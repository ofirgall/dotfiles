# Personal environment — mirrors my-zsh-conf/env.zsh

# Go
$env:GOPATH = "$HOME\go"
Append-ToPath "$HOME\go\bin"

# Rust
$env:CARGO_NET_GIT_FETCH_WITH_CLI = "true"
Add-ToPath "$HOME\.cargo\bin"

# ripgrep
if (Test-Path "$HOME\.ripgreprc") {
    $env:RIPGREP_CONFIG_PATH = "$HOME\.ripgreprc"
}

# Mason LSPs
Append-ToPath "$HOME\.local\share\nvim\mason\bin"

# Editor
$env:EDITOR = 'vim'
if (Get-Command kv -ErrorAction SilentlyContinue) {
    $env:EDITOR = 'kv'
    $env:MANPAGER = 'kv +Man!'
    $env:MANWIDTH = '999'
}

# dotfiles scripts
Add-ToPath "$HOME\dotfiles_scripts\notify"
Append-ToPath "$HOME\dotfiles_scripts\misc"
Append-ToPath "$HOME\dotfiles_scripts\inner"
Append-ToPath "$HOME\dotfiles_scripts\git"
Append-ToPath "$HOME\dotfiles_scripts\cursor"

# agents-status
Add-ToPath "$HOME\agents-status\simple-wrappers"

# Koala
$env:NEOGIT = "true"
$env:KOALA_CODE_DIFF = "true"

# AWS
$env:AWS_PROFILE = "dev"

# Secrets
$_secretsFile = "$HOME\secrets.ps1"
if (Test-Path $_secretsFile) { . $_secretsFile }
