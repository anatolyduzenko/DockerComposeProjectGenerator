# PowerShell script to generate an Nginx configuration file
# WordPress, Laravel, empty

param(
    [string]$projectPath
)

$nginxConfigPath = "$projectPath\docker\nginx"

if (!(Test-Path -PathType Container $nginxConfigPath)) {
    New-Item -ItemType Directory -Path $nginxConfigPath
}

$nginxLogsPath = "$projectPath\logs"

if (!(Test-Path -PathType Container $nginxLogsPath)) {
    New-Item -ItemType Directory -Path $nginxLogsPath
}

# Prompt user for project type
Write-Host "Select project type:"
Write-Host "1. Wordpress"
Write-Host "2. Laravel"
Write-Host "3. Raw PHP"
$projectType = Read-Host "Enter the number corresponding to your project type"

$serverName = Read-Host "Enter the domain for project"

$setupWebsockets = Read-Host "Use WebSockets? (yes/no)"

# Define base configuration
$nginxConfig = "server {
    listen 80;
    server_name $serverName;

    charset utf-8;
    root /var/www/html;
    index index.php index.html index.htm;
    
    error_log  /var/www/logs/nginx_error.log;
    access_log /var/www/logs/nginx_access.log;

    location = /favicon.ico { 
        access_log off; 
        log_not_found off; 
    }
    location = /robots.txt  { 
        access_log off; 
        log_not_found off; 
    }

    error_page 404 /index.php;
" 

if ($projectType -eq "1") {
    # Wordpress configuration
    $nginxConfig += @"

    location ~* /wp-cron.php$ {
        fastcgi_pass php:9000;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME `$document_root`$fastcgi_script_name;
        fastcgi_param REQUEST_METHOD GET;
    }

    location / {
        try_files `$uri `$uri/ /index.php?`$args;
    }
"@
}
elseif ($projectType -eq "2") {
    # Laravel configuration
    $nginxConfig += @"

    location / {
        try_files `$uri `$uri/ /index.php?`$query_string;
    }

    location ~ \.(php|html)$ {
        include fastcgi_params;
        fastcgi_pass php:9000;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME `$document_root`$fastcgi_script_name;
    }
    
    location ~ /\.(?!well-known).* {
        deny all;
    }
"@
}
elseif ($projectType -eq "3") {
    # Raw PHP configuration
    $nginxConfig += @"

    location ~* /wp-cron.php$ {
        fastcgi_pass php:9000;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME `$document_root`$fastcgi_script_name;
        fastcgi_param REQUEST_METHOD GET;
    }

    location ~ \.php\$ {
        include fastcgi_params;
        fastcgi_pass php:9000;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME `$document_root`$fastcgi_script_name;
        fastcgi_param PATH_INFO `$fastcgi_path_info;
    }
"@
}

if ($setupWebsockets -eq "yes") {
    $nginxConfig += @"


    location /ws/ {
        proxy_pass http://php:8080; # Replace with the actual WebSocket server
        proxy_http_version 1.1;
        proxy_set_header Upgrade `$http_upgrade;
        proxy_set_header Connection "Upgrade";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP `$remote_addr;
        proxy_set_header X-Forwarded-For `$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto `$scheme;
        proxy_read_timeout 60;
        proxy_send_timeout 60;
    }
"@
}

$nginxConfig += "
}
"

# Write content to nginx.conf
$nginxConfig | Out-File -Encoding ascii -FilePath "$nginxConfigPath\nginx.conf"
Write-Host "Nginx config generated successfully." -ForegroundColor Green
