# Version check
if (!([version]$PSVersionTable.PSVersion -ge [version]'7.4.0')) {
  Write-Warning "This script REQUIRES features enabled by Powershell v7.4 or later"
  Write-Host "Install Powershell v7 by running 'winget install Microsoft.Powershell' in your local powershell"
  Start-Sleep -Seconds 10
  throw "Powershell needs to be version 7.4 or greater to run this script"
}

$script:passwordLength = Read-Host -Prompt "Input Password Length (20-128 Characters)"
while (($script:passwordLength -match '[^0-9]')) {
  Write-Error "Input must be an integer"
  $script:passwordLength = Read-Host -Prompt "Input Password Length (20-128 Characters)"
}
$script:passwordLength = [int]$script:passwordLength
switch ($script:passwordLength) {
  { $_ -lt 20 } { Write-Host "Password length must be a minimum of 20 characters, setting password length to 20"; $script:passwordLength = 20 }
  { $_ -gt 128 } { Write-Host "Password length cannot exceed 128 characters to protect system resources, limitting length to 128"; $script:passwordLength = 128 }
}
[string[]]$script:charArray = @()
$script:charArray += ('a'..'z')
$script:charArray += ('A'..'Z')
$script:charArray += ('0'..'9')
$script:charArray += ('!', '@', '#', '$', '%', '^', '&', '*', '(', ')', '_', '-', '=', '+', '[', ']', '{', '}', '|', ':', ';', '<', '>', ',', '.', '?', '/', '~', '`')
$script:iteration = 0
function Get-ComplexPassword {
  $generatedPassword = -join ($script:charArray | Get-SecureRandom -Count $script:passwordLength)
  switch ($generatedPassword) {
    { ($_ -notmatch '[a-z]{3,}') -or ($_ -notmatch '[A-Z]{3,}') -or ($_ -notmatch '[0-9]{3,}') -or ($_ -notmatch '[-!@#$%^&*()_=+\[\]{}:;<>,\.?/~`|]{3,}') } {
      $script:iteration++
      Get-ComplexPassword
      return
    }
  }
  $script:iteration++
  Write-Output "Iteration $script:iteration"
  return $generatedPassword
}
Get-ComplexPassword