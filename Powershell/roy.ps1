
$zipFilePath = "D:\Code\Zips\fruit.zip" #Zip With Comment

$zipContent = Get-Content -Path $zipFilePath -Encoding Byte
$asciiContent = [System.Text.Encoding]::ASCII.GetString($zipContent)
Write-Host $asciiContent



# demo code downloading a single DLL file from an online ZIP archive
# and extracting the DLL into memory to mount it finally to the main process.

cls
Remove-Variable * -ea 0

# definition for the ZIP archive, the file to be extracted and the checksum:
$url = 'https://github.com/sshnet/SSH.NET/releases/download/2020.0.1/SSH.NET-2020.0.1-bin.zip'
$url = 'https://bcartifacts.azureedge.net/onprem/19.4.35398.35482/de'
$sub = 'Applications/BaseApp/Source/Microsoft_Base Application.app'
$md5 = '5B1AF51340F333CD8A49376B13AFCF9C'

'prepare HTTP client:'
Add-Type -AssemblyName System.Net.Http
$handler = [System.Net.Http.HttpClientHandler]::new()
$client  = [System.Net.Http.HttpClient]::new($handler)

'get the length of the ZIP archive:'
# dont use System.Web.HttpRequest, it is frequently hanging:
$req = [System.Net.Http.HttpRequestMessage]::new('HEAD', $url)
$result = $client.SendAsync($req).Result
$zipLength = $result.Content.Headers.ContentLength
$zip = [byte[]]::new($zipLength)
$req.Dispose()

'get the last 10k:'
$start = $zipLength-10kb
$end   = $zipLength-1
$client.DefaultRequestHeaders.Add('Range', "bytes=$start-$end")
$result = $client.GetAsync($url).Result
$last10kb = $result.content.ReadAsByteArrayAsync().Result
$last10kb.CopyTo($zip, $start)

"get the 'End of CD' block:"
$enc = [System.Text.Encoding]::GetEncoding(28591)
$end = $enc.GetString($last10kb, $last10kb.Length-256, 256)
$eocd = [regex]::Match($end, 'PK\x05\x06.*').value
$eocd = $enc.GetBytes($eocd)

'get the central directory:'
$cdLength = [bitconverter]::ToUInt32($eocd, 12)
$cdStart  = [bitconverter]::ToUInt32($eocd, 16)
$cd = [byte[]]::new($cdLength)
[array]::Copy($zip, $cdStart, $cd, 0, $cdLength)

'search all file headers for correct file name:'
$fileHeaders = [regex]::Split($enc.GetString($cd),'PK\x01\x02')
foreach ($header in $fileHeaders) {
    $len = $header.Length
    if ($len -ge 42) {
        $bytes = $enc.GetBytes($header)
        $nameLength = [bitconverter]::ToUInt16($bytes, 24)
        if ($nameLength -eq $sub.length -and ($nameLength + 42) -le $len) { 
            $name = $header.Substring(42, $nameLength)
            if ($name -eq $sub) {
                $size   = [bitconverter]::ToUInt32($bytes, 16) + 256
                $start  = [bitconverter]::ToUInt32($bytes, 38)
                break
            }
        }
    }
}
if (!$start) {write-host 'we could not find file in the ZIP archive' -f y ;break}

'get the block containing the file:'
$end   = $start+$size
$client.DefaultRequestHeaders.Clear()
$client.DefaultRequestHeaders.Add('Range', "bytes=$start-$end")
$result = $client.GetAsync($url).Result
$block = $result.content.ReadAsByteArrayAsync().Result
$block.CopyTo($zip, $start)
$client.dispose()

'extract the DLL file from archive:'
Add-Type -AssemblyName System.IO.Compression
$stream = [System.IO.Memorystream]::new()
$stream.Write($zip,0,$zip.Length)
$archive = [System.IO.Compression.ZipArchive]::new($stream)
$entry = $archive.GetEntry($sub)
$bytes = [byte[]]::new($entry.Length)
[void]$entry.Open().Read($bytes, 0, $bytes.Length)

'check MD5:'
$prov = [Security.Cryptography.MD5CryptoServiceProvider]::new().ComputeHash($bytes)
$hash = [string]::Concat($prov.foreach{$_.ToString("x2")})
if ($hash -ne $md5) {write-host 'dll has wrong checksum.' -f y ;break}

'load the DLL:'
[void][System.Reflection.Assembly]::Load($bytes)

'use the single demo-call from the DLL:'
$test = [Renci.SshNet.NoneAuthenticationMethod]::new('test')
'done.'