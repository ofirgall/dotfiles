# PowerShell profile entrypoint — mirrors zsh-conf/entrypoint.zsh
# Sources shared framework files, then personal overrides from my-pwsh-conf.

function Source-Conf {
    param([string]$Name)
    $shared = "$HOME\.pwsh-conf\$Name"
    if (Test-Path $shared) { . $shared }
    $personal = "$HOME\.my-pwsh-conf\$Name"
    if (Test-Path $personal) { . $personal }
}

Source-Conf vars.ps1
Source-Conf settings.ps1
Source-Conf plugins.ps1
Source-Conf aliases.ps1
Source-Conf completions.ps1
Source-Conf binds.ps1
Source-Conf prompt.ps1
