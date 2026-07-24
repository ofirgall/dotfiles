# PSReadLine configuration

$psrlOptions = @{
    HistorySearchCursorMovesToEnd = $true
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
