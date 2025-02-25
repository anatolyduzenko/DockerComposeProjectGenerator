# PowerShell script to generate a docker-compose.yml project setup

$projectPath = Read-Host "Where to store project?"

if (!(Test-Path -PathType Container $projectPath)) {
    New-Item -ItemType Directory -Path $projectPath
}

$sourceDir = "src"
$sourcePath = "$projectPath/$sourceDir"

if (!(Test-Path -PathType Container $sourcePath)) {
    New-Item -ItemType Directory -Path $sourcePath
}

# Call the service selection script
. "$PSScriptRoot\SelectServices.ps1" $projectPath

Write-Host "Project setup completed successfully!" -ForegroundColor Green
