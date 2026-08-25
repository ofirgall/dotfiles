param(
    [string]$Platform = 'windows'
)

$ErrorActionPreference = 'Stop'

$Dir = $PSScriptRoot
$PlatformFile = Join-Path $Dir "$Platform-config.toml"
$CommonFile = Join-Path $Dir 'common-config.toml'
$Output = Join-Path $Dir 'config.toml'

if (-not (Test-Path $PlatformFile)) {
    Copy-Item $CommonFile $Output
    return
}

$TmpDir = [System.IO.Path]::GetTempPath()
$TmpCommon = Join-Path $TmpDir 'herdr-common.yaml'
$TmpPlatform = Join-Path $TmpDir 'herdr-platform.yaml'

try {
    yq -p toml -o yaml '.' $CommonFile > $TmpCommon
    yq -p toml -o yaml '.' $PlatformFile > $TmpPlatform
    yq -o toml ". *+ load(`"$TmpPlatform`")" $TmpCommon > $Output
} finally {
    Remove-Item $TmpCommon, $TmpPlatform -ErrorAction SilentlyContinue
}
