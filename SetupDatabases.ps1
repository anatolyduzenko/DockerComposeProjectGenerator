# PowerShell script to set up database services

param(
    [string]$projectPath,
    [array]$selectedServicesArray
)

$databaseComposeContent = @"

"@

if ($selectedServicesArray -contains "MySQL" -Or $selectedServicesArray -contains "MariaDB") {
    $MYSQL_DB = Read-Host "Enter MySQL database name?"
    $MYSQL_USER = Read-Host "Enter MySQL database user?"
    $MYSQL_PASSWORD = Read-Host "Enter MySQL database password?"

    $databaseComposeContent += "
MYSQL_DB=$MYSQL_DB
MYSQL_USER=$MYSQL_USER
MYSQL_PASSWORD=$MYSQL_PASSWORD

"

    $MysqlPath = "$projectPath\mysql"

    if (!(Test-Path -PathType Container $MysqlPath)) {
        New-Item -ItemType Directory -Path $MysqlPath
    }
}

if ($selectedServicesArray -contains "Mongo") {
    $MONGO_USER = Read-Host "Enter MongoDB database user?"
    $MONGO_PASSWORD = Read-Host "Enter MongoDB database password?"

    $databaseComposeContent += "

MONGO_USER=$MONGO_USER
MONGO_PASSWORD=$MONGO_PASSWORD

"

    $MongoPath = "$projectPath\mongo"

    if (!(Test-Path -PathType Container $MongoPath)) {
        New-Item -ItemType Directory -Path $MongoPath
    }
}

if ($selectedServicesArray -contains "Redis") {
    $REDIS_PASSWORD = Read-Host "Enter Redis password?"
    $databaseComposeContent += "

REDIS_PASSWORD=$REDIS_PASSWORD
"
}

$databaseComposeContent | Out-File -Encoding utf8 -FilePath "$projectPath/.env"
Write-Host ".env file generated successfully." -ForegroundColor Green

