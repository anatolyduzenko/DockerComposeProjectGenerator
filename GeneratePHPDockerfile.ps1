param(
    [string]$projectPath,
    [string]$phpVersion
)

$phpDockerFilePath = "$projectPath\docker\php"

if (!(Test-Path -PathType Container $phpDockerFilePath)) {
    New-Item -ItemType Directory -Path $phpDockerFilePath
}

$phpExtensions = Read-Host "Enter additional PHP extensions (comma-separated, e.g., pdo, pdo_mysql, mysqli, zip, gd)"
$phpExtensionsArray = $phpExtensions -split "," | ForEach-Object { $_.Trim() }

$dockerfileContent = @"
FROM php:$phpVersion-fpm
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
RUN apt-get update \ 
    && apt-get install -y \ 
        mc git \ 
        libzip-dev \ 
        zip \ 
        libfreetype6-dev libjpeg62-turbo-dev libpng-dev \
        strace \ 
        htop \ 
    && docker-php-ext-install $($phpExtensionsArray -join " ") \
    && docker-php-ext-enable $($phpExtensionsArray -join " ")

COPY docker.conf /usr/local/etc/php-fpm.d/docker.conf
COPY php.ini /usr/local/etc/php/php.ini

ENV TERM xterm-256color
"@

$customLogsConfig = @"
[global]
error_log = /var/www/logs/php_fpm_error.log

; https://github.com/docker-library/php/pull/725#issuecomment-443540114
log_limit = 8192

[www]
; php-fpm closes STDOUT on startup, so sending logs to /proc/self/fd/1 does not work.
; https://bugs.php.net/bug.php?id=73886
access.log = /var/www/logs/php_fpm_access.log

clear_env = no

; Ensure worker stdout and stderr are sent to the main error log.
catch_workers_output = yes
decorate_workers_output = no
"@

$customLogsConfig | Out-File -Encoding utf8 -FilePath "$phpDockerFilePath\docker.conf"

$dockerfileContent | Out-File -Encoding utf8 -FilePath "$phpDockerFilePath\Dockerfile"
Write-Host "PHP Dockerfile generated successfully." -ForegroundColor Green

