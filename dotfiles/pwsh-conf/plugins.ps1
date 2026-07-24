# Module management — replaces zinit plugin loading

$_requiredModules = @('PSFzf')

foreach ($mod in $_requiredModules) {
    if (-not (Get-Module -ListAvailable $mod)) {
        Write-Host "Installing module: $mod"
        $installArgs = @{ Name = $mod; Scope = 'CurrentUser'; Force = $true }
        if ((Get-Command Install-Module).Parameters.ContainsKey('AcceptLicense')) {
            $installArgs.AcceptLicense = $true
        }
        Install-Module @installArgs
    }
    Import-Module $mod -ErrorAction SilentlyContinue
}

if (Get-Module PSFzf) {
    Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordReverseHistory 'Ctrl+r'
    Set-PSReadLineKeyHandler -Key Tab -ScriptBlock { Invoke-FzfTabCompletion }
    Set-PSReadLineKeyHandler -Key Shift+Tab -Function MenuComplete
}
