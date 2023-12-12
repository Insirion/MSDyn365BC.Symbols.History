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

    $AppFilePaths =
    'Applications\BaseApp\Source\Microsoft_Base Application.app',
    'Applications\Application\Source\Microsoft_Application.app',
    'Applications\system application\source\Microsoft_System Application.app'

    Write-Verbose 'Download and Extract Base Application, Application and System Application apps'
    Expand-FileFromZipArchive -Uri $ArtifactUrl -ZipEntryPath $AppFilePaths -Destination $Directory

    $TempPath =  [System.IO.Path]::GetTempPath()
    Write-Verbose "Using $TempPath as temporary file path"

    $ManifestFileName = Join-Path -Path $TempPath -ChildPath manifest.json
    Write-Verbose "Using manifest $ManifestFileName"

    if (Test-Path -Path $ManifestFileName) { Remove-Item -Path $ManifestFileName -Force }

    Write-Verbose "Extract manifest.json from $ArtifactUrl"
    Expand-FileFromZipArchive -Uri $ArtifactUrl -ZipEntryPath manifest.json -Destination $TempPath

    $Platform = Get-Content -Path $ManifestFileName | ConvertFrom-Json | Select-Object -ExpandProperty platform
    Invoke-WebRequest -Uri https://bcartifacts.azureedge.net/sandbox/$Platform -OutFile (Join-Path -Path $Directory -ChildPath dummy)
    # Expand-FileFromZipArchive -Uri https://bcartifacts.azureedge.net/sandbox/$Platform




    <#
		download  https://bcartifacts.azureedge.net/sandbox/$versie uit manifest/platform
				sandbox\23.1.13431.14265\platform\ModernDev\program files\Microsoft Dynamics NAV\230\AL Development Environment\System.app"
    #>

}