param
(
    [Parameter(Mandatory)][string]$Country,
    [Parameter(Mandatory)][string]$Version
)

$ArtifactUrl = Get-BCArtifactUrl -Country $Country -Version $Version
Get-BCSymbols -ArtifactUrl $ArtifactUrl -Directory .