param(
    [string]$projectPath
)

$phpINIFilePath = "$projectPath\docker\php"

if (!(Test-Path -PathType Container $phpINIFilePath)) {
    New-Item -ItemType Directory -Path $phpINIFilePath
}

Write-Host "Enter php.ini configuration lines or empty line to finish."

# Store user input in an array
$configLines = @()
While ($line = Read-Host) {
    if ($line -eq "") { break }  # Stop on an empty line
    $configLines += $line
}

$iniFileContent = $configLines -join "`n"

$iniFileContent | Out-File -Encoding utf8 -FilePath "$phpINIFilePath\php.ini"
Write-Host "PHP INI generated successfully." -ForegroundColor Green