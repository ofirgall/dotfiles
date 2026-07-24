# Personal aliases — mirrors my-zsh-conf/aliases.zsh

Set-Alias nv kv -Force -Option AllScope
Set-Alias v kv -Force -Option AllScope
function br { broot --conf "$HOME\.brootrc.toml" @args }
function btmf { btm -C "$HOME\dotfiles\dotfiles\bottom\bottom-full.toml" @args }

# bat as cat — override the built-in Get-Content alias
if (Get-Command bat -ErrorAction SilentlyContinue) {
    Remove-Item Alias:\cat -Force -ErrorAction SilentlyContinue
    Set-Alias cat bat
}

function open { Start-Process @args }

# cd aliases
function cdd { Set-Location "$HOME\dotfiles" }
function cdn { Set-Location "$HOME\dotfiles\editors\KoalaConfig" }
function cdz { Set-Location "$HOME\.my-pwsh-conf" }
function cdZ { Set-Location "$HOME\.pwsh-conf" }
function cdr { groot }
Set-Alias gr groot
function plans { Set-Location "$HOME\.cursor\plans" }
function cdl { Set-Location $args[-1] }

function up {
    param([int]$Count = 1)
    $path = '..'
    for ($i = 1; $i -lt $Count; $i++) { $path = Join-Path $path '..' }
    Set-Location $path
}

# Neovim/KoalaVim wrappers
function ai { kv --ai -- @args }
function g { kv --git -- @args }
function gt { kv --tree -- @args }

# Override shared git aliases with kv wrappers
function gd { kv --git-diff -- @args }
function ghs { kv --tree -- @args }

function gshowp { git show-patch @args }
Set-Alias cb cbranch

# GitHub CLI
function gpc { gh pr create @args }
function gpv { gh pr view --web @args }
function gpvc {
    (gh pr view --json url --jq '.url') | Set-Clipboard
}
function gpar { gh pr edit --add-reviewer @args }
function ghd { gh dash @args }
function mdp { gh markdown-preview --full @args }

function gh_select_account {
    $users = gh auth status 2>$null | Select-String 'Logged in' | ForEach-Object {
        if ($_ -match 'account (\S+)') { $Matches[1] }
    }
    if (-not $users -or @($users).Count -le 1) { return }
    $selected = $users | fzf --prompt='GitHub account> ' --height=40% --reverse
    if ($selected) { gh auth switch -u $selected }
}

function gfork {
    $prevUser = gh api user --jq '.login' 2>$null
    gh_select_account
    if ($LASTEXITCODE -ne 0) { return }
    git remote rename origin upstream
    gh repo fork --remote --remote-name origin
    $branch = (git branch --show-current).Trim()
    git config remote.pushDefault origin
    git push --set-upstream origin $branch
    git branch "--set-upstream-to=origin/$branch"
    git config "branch.$branch.pushremote" origin
    if ($prevUser) { gh auth switch -u $prevUser }
}

# yazi file manager
function y {
    $tmp = Join-Path ([System.IO.Path]::GetTempPath()) "yazi-cwd-$(Get-Random)"
    yazi @args --cwd-file="$tmp"
    if (Test-Path $tmp) {
        $cwd = (Get-Content $tmp -Raw).Trim()
        if ($cwd -and $cwd -ne (Get-Location).Path -and (Test-Path $cwd)) {
            Set-Location $cwd
        }
        Remove-Item $tmp -Force
    }
}
Set-Alias c y

function tmp {
    param([string]$ft)
    $scratch = Join-Path ([System.IO.Path]::GetTempPath()) "scratch-$(Get-Random)"
    kv $scratch +"set ft=$ft"
    Write-Output $scratch
}

function nvlog { $env:NVLOG = "1"; kv @args; Remove-Item Env:\NVLOG }

# Misc
$env:VREC_ENV_NAME = "ofir"

function notes {
    $session = Split-Path -Leaf (Get-Location)
    $dir = "$HOME\notes\$session"
    if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
    Set-Location $dir
}

# ez-workspaces (no native powershell init, manual cd wrapper)
function ez {
    $tmp = Join-Path ([System.IO.Path]::GetTempPath()) "ez-cd-$(Get-Random)"
    $postCmd = Join-Path ([System.IO.Path]::GetTempPath()) "ez-post-$(Get-Random)"
    & (Get-Command ez -CommandType Application) @args --cd-file="$tmp" --post-cmd-file="$postCmd"
    if ((Test-Path $postCmd) -and (Get-Item $postCmd).Length -gt 0) {
        Remove-Item $tmp, $postCmd -Force -ErrorAction SilentlyContinue
        ez @args
        return
    }
    if ((Test-Path $tmp) -and (Get-Item $tmp).Length -gt 0) {
        $dest = (Get-Content $tmp -Raw).Trim()
        if ($dest) { Set-Location $dest }
    }
    Remove-Item $tmp, $postCmd -Force -ErrorAction SilentlyContinue
}
function del { ez session delete @args }
function new { ez session new @args }
function ezp { ez --workspace "$HOME\workspace\personal" @args }
function ezw { ez --workspace "$HOME\workspace\work" @args }

function venv { . .\Scripts\Activate.ps1 }
function pg { Set-Location "$HOME\playgrounds"; kv }
function cls { Clear-Host }

function ssh { $env:TERM = 'xterm-256color'; ssh.exe @args }

# cd-to-git: fzf over git repos in a directory
function cg {
    param([string]$Dir = '.')
    $repo = Get-ChildItem -Path $Dir -Directory -Recurse -Filter '.git' -Hidden -ErrorAction SilentlyContinue |
        ForEach-Object { $_.Parent.FullName } |
        fzf --reverse --height=40%
    if ($repo) { Set-Location $repo }
}
function cgp { cg "$HOME\workspace\personal" }
function cgw { cg "$HOME\worktrees" }
function cgnp { cg "$HOME\.local\share\kvim-envs\main\lazy" }
function cgk {
    $dir = Get-ChildItem "$HOME\.local\share\kvim-envs" -Directory |
        ForEach-Object { $_.Name } | fzf --reverse --height=30%
    if ($dir) { cg "$HOME\.local\share\kvim-envs\$dir\lazy" }
}
function cgg { cg "$HOME\go" }
