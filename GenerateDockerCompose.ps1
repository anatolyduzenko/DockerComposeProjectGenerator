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

    build: ./docker/php
"@    
} else {
    $dockerComposeContent += @"

    image: php:$phpVersion-fpm
"@    
}
$dockerComposeContent += @"

    # container_name: php_container
    volumes:
      - ./${sourceDir}:/var/www/html
      - ./logs:/var/www/logs
    
"@
}

if ($selectedServicesArray -contains "Apache") {
    $dockerComposeContent += @"

  apache:
    image: httpd:latest
    # container_name: apache_container
    # restart: always
    ports:
      - 80:80
    volumes:
      - ./${sourceDir}:/var/www/html
      - ./logs:/var/www/logs
"@
}

if ($selectedServicesArray -contains "Nginx") {
    $dockerComposeContent += @"

  nginx:
    build: ./docker/nginx
    # container_name: nginx_container
    # restart: always
    ports:
      - 80:80
    volumes:
      - ./${sourceDir}:/var/www/html
      # - ./nginx.conf:/etc/nginx/nginx.conf
      - ./logs:/var/www/logs
"@

    if ($selectedServicesArray -contains "PHP" -Or $selectedServicesArray -contains "Node" -Or $selectedServicesArray -contains "MariaDB" -Or $selectedServicesArray -contains "Mysql") {
        $dockerComposeContent += @"

    links:
"@
        if ($selectedServicesArray -contains "PHP") {
            $dockerComposeContent += @"

      - php
"@

        }
        
        if ($selectedServicesArray -contains "Node") {
            $dockerComposeContent += @"

      - node
"@

        }
        if ($selectedServicesArray -contains "MariaDB") {
            $dockerComposeContent += @"

      - mariadb
"@
        }
        if ($selectedServicesArray -contains "Mysql") {
            $dockerComposeContent += @"

      - mysql
"@

        }
    }
}

if ($selectedServicesArray -contains "MongoDB") {
    $dockerComposeContent += @"

  mongo:
    image: mongo:latest
    # container_name: mongo_container
    restart: always
    environment:
      - MONGODB_INITDB_ROOT_USERNAME=`$MONGO_USER
      - MONGODB_INITDB_ROOT_PASSWORD=`$MONGO_PASSWORD
    ports:
      - 27017:27017
    volumes:
      - mongo_data:/mongo"
"@
    }

if ($selectedServicesArray -contains "MySQL") {
    $dockerComposeContent += @"

  mysql:
    image: mysql:latest
    # container_name: mysql_container
    # restart: always
    volumes:
        - ./mysql:/var/lib/mysql
    environment:
      MYSQL_ROOT_PASSWORD: 'root'
      MYSQL_DATABASE: `$MYSQL_DB
      MYSQL_USER: `$MYSQL_USER
      MYSQL_PASSWORD: `$MYSQL_PASSWORD
    depends_on:
      - php
    command: --default-authentication-plugin=mysql_native_password --skip-ssl --sha256-password-auto-generate-rsa-keys=OFF --caching-sha2-password-auto-generate-rsa-keys=OFF
"@
    }

if ($selectedServicesArray -contains "MariaDB") {
    $dockerComposeContent += @"

  mariadb:
    image: mariadb:latest
    # container_name: mariadb_container
    # restart: always
    volumes:
        - ./mysql:/var/lib/mysql
    environment:
      MYSQL_ROOT_PASSWORD: 'root'
      MYSQL_DATABASE: `$MYSQL_DB
      MYSQL_USER: `$MYSQL_USER
      MYSQL_PASSWORD: `$MYSQL_PASSWORD
    depends_on:
      - php
    # command: --default-authentication-plugin=mysql_native_password --skip-ssl --sha256-password-auto-generate-rsa-keys=OFF --caching-sha2-password-auto-generate-rsa-keys=OFF
"@
    }

if ($selectedServicesArray -contains "Adminer") {
    $dockerComposeContent += @"

  adminer:
    image: adminer
    # container_name: adminer_container
    # restart: always
    ports:
      - 8081:8080
    depends_on:
"@
    if ($selectedServicesArray -contains "Mysql") {
        $dockerComposeContent += @"

      - mysql
"@
    }
    if ($selectedServicesArray -contains "MariaDB") {
        $dockerComposeContent += @"

      - mariadb
"@
    }
}

if ($selectedServicesArray -contains "Node") {
    $dockerComposeContent += @"

  node:
    image: node:latest
    # container_name: node_container
    # restart: always
    working_dir: /app
    ports:
      - 5173:5173
    volumes:
      - ./${sourceDir}:/app
    command: "tail -f /dev/null"
"@
    }

if ($selectedServicesArray -contains "Redis") {
    $dockerComposeContent += @"

  redis:
    image: redis:latest
    # container_name: redis_container
    # restart: always
    environment:
      - REDIS_PASSWORD=`$REDIS_PASSWORD
      - REDIS_PORT=6379
      - REDIS_DATABASES=16
    ports:
      - 6379:6379
    volumes:
      - redis_data:/redis
"@
    }

# Add volumes section
$dockerComposeContent += @"

volumes:
"@
if ($selectedServicesArray -contains "MongoDB") {
    $dockerComposeContent += "  
  mongo_data:
"
}
if ($selectedServicesArray -contains "Redis") {
    $dockerComposeContent += "
  redis_data:
"
}

$dockerComposeContent | Out-File -Encoding utf8 -FilePath $dockerComposePath
Write-Host "docker-compose.yml file generated successfully." -ForegroundColor Green
