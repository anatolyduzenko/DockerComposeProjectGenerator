# Scripts Setup Guide

## Overview
This setup script generates a `docker-compose.yml` file for configuring container services including Adminer, Apache/Nginx, MySQL, MariaDB, Redis, Node, and MongoDB using Docker.

## Features
- **Adminer**: Sets up an Adminer container with default configuration.
- **Apache**: Sets up an Apache container with default host configuration.
- **MySQL**: Sets up a MySQL container with default credentials.
- **MariaDB**: Configures a MariaDB container with user authentication.
- **MongoDB**: Initializes a MongoDB instance with root credentials.
- **Nginx**: Sets up a Nginx container with default host configuration.
- **PHP**: Sets up a PHP-FPM container with adjustable configuration.
- **Redis**: Sets up a Redis container with default credentials.
- **Persistent Storage**: Data volumes are mapped to avoid data loss.

## Requirements
- Docker installed on your system.
- PowerShell (for running the setup script).

## Installation & Usage
### Step 1: Run the Setup Script
Execute the PowerShell script to generate the database configuration:
```powershell
.\GenerateProject.ps1
```

### Step 2: Start Database Containers
Run the following command to start the database containers:
```sh
docker-compose -f docker-compose.yml up -d
```

### Step 3: Verify Running Containers
Check if the database containers are running using:
```sh
docker ps
```

## Configuration
You will be prompted for additional information.

## Troubleshooting
- If a container fails to start, check logs using:
  ```sh
  docker logs <container_name>
  ```
- Ensure that no other database services are running on the same ports.

## Nginx container
- Ensure that the generated nginx.conf file is saved without BOM. Otherwise the container won't start.

## License
MIT License
