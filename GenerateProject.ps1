# PowerShell script to generate a docker-compose.yml project setup

# $projectPath = Read-Host "Where to store project?"

$projectPath = "C:\Work\temp"

if (!(Test-Path -PathType Container $projectPath)) {
    New-Item -ItemType Directory -Path $projectPath
}

# Call the service selection script
. "$PSScriptRoot\SelectServices.ps1" $projectPath

Write-Host "Project setup completed successfully!" -ForegroundColor Green
