$Public = @( Get-ChildItem -Path $PSScriptRoot\Public\*.ps1 -ErrorAction SilentlyContinue )
$Private = @( Get-ChildItem -Path $PSScriptRoot\Private\*.ps1 -ErrorAction SilentlyContinue )

Foreach ($Import in @($Private + $Public))
{
  Try
  {
    . $Import.FullName
  }
  Catch
  {
    Write-Error -Message "Failed to import function $($Import.FullName): $_"
  }
}