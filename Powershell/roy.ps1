
$zipFilePath = "D:\Code\Zips\fruit.zip" #Zip With Comment

$zipContent = Get-Content -Path $zipFilePath -Encoding Byte
$asciiContent = [System.Text.Encoding]::ASCII.GetString($zipContent)
Write-Host $asciiContent