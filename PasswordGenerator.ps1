# Version check
if ([version]$PSVersionTable.PSVersion -lt [version]'7.4.0') {
  Write-Warning "This script REQUIRES features enabled by Powershell v7.4 or later"
  Write-Host "Install Powershell v7 by running 'winget install Microsoft.Powershell' in your local powershell"
  Start-Sleep -Seconds 10
  throw "Powershell needs to be version 7.4 or greater to run this script"
}

$userInput = { Write-Host "Input Password Length (20-128 Characters): " -ForegroundColor DarkCyan -BackgroundColor Black -NoNewline; $script:passwordLength = Read-Host }
& $userInput
while (($script:passwordLength -match '[^0-9]')) {
  Write-Error "Input must be an integer"
  & $userInput
}
$script:passwordLength = [int]$script:passwordLength
switch ($script:passwordLength) {
  { $_ -lt 20 } { Write-Warning "Password length must be a minimum of 20 characters, setting password length to 20"; $script:passwordLength = 20 }
  { $_ -gt 128 } { Write-Warning "Password length cannot exceed 128 characters to protect system resources, limitting length to 128"; $script:passwordLength = 128 }
}

function Get-ComplexPassword {
  param(
    [Parameter(Mandatory)]
    [ValidateScript(
      { (($_ -is [int]) -and ($_ -le 128) -and ($_ -ge 20)) }
    )]
    [int]$passwordLength
  )

  [string[]]$charArray = @()
  $charArray += ('a'..'z')
  $charArray += ('A'..'Z')
  $charArray += ('0'..'9')
  $charArray += ('!', '@', '#', '$', '%', '^', '&', '*', '(', ')', '_', '-', '=', '+', '[', ']', '{', '}', '|', ':', ';', '<', '>', ',', '.', '?', '/', '~', '`')
  $iteration = 0
  
  do {
    $generatedPassword = -join ($charArray | Get-SecureRandom -Count $passwordLength)
    $iteration++
  } while (
    ($generatedPassword -notmatch '[a-z]{3,}') -or 
    ($generatedPassword -notmatch '[A-Z]{3,}') -or 
    ($generatedPassword -notmatch '[0-9]{3,}') -or 
    ($generatedPassword -notmatch '[-!@#$%^&*()_=+\[\]{}:;<>,\.?/~`|]{3,}')
  )
  Write-Host "Generation attempts to achieve mandated complexity: $iteration" -ForegroundColor Magenta -BackgroundColor Black
  Write-Host "Password: " -ForegroundColor DarkGreen -BackgroundColor Black -NoNewline
  Write-Host "$generatedPassword"
}
Get-ComplexPassword -passwordLength $script:passwordLength