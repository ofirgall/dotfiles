# Shared aliases — mirrors zsh-conf/aliases.zsh

# Remove built-in aliases that conflict with git aliases
@('gc', 'gcm', 'gl', 'gp', 'gs') | ForEach-Object {
    Remove-Item "Alias:\$_" -Force -ErrorAction SilentlyContinue
}

# Clipboard helpers (replaces toclip)
function pwdc { (Get-Location).Path | Set-Clipboard }
function pwdcd { "cd `"$((Get-Location).Path)`"" | Set-Clipboard }

# Ticket helpers
function get_ticket {
    param([string]$FromInput)
    if ($FromInput) {
        if ($FromInput -match '([A-Z]+-[0-9]+)') { return $Matches[1] }
        return $null
    }
    $branch = git rev-parse --abbrev-ref HEAD 2>$null
    if ($branch -and $branch -match '([A-Z]+-[0-9]+)') { return $Matches[1] }
    if ((Get-Location).Path -match '([A-Z]+-[0-9]+)') { return $Matches[1] }
    return $null
}

function cticket { get_ticket | Set-Clipboard }
function ticket {
    param([string]$t)
    if (-not $t) { $t = get_ticket }
    Start-Process "$env:JIRA_URL/browse/$t"
}
Set-Alias jira ticket

function cbranch { (git rev-parse --abbrev-ref HEAD).Trim() | Set-Clipboard }
function ccmt { (git rev-parse HEAD).Trim() | Set-Clipboard }

# Git aliases
function ga { git add @args }
function gc { git commit @args }
function gcm { git commit -m @args }
function gcam { git commit -a -m @args }
function gco { git checkout @args }
function gd { git diff @args }
function gf { git fetch @args }
function gl { git pull @args }
function gp { git push @args }
function gs { git status @args }
function gst { git status @args }
function gcp { git cherry-pick @args }
function gcpa { git cherry-pick --abort @args }
function gcpc { git cherry-pick --continue @args }
function ghs { git hist @args }
function ghist { git hist @args }
function gdiff { git diff @args }
function gshow { git show @args }
function grim { git rebase -i origin/master @args }
function groot { Set-Location (git rev-parse --show-toplevel) }

# GitHub Actions — watch run and notify when done
function gh-notify {
    param([string]$RunUrl)
    if (-not $RunUrl) {
        Write-Host "Usage: gh-notify <run_url_or_id>"
        return
    }
    $runId = if ($RunUrl -match 'runs/(\d+)') { $Matches[1] } else { $RunUrl }
    $repoFlag = @()
    if ($RunUrl -match 'github\.com/([^/]+/[^/]+)') {
        $repoFlag = @('--repo', $Matches[1])
    }
    gh run watch $runId @repoFlag
    if ($LASTEXITCODE -eq 0) {
        & "$HOME\dotfiles_scripts\notify\windows_notify.ps1" "GitHub Actions" "Run is done!"
    }
}

function gh-notify-pr {
    param([string]$PrUrl)
    $pr = $null
    $repoFlag = @()

    if (-not $PrUrl) {
        $pr = gh pr view --json number --jq '.number' 2>$null
        if (-not $pr) {
            Write-Host "No open PR found for the current branch."
            return
        }
    } else {
        if ($PrUrl -match 'github\.com/([^/]+/[^/]+)') {
            $repoFlag = @('--repo', $Matches[1])
        }
        $pr = if ($PrUrl -match 'pull/(\d+)') { $Matches[1] } else { $PrUrl }
    }

    Write-Host "Watching all checks for PR #$pr..."
    gh pr checks $pr @repoFlag --watch
    if ($LASTEXITCODE -eq 0) {
        & "$HOME\dotfiles_scripts\notify\windows_notify.ps1" "GitHub Actions" "All checks passed for PR #$pr!"
    } else {
        & "$HOME\dotfiles_scripts\notify\windows_notify.ps1" "GitHub Actions" "Some checks failed for PR #$pr"
    }
}

# Misc
function p { python -c "print($($args -join ' '))" }

function logs {
    param([string]$Ticket)
    if (-not $Ticket) { $Ticket = get_ticket }
    $dir = "$HOME\logs\$Ticket"
    if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
    Set-Location $dir
}

# eza / ls aliases
if ($env:NO_EZA -ne "1" -and (Get-Command eza -ErrorAction SilentlyContinue)) {
    function ls { eza @global:EZA_PARAMS @args }
    function l { eza @global:EZA_PARAMS -lbF @args }
    function ll { eza @global:EZA_PARAMS -la @args }
    function llm { eza @global:EZA_PARAMS -la --sort=modified @args }
    function la { eza @global:EZA_PARAMS -lbhHigUmuSa @args }
    function tree { eza --tree @args }
    function lS { eza -1 @args }
} else {
    function ll { Get-ChildItem -Force @args }
    function la { Get-ChildItem -Force @args }
}
