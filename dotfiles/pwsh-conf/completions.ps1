# Completion caching framework — mirrors zsh-conf/completions.zsh

$script:CachedCompletions = @{}
$script:CompletionCacheDir = "$HOME\.cache\pwsh-completions"
if (-not (Test-Path $script:CompletionCacheDir)) {
    New-Item -ItemType Directory -Path $script:CompletionCacheDir -Force | Out-Null
}

function Register-CachedCompletion {
    param(
        [string]$Name,
        [string]$Command
    )
    $script:CachedCompletions[$Name] = $Command
    $cacheFile = Join-Path $script:CompletionCacheDir "$Name.ps1"

    $needsRegen = $true
    if (Test-Path $cacheFile) {
        $age = (Get-Date) - (Get-Item $cacheFile).LastWriteTime
        if ($age.TotalMinutes -lt 15) { $needsRegen = $false }
    }

    if ($needsRegen) {
        try {
            Invoke-Expression $Command | Out-File $cacheFile -Encoding utf8
        } catch {
            return
        }
    }

    if (Test-Path $cacheFile) { . $cacheFile }
}

function Update-AllCompletions {
    foreach ($entry in $script:CachedCompletions.GetEnumerator()) {
        Write-Host "Regenerating completion: $($entry.Key)"
        $cacheFile = Join-Path $script:CompletionCacheDir "$($entry.Key).ps1"
        try {
            Invoke-Expression $entry.Value | Out-File $cacheFile -Encoding utf8
        } catch {
            Write-Host "  Failed: $_"
        }
    }
    Write-Host "Done. Restart your shell to pick up changes."
}
