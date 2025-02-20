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
        strace \ 
        htop \ 
    && docker-php-ext-install $($phpExtensionsArray -join " ") \
    && docker-php-ext-enable $($phpExtensionsArray -join " ")

COPY docker.conf /usr/local/etc/php-fpm.d/docker.conf
COPY php.ini /usr/local/etc/php/php.ini

ENV TERM xterm-256color
"@

$dockerfileContent | Out-File -Encoding utf8 -FilePath "$phpDockerFilePath\Dockerfile"
Write-Host "PHP Dockerfile generated successfully." -ForegroundColor Green
