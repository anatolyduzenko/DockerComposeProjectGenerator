param(
    [string]$projectPath
)

$phpVersion = Read-Host "Enter PHP version (e.g., 8.1, 8.2)"
$phpUseBuild = Read-Host "Should PHP container be built (yes/no)?"

if ($phpUseBuild -eq "yes") {
    . "$PSScriptRoot\GeneratePHPDockerfile.ps1" $projectPath $phpVersion

    $phpIniConfiguration = Read-Host "Configure PHP.ini (yes/no)?"
    if ($phpIniConfiguration -eq "yes") {
        . "$PSScriptRoot\GeneratePHPINIfile.ps1" $projectPath 
    }

} else {
    $phpServices = Read-Host "Enter additional services for PHP (comma-separated, e.g., pdo_mysql, mbstring)"
}
