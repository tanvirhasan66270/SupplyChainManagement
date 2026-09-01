param (
    [string]$FilePath
)

$content = Get-Content -Path $FilePath -Encoding UTF8
$newLines = @()
$state = 'NORMAL'

foreach ($line in $content) {
    if ($line.StartsWith('<<<<<<< Updated upstream')) {
        $state = 'IN_UPSTREAM'
        continue
    }
    elseif ($line.StartsWith('=======')) {
        $state = 'IN_STASHED'
        continue
    }
    elseif ($line.StartsWith('>>>>>>> Stashed changes')) {
        $state = 'NORMAL'
        continue
    }

    if ($state -eq 'NORMAL' -or $state -eq 'IN_UPSTREAM') {
        $newLines += $line
    }
}

$newLines | Set-Content -Path $FilePath -Encoding UTF8
Write-Host "Resolved conflicts in $FilePath"
