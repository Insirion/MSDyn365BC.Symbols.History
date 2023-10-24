# URL of the ZIP file
$DUrl = 'https://www.dropbox.com/scl/fi/lauimuqi98z4x8sbmbtke/Test.zip?rlkey=584z2ykj4yw6b7fl63ny1vdwu&dl=1'

try {
    # Send a HEAD request to get the Content-Length
    $response = Invoke-WebRequest -Uri $DUrl -Method Head
    $contentLength = [Int]($response.Headers['Content-Length'][0])

    # Calculate the range for the last 22 bytes (EOCD)
    $rangeStart = [math]::Max($contentLength - 22, 0)
    $rangeEnd = $contentLength - 1

    # Send a GET request with the "Range" header
    $headers = @{
        'Range' = "bytes=$($rangeStart)-$($rangeEnd)"
    }

    $response = Invoke-WebRequest -Uri $DUrl -Headers $headers

    # Extract and display the EOCD
    $eocdBytes = $response.RawContent

    
    if ($eocdSignature -eq 0x06054b50) {
        $eocdOffset = [BitConverter]::ToUInt32($eocdBytes, $eocdBytes.Length - 16)
        $eocdSize = $eocdBytes.Length - $eocdOffset

        # Convert the EOCD bytes to ASCII string
        $eocdData = [System.Text.Encoding]::ASCII.GetString($eocdBytes, $eocdOffset, $eocdSize)
        
        # Split the EOCD data into individual lines (file entries)
        $entries = $eocdData -split [System.Environment]::NewLine

        # Display the list of files in the ZIP archive
        foreach ($entry in $entries) {
            Write-Host $entry
        }
    } else {
        Write-Host "Invalid ZIP file (EOCD signature not found)."
    }
} catch {
    Write-Host "An error occurred: $_.Exception.Message"
}