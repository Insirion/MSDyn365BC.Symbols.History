Get-Module -ListAvailable UncommonSense.Zip.Utils | Import-Module -Force

Get-BCSymbols `
    -ArtifactUrl https://bcartifacts.azureedge.net/onprem/23.2.14098.14562/nl `
    -Directory ~/Desktop/onprem `
    -Verbose

Get-BCSymbols `
    -ArtifactUrl https://bcartifacts.azureedge.net/sandbox/23.2.14098.15193/nl `
    -Directory ~/Desktop/sandbox `
    -Verbose