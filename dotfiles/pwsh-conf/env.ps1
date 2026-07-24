# Shared environment — mirrors zsh-conf/env.zsh

$env:FZF_DEFAULT_OPTS = ""

function Add-ToPath {
    param([string]$Dir)
    if ((Test-Path $Dir) -and $env:PATH -notlike "*$Dir*") {
        $env:PATH = "$Dir;$env:PATH"
    }
}

function Append-ToPath {
    param([string]$Dir)
    if ((Test-Path $Dir) -and $env:PATH -notlike "*$Dir*") {
        $env:PATH = "$env:PATH;$Dir"
    }
}

Add-ToPath "$HOME\.local\bin"
Append-ToPath "$HOME\.npm-packages\bin"
