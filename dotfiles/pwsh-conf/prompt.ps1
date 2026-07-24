# Starship prompt — mirrors zsh-conf/design.zsh

if (Get-Command starship -ErrorAction SilentlyContinue) {
    Invoke-Expression (&starship init powershell)
}

$_starship_files = @("$HOME\.zsh-conf\starship.toml")
if ($env:NERD_FONT -eq "1") {
    $_starship_files += "$HOME\.zsh-conf\starship_nerdfont.toml"
}
$_personal_starship = "$HOME\.my-zsh-conf\starship.toml"
if (Test-Path $_personal_starship) {
    $_starship_files += $_personal_starship
}

function _gen_starship {
    Write-Host "Generating $HOME\.config\starship.toml"
    $tmpDir = Join-Path ([System.IO.Path]::GetTempPath()) "starship-merge-$(Get-Random)"
    New-Item -ItemType Directory -Path $tmpDir -Force | Out-Null

    $i = 0
    foreach ($f in $script:_starship_files) {
        if (Test-Path $f) {
            yq eval -oy $f | Out-File "$tmpDir\$i.yaml" -Encoding utf8
            $i++
        }
    }

    $configDir = "$HOME\.config"
    if (-not (Test-Path $configDir)) { New-Item -ItemType Directory -Path $configDir -Force | Out-Null }

    yq eval-all -oy --expression '. as $item ireduce ({}; . *+d $item)' "$tmpDir\*.yaml" |
        yj -yt |
        Out-File "$HOME\.config\starship.toml" -Encoding utf8

    Remove-Item $tmpDir -Recurse -Force
}
