param
(
    [Parameter(Mandatory)][string]$Country
)

$Version = Get-Content ./app.json | ConvertFrom-Json | Select-Object -ExpandProperty application 
$Version = ($Version -split '\.' )[0,1] -join "."

Write-Host $Country
Write-Host $Version

$ArtifactUrl = Get-BCArtifactUrl -Country $Country -Version $Version
Write-Host $ArtifactUrl
Get-BCSymbols -ArtifactUrl $ArtifactUrl -Directory  ./.alpackages