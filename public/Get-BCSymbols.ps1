<#
.EXAMPLE
Get-BCSymbols -ArtifactUrl https://bcartifacts.azureedge.net/sandbox/23.2.14098.14594/nl -Directory ~/Desktop
#>
function Get-BCSymbols
{
    param
    (
        [Parameter(Mandatory)]
        [string]$ArtifactUrl,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$Directory = '.'
    )

    $AppFilePatterns =
    'Applications*Microsoft_Base Application*.app',
    'Applications*Microsoft_Application*.app',
    'Applications*Microsoft_System Application*.app'

    Write-Verbose 'Finding apps files in artifact'
    $FilesInArtifact = Expand-FileFromZipArchive -Uri $ArtifactUrl -ListOnly | Select-Object -ExpandProperty FileName
    $AppFilePaths = $AppFilePatterns | ForEach-Object { $FilesInArtifact -like $_ }
    $AppFilePaths = $AppFilePaths -notlike '*Test*'
    Write-Verbose "Found $($AppFilePaths -join ', ')"

    Write-Verbose 'Download and Extract Base Application, Application and System Application apps'
    Expand-FileFromZipArchive -Uri $ArtifactUrl -ZipEntryPath $AppFilePaths -Destination $Directory -NoContainer

    $TempPath = [System.IO.Path]::GetTempPath()
    Write-Verbose "Using $TempPath as temporary file path"

    $ManifestFilePath = Join-Path -Path $TempPath -ChildPath manifest.json
    Write-Verbose "Using manifest $ManifestFilePath"

    if (Test-Path -Path $ManifestFilePath) { Remove-Item -Path $ManifestFilePath -Force }

    Write-Verbose "Extract manifest.json from $ArtifactUrl"
    Expand-FileFromZipArchive -Uri $ArtifactUrl -ZipEntryPath manifest.json -Destination $TempPath

    $Manifest = Get-Content -Path $ManifestFilePath | ConvertFrom-Json
    $Version = $Manifest | Select-Object -ExpandProperty Version
    $Target = $Manifest.isBcSandbox ? 'sandbox' : 'onprem'
    Write-Verbose "Using platform $Version"
    Write-Verbose "Target is $Target"

    $PlatformUrl = "https://bcartifacts-exdbf9fwegejdqak.b02.azurefd.net/$Target/$Version/platform"
    Write-Verbose "Using platform url $PlatformUrl"

    $AppFilePatterns = 'ModernDev\program files\Microsoft Dynamics NAV\*\AL Development Environment\System.app'

    Write-Verbose 'Finding apps files in artifact'
    $FilesInArtifact = Expand-FileFromZipArchive -Uri $PlatformUrl -ListOnly | Select-Object -ExpandProperty FileName
    $AppFilePaths = $AppFilePatterns | ForEach-Object { $FilesInArtifact -like $_ }
    $AppFilePaths = $AppFilePaths -notlike '*Test*'
    Write-Verbose "Found $($AppFilePaths -join ', ')"

    Write-Verbose 'Download and Extract Base Application, Application and System Application apps'
    Expand-FileFromZipArchive -Uri $PlatformUrl -ZipEntryPath $AppFilePaths -Destination $Directory -NoContainer -CentralDirSize 20mb
}