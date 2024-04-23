Remove-Item ~/Desktop/onprem -ErrorAction SilentlyContinue -Recurse
Remove-Item ~/Desktop/sandbox -ErrorAction SilentlyContinue -Recurse

$ErrorActionPreference = 'Stop'

Get-Module -ListAvailable UncommonSense.Zip.Utils | Import-Module -Force

Get-BCSymbols `
    -ArtifactUrl 'https://bcartifacts-exdbf9fwegejdqak.b02.azurefd.net/onprem/24.0.16410.18056/nl' `
    -Directory ~/Desktop/onprem `
    -Verbose

Get-BCSymbols `
    -ArtifactUrl 'https://bcartifacts-exdbf9fwegejdqak.b02.azurefd.net/sandbox/24.0.16410.18817/nl' `
    -Directory ~/Desktop/sandbox `
    -Verbose