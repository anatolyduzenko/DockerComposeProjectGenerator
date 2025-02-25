param(
    [string]$projectPath
)

# Predefined services
$services = @("Adminer", "Apache", "MariaDB", "PHP", "MongoDB", "MySQL", "Nginx", "Node", "Redis")

# Display service options to user
Write-Host "Available services (select by entering numbers separated by commas):"
$i = 1
$serviceSelection = @{}
foreach ($service in $services) {
    Write-Host "$i. $service"
    $serviceSelection[$i] = $service
    $i++
}

# Prompt user for selected services
$selectedIndexes = Read-Host "Enter the numbers of the services you want to include (comma-separated)"
$selectedIndexesArray = $selectedIndexes -split "," | ForEach-Object { $_.Trim() }

$selectedServicesArray = @()
foreach ($index in $selectedIndexesArray) {
    if ($serviceSelection.ContainsKey([int]$index)) {
        $selectedServicesArray += $serviceSelection[[int]$index]
    }
}

# Handle PHP setup
if ($selectedServicesArray -contains "PHP") {
    . "$PSScriptRoot\SetupPHP.ps1" $projectPath
}

# Handle Web Server Setup
if ($selectedServicesArray -contains "Apache") {
    . "$PSScriptRoot\SetupApache.ps1" $projectPath
}

if ($selectedServicesArray -contains "Nginx") {
    . "$PSScriptRoot\SetupNginx.ps1" $projectPath
}

# Handle Database Setup
if ($selectedServicesArray -contains "MySQL" -or $selectedServicesArray -contains "MariaDB" -or $selectedServicesArray -contains "MongoDB") {
    . "$PSScriptRoot\SetupDatabases.ps1" $projectPath $selectedServicesArray
}

# Generate docker-compose file
. "$PSScriptRoot\GenerateDockerCompose.ps1" $projectPath $selectedServicesArray $phpServices
