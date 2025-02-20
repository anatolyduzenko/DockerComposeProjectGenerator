param(
    [string]$projectPath,
    [array]$selectedServicesArray
)

$dockerComposePath = "$projectPath\docker-compose.yml"

$dockerComposeContent = @"
version: '3.8'
services:
"@

if ($selectedServicesArray -contains "PHP") {
        $dockerComposeContent += @"
  php:
"@

if ($phpUseBuild -eq "yes") {
    $dockerComposeContent += @"

    build: ./${phpDockerFilePath}
"@    
} else {
    $dockerComposeContent += @"

    image: php:$phpVersion-fpm
"@    
}
$dockerComposeContent += @"

    container_name: php_container
    volumes:
      - ./${sourceDir}:/var/www/html
    environment:
      - PHP_EXTENSIONS=$phpServices"
"@
}

if ($selectedServicesArray -contains "Apache") {
    $dockerComposeContent += @"

  apache:
    image: httpd:latest
    container_name: apache_container
    restart: always
    ports:
      - "80:80"
    volumes:
      - ./${sourceDir}:/var/www/html"
"@
}

if ($selectedServicesArray -contains "Nginx" -and $selectedServicesArray -contains "PHP") {
    $dockerComposeContent += @"

  nginx:
    image: nginx:latest
    container_name: nginx_container
    restart: always
    ports:
      - "80:80"
    volumes:
      - ./${sourceDir}:/var/www/html
      - ./nginx.conf:/etc/nginx/nginx.conf"
"@
}

if ($selectedServicesArray -contains "MongoDB") {
    $dockerComposeContent += @"

  mongo:
    image: mongo:latest
    container_name: mongo_container
    restart: always
    ports:
      - "27017:27017"
    volumes:
      - mongo_data:/data/db"
"@
    }

if ($selectedServicesArray -contains "MySQL") {
    $dockerComposeContent += @"

  mysql:
    image: mysql:latest
    container_name: mysql_container
    restart: always
    environment:
      - MYSQL_ROOT_PASSWORD=root
    depends_on:
      - php
"@
    }

if ($selectedServicesArray -contains "MariaDB") {
    $dockerComposeContent += @"

  mariadb:
    image: mariadb:latest
    container_name: mariadb_container
    restart: always
    environment:
      - MYSQL_ROOT_PASSWORD=root
    depends_on:
      - php
"@
    }

if ($selectedServicesArray -contains "Adminer") {
    $dockerComposeContent += @"

  adminer:
    image: adminer
    container_name: adminer_container
    restart: always
    ports:
      - "8081:8080"
    depends_on:
      - mysql
      - mariadb"
"@
    }

if ($selectedServicesArray -contains "Node") {
    $dockerComposeContent += @"

  node:
    image: node:latest
    container_name: node_container
    restart: always
    working_dir: /app
    volumes:
      - ./${sourceDir}:/app
    command: "tail -f /dev/null"
"@
    }

if ($selectedServicesArray -contains "Redis") {
    $dockerComposeContent += @"

  redis:
    image: redis:latest
    container_name: redis_container
    restart: always
    ports:
      - "6379:6379"
    volumes:
      - redis_data:/data"
"@
    }

# Add volumes section
$dockerComposeContent += @"

volumes:
"@
if ($selectedServicesArray -contains "MongoDB") {
    $dockerComposeContent += "  mongo_data:\n"
}
if ($selectedServicesArray -contains "Redis") {
    $dockerComposeContent += "  redis_data:\n"
}

Write-host $dockerComposeContent

# $dockerComposeContent | Out-File -Encoding utf8 -FilePath $dockerComposePath
Write-Host "docker-compose.yml file generated successfully." -ForegroundColor Green
