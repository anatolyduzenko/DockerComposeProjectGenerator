param(
    [string]$projectPath
)

. "$PSScriptRoot\GenerateNginxDockerfile.ps1" $projectPath
. "$PSScriptRoot\GenerateNginxConfig.ps1" $projectPath
