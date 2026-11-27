# Shared keybindings — mirrors zsh-conf/binds.zsh

# Accept autosuggestion with Ctrl+Space (PSReadLine 2.2+)
$_psrlFunctions = (Get-PSReadLineKeyHandler -Bound -Unbound).Function
if ($_psrlFunctions -contains 'AcceptSuggestion') {
    Set-PSReadLineKeyHandler -Chord 'Ctrl+Spacebar' -Function AcceptSuggestion
}

# Edit command line in $EDITOR with Ctrl+X, Ctrl+E
Set-PSReadLineKeyHandler -Chord 'Ctrl+x,Ctrl+e' -ScriptBlock {
    $line = $null
    $cursor = $null
    [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)
    $tmp = Join-Path ([System.IO.Path]::GetTempPath()) "psrl-edit-$(Get-Random).ps1"
    $line | Out-File $tmp -Encoding utf8 -NoNewline
    $editor = if ($env:EDITOR) { $env:EDITOR } else { 'notepad' }
    & $editor $tmp
    if (Test-Path $tmp) {
        $edited = (Get-Content $tmp -Raw).TrimEnd()
        [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
        [Microsoft.PowerShell.PSConsoleReadLine]::Insert($edited)
        Remove-Item $tmp -Force
    }
}
