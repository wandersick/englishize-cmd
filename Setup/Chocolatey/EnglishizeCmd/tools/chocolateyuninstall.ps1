﻿$ErrorActionPreference = 'Stop';
$packageArgs = @{
  packageName   = 'EnglishizeCmd'
  softwareName  = 'EnglishizeCmd*'
  fileType      = 'EXE'
  silentArgs    = "/programfiles /unattendAZ=1"
  validExitCodes= @(0)
}

$uninstalled = $false
[array]$key = Get-UninstallRegistryKey -SoftwareName $packageArgs['softwareName']

if ($key.Count -eq 1) {
  $key | % { 
    $packageArgs['file'] = "$($_.UninstallString)".Substring(0, $_.UninstallString.IndexOf(' /'))
    if ($packageArgs['fileType'] -eq 'MSI') {
      $packageArgs['silentArgs'] = "$($_.PSChildName) $($packageArgs['silentArgs'])"
      
      $packageArgs['file'] = ''
    }

    Uninstall-ChocolateyPackage @packageArgs
  }
} elseif ($key.Count -eq 0) {
  Write-Warning "$packageName has already been uninstalled by other means."
} elseif ($key.Count -gt 1) {
  Write-Warning "$($key.Count) matches found!"
  Write-Warning "To prevent accidental data loss, no programs will be uninstalled."
  Write-Warning "Please alert package maintainer the following keys were matched:"
  $key | % {Write-Warning "- $($_.DisplayName)"}
}
