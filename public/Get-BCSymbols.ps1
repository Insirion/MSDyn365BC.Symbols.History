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
    'Applications\system application\source\Microsoft_System Application.app',
    'manifest.json'

    Expand-FileFromZipArchive -Uri $ArtifactUrl -ZipEntryPath $AppFilePaths -Destination $Directory


    <#


"C:\bcartifacts.cache\sandbox\23.1.13431.14265\base\manifest.json" eruit halen.
		 Expand-FileFromZipArchive -uri https://bcartifacts.azureedge.net/sandbox/23.1.13431.14265/de -ZipEntryPath manifest.json -Destination .
		 {
			Applications\BaseApp\Source\Microsoft_Base Application.app
			Applications\Application\Source\Microsoft_Application.app
			Applications\system application\source\Microsoft_System Application.app"
		 }


		download  https://bcartifacts.azureedge.net/sandbox/$versie uit manifest/platform
				sandbox\23.1.13431.14265\platform\ModernDev\program files\Microsoft Dynamics NAV\230\AL Development Environment\System.app"


Powershell command maken met artifactUrl en directory.
En die downloadt de artifact + manifest.json En daaruit het platform
#>

}