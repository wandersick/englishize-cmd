
$ErrorActionPreference = 'Stop';
$toolsDir   = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
$fileLocation = Join-Path $toolsDir 'Setup.exe'
$url        = 'https://github.com/wandersick/englishize-cmd/releases/download/v2.0/EnglishizeCmd-2.0.0.0_Silent_Installer.exe'

$packageArgs = @{
  packageName   = 'EnglishizeCmd'
  unzipLocation = $toolsDir
  fileType      = 'exe'
  url           = $url
  file          = $fileLocation

  softwareName  = 'EnglishizeCmd*'

  checksum      = '5c9d603b7d89bfc5df4d6fd39b30b44e'
  checksumType  = 'md5'

  silentArgs    = "/programfiles /unattendaz=1"
  validExitCodes= @(0)
}

Install-ChocolateyPackage @packageArgs
