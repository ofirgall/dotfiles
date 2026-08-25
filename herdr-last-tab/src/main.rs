use serde::Deserialize;
use std::env;
use std::fs;
use std::io::{BufRead, BufReader, Read, Write};
use std::path::PathBuf;
use std::process::Command;
use std::thread;
use std::time::Duration;

#[cfg(unix)]
use std::os::unix::net::UnixStream;

fn state_dir() -> PathBuf {
    #[cfg(unix)]
    let dir = PathBuf::from("/tmp/herdr-last-tab");
    #[cfg(windows)]
    let dir = PathBuf::from(env::var("TEMP").unwrap_or_else(|_| r"C:\Temp".into()))
        .join("herdr-last-tab");
    fs::create_dir_all(&dir).ok();
    dir
}

fn sock_path() -> PathBuf {
    if let Ok(p) = env::var("HERDR_SOCKET_PATH") {
        return PathBuf::from(p);
    }
    #[cfg(unix)]
    {
        let home = env::var("HOME").unwrap_or_else(|_| "/tmp".into());
        PathBuf::from(home).join(".config/herdr/herdr.sock")
    }
    #[cfg(windows)]
    {
        let appdata = env::var("APPDATA").unwrap_or_else(|_| {
            let profile = env::var("USERPROFILE").unwrap_or_else(|_| r"C:\Users\Default".into());
            format!(r"{}\AppData\Roaming", profile)
        });
        PathBuf::from(appdata).join(r"herdr\herdr.sock")
    }
}

fn pid_file() -> PathBuf {
    state_dir().join("daemon.pid")
}

#[cfg(unix)]
fn is_process_alive(pid: u32) -> bool {
    unsafe { libc::kill(pid as i32, 0) == 0 }
}

#[cfg(windows)]
fn is_process_alive(pid: u32) -> bool {
    unsafe {
        let handle = winapi::OpenProcess(winapi::PROCESS_QUERY_LIMITED_INFORMATION, 0, pid);
        if handle == 0 {
            return false;
        }
        winapi::CloseHandle(handle);
        true
    }
}

fn is_daemon_running() -> bool {
    let pf = pid_file();
    if let Ok(content) = fs::read_to_string(&pf) {
        if let Ok(pid) = content.trim().parse::<u32>() {
            return is_process_alive(pid);
        }
    }
    false
}

// --- Daemon ---

#[derive(Deserialize)]
struct EventMessage {
    data: Option<EventData>,
}

#[derive(Deserialize)]
struct EventData {
    #[serde(rename = "type")]
    event_type: Option<String>,
    workspace_id: Option<String>,
    tab_id: Option<String>,
}

fn subscribe(stream: &mut impl Write) -> std::io::Result<()> {
    let req = serde_json::json!({
        "id": "last-tab-sub",
        "method": "events.subscribe",
        "params": {
            "subscriptions": [{"type": "tab.focused"}]
        }
    });
    let mut msg = serde_json::to_string(&req)?;
    msg.push('\n');
    stream.write_all(msg.as_bytes())?;
    Ok(())
}

fn listen(stream: impl Read) {
    let reader = BufReader::new(stream);
    let sd = state_dir();

    for line in reader.lines() {
        let line = match line {
            Ok(l) => l,
            Err(_) => return,
        };
        if line.trim().is_empty() {
            continue;
        }

        let msg: EventMessage = match serde_json::from_str(&line) {
            Ok(m) => m,
            Err(_) => continue,
        };

        let data = match msg.data {
            Some(d) => d,
            None => continue,
        };

        if data.event_type.as_deref() != Some("tab_focused") {
            continue;
        }

        let workspace_id = match data.workspace_id {
            Some(w) if !w.is_empty() => w,
            _ => continue,
        };
        let tab_id = match data.tab_id {
            Some(t) if !t.is_empty() => t,
            _ => continue,
        };

        let current_file = sd.join(format!("{}.current", workspace_id));
        let prev_file = sd.join(format!("{}.prev", workspace_id));

        let prev_tab = fs::read_to_string(&current_file)
            .unwrap_or_default()
            .trim()
            .to_string();

        if !prev_tab.is_empty() && prev_tab != tab_id {
            fs::write(&prev_file, &prev_tab).ok();
        }

        fs::write(&current_file, &tab_id).ok();
    }
}

fn daemon_loop() {
    loop {
        #[cfg(unix)]
        {
            if let Ok(mut stream) = UnixStream::connect(sock_path()) {
                if subscribe(&mut stream).is_ok() {
                    listen(stream);
                }
            }
        }
        #[cfg(windows)]
        {
            let pipe_path = format!(r"\\.\pipe\{}", sock_path().display());
            if let Ok(mut file) = fs::OpenOptions::new()
                .read(true)
                .write(true)
                .open(&pipe_path)
            {
                if subscribe(&mut file).is_ok() {
                    listen(file);
                }
            }
        }
        thread::sleep(Duration::from_secs(2));
    }
}

#[cfg(unix)]
fn daemonize() {
    use nix::unistd::{fork, setsid, ForkResult};

    match unsafe { fork() } {
        Ok(ForkResult::Parent { .. }) => std::process::exit(0),
        Ok(ForkResult::Child) => {}
        Err(_) => std::process::exit(1),
    }

    setsid().ok();

    match unsafe { fork() } {
        Ok(ForkResult::Parent { .. }) => std::process::exit(0),
        Ok(ForkResult::Child) => {}
        Err(_) => std::process::exit(1),
    }

    use std::os::unix::io::AsRawFd;
    let devnull = fs::OpenOptions::new()
        .read(true)
        .write(true)
        .open("/dev/null")
        .unwrap();
    let fd = devnull.as_raw_fd();
    unsafe {
        libc::dup2(fd, 0);
        libc::dup2(fd, 1);
        libc::dup2(fd, 2);
    }
}

fn run_daemon() {
    if is_daemon_running() {
        return;
    }

    #[cfg(unix)]
    daemonize();

    fs::write(pid_file(), std::process::id().to_string()).ok();
    daemon_loop();
}

// --- Switch ---

#[derive(Deserialize)]
struct SnapshotResponse {
    result: Option<SnapshotResult>,
}

#[derive(Deserialize)]
struct SnapshotResult {
    snapshot: Option<Snapshot>,
}

#[derive(Deserialize)]
struct Snapshot {
    focused_workspace_id: Option<String>,
}

fn get_focused_workspace() -> Option<String> {
    let output = Command::new("herdr")
        .args(["api", "snapshot"])
        .output()
        .ok()?;
    if !output.status.success() {
        return None;
    }
    let resp: SnapshotResponse = serde_json::from_slice(&output.stdout).ok()?;
    resp.result?.snapshot?.focused_workspace_id
}

fn spawn_daemon() {
    let exe = env::current_exe().unwrap_or_else(|_| PathBuf::from("herdr-last-tab"));

    #[cfg(unix)]
    {
        Command::new(exe).arg("daemon").spawn().ok();
    }
    #[cfg(windows)]
    {
        use std::os::windows::process::CommandExt;
        use std::process::Stdio;
        const CREATE_NO_WINDOW: u32 = 0x08000000;
        Command::new(exe)
            .arg("daemon")
            .stdin(Stdio::null())
            .stdout(Stdio::null())
            .stderr(Stdio::null())
            .creation_flags(CREATE_NO_WINDOW)
            .spawn()
            .ok();
    }
}

fn run_switch() {
    if !is_daemon_running() {
        spawn_daemon();
        thread::sleep(Duration::from_millis(300));
    }

    let workspace_id = match get_focused_workspace() {
        Some(w) => w,
        None => return,
    };

    let prev_file = state_dir().join(format!("{}.prev", workspace_id));
    let prev_tab = match fs::read_to_string(&prev_file) {
        Ok(t) => t.trim().to_string(),
        Err(_) => return,
    };

    if prev_tab.is_empty() {
        return;
    }

    Command::new("herdr")
        .args(["tab", "focus", &prev_tab])
        .output()
        .ok();
}

// --- Main ---

fn main() {
    let args: Vec<String> = env::args().collect();
    let cmd = args.get(1).map(|s| s.as_str()).unwrap_or("switch");

    match cmd {
        "daemon" => run_daemon(),
        "switch" => run_switch(),
        _ => {
            eprintln!("Usage: herdr-last-tab {{daemon|switch}}");
            std::process::exit(1);
        }
    }
}

#[cfg(unix)]
mod libc {
    extern "C" {
        pub fn kill(pid: i32, sig: i32) -> i32;
        pub fn dup2(oldfd: i32, newfd: i32) -> i32;
    }
}

#[cfg(windows)]
mod winapi {
    extern "system" {
        pub fn OpenProcess(desired_access: u32, inherit_handle: i32, process_id: u32) -> isize;
        pub fn CloseHandle(handle: isize) -> i32;
    }
    pub const PROCESS_QUERY_LIMITED_INFORMATION: u32 = 0x1000;
}
