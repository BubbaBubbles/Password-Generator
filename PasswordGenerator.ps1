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
    { $_ -lt 20 } { Write-Warning "Password length must be a minimum of 20 characters, setting password length to 32"; $script:passwordLength = 32 }
    { $_ -gt 128 } { Write-Warning "Password length cannot exceed 128 characters to protect system resources, limitting length to 128"; $script:passwordLength = 128 }
}

[int]$complexity = 4
if ($complexity * 4 -gt $passwordLength) {
    throw "Complexity requirements exceed password length"
}

function Get-ComplexPassword {
    param(
        [Parameter(Mandatory)]
        [ValidateScript(
            { (($_ -is [int]) -and ($_ -le 128) -and ($_ -ge 20)) }
        )]
        [int]$passwordLength,
        [int]$complexity
    )

    $charArray = @(
        (0x61..0x7A) # a-z
        (0x41..0x5A) # A-Z
        (0x30..0x39) # 0-9
        [int[]][char[]]'!@#$%^&*()_=+[]{}:;<>,.?/~`-'
    ) | ForEach-Object { [char]$_ }
    $iteration = 0
  
    do {
        $passContainer = New-Object System.Object[] $passwordLength
        for ($i = 0; $i -lt $passwordLength; ++$i) {
            $passContainer[$i] = $charArray | Get-SecureRandom
        }
        $generatedPassword = [string]::new($passContainer)
        $iteration++
    } until (
        (($generatedPassword -creplace '[^a-z]').Length -ge $complexity) -and
        (($generatedPassword -creplace '[^A-Z]').Length -ge $complexity) -and
        (($generatedPassword -creplace '[^0-9]').Length -ge $complexity) -and
        (($generatedPassword -creplace '[^!@#$%^&*()_=+\[\]{}:;<>,\.?/~`|-]').Length -ge $complexity) -and $true
    )
    Write-Host "Generation attempts to achieve mandated complexity: $iteration" -ForegroundColor Magenta -BackgroundColor Black
    Write-Host "Password: " -ForegroundColor DarkGreen -BackgroundColor Black -NoNewline
    Write-Host "$generatedPassword"
}
Get-ComplexPassword -passwordLength $script:passwordLength -complexity $complexity