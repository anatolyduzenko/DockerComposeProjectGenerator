param(
    [string]$projectPath
)

$apacheConfigPath = "$projectPath\docker\apache"

if (!(Test-Path -PathType Container $apacheConfigPath)) {
    New-Item -ItemType Directory -Path $apacheConfigPath
}

$apacheConfig = @"
<VirtualHost *:80>
    DocumentRoot /var/www/html
    <Directory /var/www/html>
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>
"@

$apacheConfig | Out-File -Encoding utf8 -FilePath "$apacheConfigPath\apache.conf"
Write-Host "Apache config generated successfully." -ForegroundColor Green
