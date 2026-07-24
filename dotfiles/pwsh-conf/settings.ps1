# PSReadLine configuration

$psrlOptions = @{
    HistorySearchCursorMovesToEnd = $true
    MaximumHistoryCount        = 50000
    HistoryNoDuplicates        = $true
    HistorySaveStyle           = 'SaveIncrementally'
    BellStyle                  = 'None'
}

if ($env:VIM_MODE -eq "1") {
    $psrlOptions.EditMode = 'Vi'
}

$psrlVersion = (Get-Module PSReadLine).Version
if ($psrlVersion -ge [version]'2.2.0') {
    $psrlOptions.PredictionSource = 'History'
    $psrlOptions.PredictionViewStyle = 'InlineView'
}

Set-PSReadLineOption @psrlOptions

# Auto-cd: type a directory name to cd into it
$ExecutionContext.InvokeCommand.CommandNotFoundAction = {
    param($Name, $EventArgs)
    if (Test-Path $Name -PathType Container) {
        $EventArgs.StopSearch = $true
        $EventArgs.CommandScriptBlock = { Set-Location $Name }.GetNewClosure()
    }
}
