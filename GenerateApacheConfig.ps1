# PowerShell script to generate an Apache configuration file

param(
    [string]$projectPath
)

$apacheConfigPath = "$projectPath\docker\apache"

if (!(Test-Path -PathType Container $apacheConfigPath)) {
    New-Item -ItemType Directory -Path $apacheConfigPath
}

# Prompt user for project type
Write-Host "Select project type:"
Write-Host "1. WordPress"
Write-Host "2. Laravel"
Write-Host "3. Raw PHP"
$projectType = Read-Host "Enter the number corresponding to your project type"

# Define base configuration
$apacheConfig = @"
<VirtualHost *:80>
    ServerAdmin webmaster@localhost
    DocumentRoot /var/www/html
    <Directory /var/www/html>
        Options Indexes FollowSymLinks MultiViews
        AllowOverride All
        Require all granted
    </Directory>
"@

if ($projectType -eq "1") {
    # WordPress configuration
    $apacheConfig += @"
    <IfModule mod_rewrite.c>
        RewriteEngine On
        RewriteBase /
        RewriteRule ^index\.php$ - [L]
        RewriteCond %{REQUEST_FILENAME} !-f
        RewriteCond %{REQUEST_FILENAME} !-d
        RewriteRule . /index.php [L]
    </IfModule>
"@
}
elseif ($projectType -eq "2") {
    # Laravel configuration
    $apacheConfig += @"
    <IfModule mod_rewrite.c>
        RewriteEngine On
        RewriteRule ^(.*)/$ /$1 [R=301,L]
        RewriteCond %{REQUEST_FILENAME} !-f
        RewriteCond %{REQUEST_FILENAME} !-d
        RewriteRule ^ index.php [L]
    </IfModule>
"@
}

$apacheConfig += "

</VirtualHost>
"

# Write content to apache.conf
$apacheConfig | Out-File -Encoding utf8 -FilePath "$apacheConfigPath\apache.conf"
Write-Host "Apache config generated successfully." -ForegroundColor Green
