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
    $session = "general"
    $dir = "$HOME\notes\$session"
    if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
    Set-Location $dir
}
