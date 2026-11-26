use std::io::{Read, Write};
use std::os::unix::net::UnixStream;

const SOCKET_PROTOCOL_VERSION: u32 = 1;

pub struct Connection {
    stream: UnixStream,
}

#[derive(serde::Serialize)]
struct ClientRequest<'a> {
    args: &'a [&'a str],
    stdin: &'a str,
    #[serde(rename = "windowId")]
    window_id: Option<u32>,
    workspace: Option<String>,
}

#[derive(serde::Deserialize)]
pub struct Response {
    #[serde(rename = "exitCode")]
    pub exit_code: i32,
    #[serde(default)]
    pub stdout: String,
}

impl Connection {
    pub fn connect() -> Option<Self> {
        let user = std::env::var("USER").ok()?;
        let path = format!("/tmp/bobko.aerospace-{user}.sock");
        let mut stream = UnixStream::connect(path).ok()?;

        stream.write_all(&SOCKET_PROTOCOL_VERSION.to_le_bytes()).ok()?;
        let mut buf = [0u8; 4];
        stream.read_exact(&mut buf).ok()?;
        if u32::from_le_bytes(buf) != SOCKET_PROTOCOL_VERSION {
            return None;
        }

        Some(Self { stream })
    }

    pub fn send(&mut self, args: &[&str]) -> Option<Response> {
        let req = ClientRequest {
            args,
            stdin: "",
            window_id: std::env::var("AEROSPACE_WINDOW_ID")
                .ok()
                .and_then(|v| v.parse().ok()),
            workspace: std::env::var("AEROSPACE_WORKSPACE").ok(),
        };

        let payload = serde_json::to_vec(&req).ok()?;
        self.stream.write_all(&(payload.len() as u32).to_le_bytes()).ok()?;
        self.stream.write_all(&payload).ok()?;

        let mut len_buf = [0u8; 4];
        self.stream.read_exact(&mut len_buf).ok()?;
        let len = u32::from_le_bytes(len_buf) as usize;

        let mut resp_buf = vec![0u8; len];
        self.stream.read_exact(&mut resp_buf).ok()?;

        serde_json::from_slice(&resp_buf).ok()
    }

    /// Send a command, return true if it exited successfully.
    pub fn run(&mut self, args: &[&str]) -> bool {
        self.send(args).is_some_and(|r| r.exit_code == 0)
    }

    /// Send a command and return trimmed stdout on success.
    pub fn query(&mut self, args: &[&str]) -> Option<String> {
        let r = self.send(args)?;
        (r.exit_code == 0).then(|| r.stdout.trim().to_string())
    }
}
