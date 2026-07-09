# Windows dotfiles bootstrap — installs MSYS2, then hands off to dotbot via bash.
# Run from PowerShell: .\install-windows.ps1

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# 1. Check symlink capability (requires Developer Mode or admin)
$testTarget = [System.IO.Path]::GetTempFileName()
$testLink = "$testTarget.link"
$mklinkOut = cmd /c "mklink `"$testLink`" `"$testTarget`"" 2>&1
if (Test-Path $testLink) {
    Remove-Item $testLink -Force
    Remove-Item $testTarget -Force
} else {
    Remove-Item $testTarget -Force -ErrorAction SilentlyContinue
    Write-Error "Cannot create symlinks. Enable Developer Mode (Settings > System > For Developers) or run as Administrator, then re-run this script."
    exit 1
}

# 2. Install MSYS2 via winget
$msys2 = "C:\msys64\usr\bin\bash.exe"
if (-not (Test-Path $msys2)) {
    Write-Host "Installing MSYS2..."
    winget install --id MSYS2.MSYS2 --accept-package-agreements --accept-source-agreements
    if (-not (Test-Path $msys2)) {
        Write-Error "MSYS2 installation failed — $msys2 not found."
        exit 1
    }
} else {
    Write-Host "MSYS2 already installed"
}

# 3. Configure MSYS2 to use the Windows home directory
$nsswitch = "C:\msys64\etc\nsswitch.conf"
if (Test-Path $nsswitch) {
    $content = Get-Content $nsswitch -Raw
    if ($content -notmatch "db_home:\s*windows") {
        $content = $content -replace "(db_home:.*)", "db_home: windows"
        if ($content -notmatch "db_home:") {
            $content += "`ndb_home: windows`n"
        }
        Set-Content -Path $nsswitch -Value $content -Encoding utf8
        Write-Host "Configured MSYS2 to use Windows home directory"
    }
} else {
    Set-Content -Path $nsswitch -Value "db_home: windows`n" -Encoding utf8
    Write-Host "Created nsswitch.conf with Windows home directory"
}

# 4. Update MSYS2 base system
Write-Host "Updating MSYS2 base system..."
& $msys2 -lc "pacman -Syu --noconfirm"

# 5. Install git + python (needed for dotbot)
Write-Host "Installing git and python..."
& $msys2 -lc "pacman -S --noconfirm --needed git python"

# 6. Hand off to bash-based dotbot bootstrap
$repoWin = Split-Path -Parent $MyInvocation.MyCommand.Definition
$repoMsys = $repoWin -replace '\\', '/'
$repoMsys = '/' + $repoMsys.Substring(0, 1).ToLower() + $repoMsys.Substring(2)

Write-Host "Running dotbot via MSYS2 bash..."
$env:MSYS = "winsymlinks:nativestrict"
& $msys2 -lc "cd '$repoMsys' && ./install-windows"
