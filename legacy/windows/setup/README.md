# Some Windows shit
* `binds.ahk` - Autohotkey script for my workspace binds and some other

## Install & Config
* Install [alacritty](https://github.com/alacritty/alacritty/releases)
* Install [wezterm](https://wezfurlong.org/wezterm/)
* [AutoHotKey](https://www.autohotkey.com/)
* Run `disable_win_l.reg` to disable Winkey+L to lock
* Run `disable_office_pop.bat` to disable CTRL+ALT+SHIFT+Key office popup
* Multitasking -> disable `When I snap a window, show what I can snap next`
* Keyboard -> Shortest repeat delay, highest Repeate rate
* Run `Set-ExecutionPolicy -ExecutionPolicy Unrestricted` in powershell from admin, to allow the execute of `windows_notify.ps1`
* Right click on the task bar -> Task bar settings -> Automatically hide the task bar in desktop mode
TODO: install brotab for windows

### Fix mouse support for alacritty
* install `Windows Terminal` from store
* create backup for `C:\Windows\System32\conhost.exe` 
* [change permissions of conhost.exe to be writeable from your user](https://github.com/microsoft/terminal/issues/1817)
* use admin cmd to copy `C:\Program Files\WindowsApps\Microsoft.WindowsTerminal_<VERSION information>\OpenConsole.exe` to `C:\Windows\System32\conhost.exe`


## TODO
* Download MoveToDesktop
* tmux keyboard layout
* Both shift to change lang
