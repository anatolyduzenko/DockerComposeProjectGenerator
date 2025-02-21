# PowerShell script to generate an Nginx Dockerfile

param(
    [string]$projectPath
)

$nginxDockerFilePath = "$projectPath\docker\nginx"

if (!(Test-Path -PathType Container $nginxDockerFilePath)) {
    New-Item -ItemType Directory -Path $nginxDockerFilePath
}

$dockerfileContent = @"
FROM nginx
COPY nginx.conf /etc/nginx/conf.d/default.conf
"@

$dockerfileContent | Out-File -Encoding utf8 -FilePath "$nginxDockerFilePath\Dockerfile"
Write-Host "PHP Dockerfile generated successfully." -ForegroundColor Green
