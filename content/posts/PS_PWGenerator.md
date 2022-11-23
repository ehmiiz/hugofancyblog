--- 
title: "PowerShell for Security: PassWord Gen Part 1" 
date: 2021-05-10T14:58:11+01:00 
draft: false
comments: false

--- 
## My history with Password Generators

Password generators can be very simple and fun to build, and I thought that publishing my own history with creating them can be a good source of knowledge for other people, hence this post :)

My first version of Get-GeneratedPassword was created in Powershell 3.0, and at that point I didn't have that many requirements, the usecase for the function was basically to stash it in my $profile to quickly set new passwords for various AD accounts.

 However the first version was based on a dotnet class method called: [[System.Web.Security.Membership]::GeneratePassword](https://adamtheautomator.com/random-password-generator/)

 Adam Bertram does a great job covering how to wrap this in a module, click the class name to read his post about it.

 The class does bring a dependency on the the specific dotnet class, and for me, this approach started to bring errors in Powershell cores early versions.

## New attempt without dependencies

This is my attempt at creating my own password generator
```powershell
function Get-GeneratedPassword {
<#
.SYNOPSIS
    Cross-platform password generator
.DESCRIPTION
    Get-GeneratedPassword is using a Get-Random, a string and regex 
    validation to ensure that the password meets the complexity level 
    enforced by default in ActiveDirectory
.EXAMPLE
    PS C:\> Get-GeneratedPassword -PwLength 10 -Amount 10
    Generates 10 passwords with the length set to 10
.EXAMPLE
    PS C:\> Get-GeneratedPassword -PwLength 12 | clip
    Only supported in Windows. Will generate a password with 12 as length 
    and clip the result to clipboard
.EXAMPLE
    PS C:\> $user = "emil"; $pw = ConvertTo-SecureString -String (Get-GeneratedPassword 12) -AsPlainText
    PS C:\> $creds = $user,$pw
    Creates a CredentialObject that can be passed in to user generating cmdlets
.EXAMPLE
    PS C:\> Get-GeneratedPassword -PwLength 8 -Amount 100 | Out-File C:\Temp\PW.txt
    Generates 100 passwords to a textfile stored in C:\Temp\PW.txt
.INPUTS
    PwLengt as int32
.OUTPUTS
    Outputs randomized password as string(s)
.NOTES
    Purpose :   Designed to meet AD Complexity rules & be crossplatform (Windows, Linux)
    Author  :   Emil.t.Larsson@gmail.com
    Date    :   2021-05-11
    OS      :   Win10, Ubuntu 20
    Version :   1.0.0
#>
    [CmdletBinding()]
    Param
    (
        
        [Parameter(Mandatory = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 0)]
        [ValidateRange(6, 30)]
        [int32]$PwLength,
        [Parameter(Mandatory = $false)]
        [int32]$Amount = 1
    )

    Begin {
        $Password = @()
    }
    Process {

        $PwdValues = "-!@#$%^&*_{}()?0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"

        do {

            $PasswordGenerated = ($PwdValues.ToCharArray() | Sort-Object { Get-Random })[1..$PwLength] -join ''

            # Regex rules, contains any of the special AND 0-9 AND upper/lower
            if (
                $PasswordGenerated -match "[-!@#$%^&*_{}()?]" -and 
                $PasswordGenerated -match "(?-i)[A-Z]" -and 
                $PasswordGenerated -match "(?-i)[a-z]" -and 
                $PasswordGenerated -match "[0-9]"
            ) {
                # Add to pw array
                $Password += $PasswordGenerated
            }
            else {
                Continue
            }
        }
        until ($Password.count -eq $Amount)
    }
    End {
        $Password
    }
}
```

The script can be found on my [GitHub PS repo](https://github.com/ehmiiz/PowerShell/blob/master/Get-GeneratedPassword.ps1)

![Displaying the cmdlet](https://i.imgur.com/fvwI0bb.png "Get-GeneratedPassword")

Read the comment based help, or load the function and run:

 `Get-Help Get-GeneratedPassword`

### My Requirements was the following

* Cover [AD complexity rules](https://docs.microsoft.com/en-us/windows/security/threat-protection/security-policy-settings/password-must-meet-complexity-requirements) (in 99,9%)
* String output, for simplicity
* X-platform
* No dependencies outside of Powershell 7

### Begin

The function starts of by enforcing some of the requirements using ValidateRange, and a default value for the `-Amount` parameter  
`[ValidateRange(6, 30)]
[int32]$PwLength`

Since AD's complexity rule is enforcing at least 6 chars, this range checks that requirement box.

`[int32]$Amount = 1`

The default value solves the issue of just running the cmdlet without the `-Amount` parameter

Next up is the whole idea behind the script, instead of using a dotnet class, I'll just generate my own string of chars to pick from:

` $pwdvalues = "-!@#$%^&*_{}()?0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz" `

By using a [do-until loop](https://devblogs.microsoft.com/scripting/powershell-looping-understanding-and-using-dountil/), I can simply abuse Get-Random:  
` $PasswordGenerated = ($pwdvalues.tochararray() | Sort-Object { Get-Random })[1..$PwLength] -join '' `

 until my desired count of complex passwords are achieved by validating them through some regex validations:

`$PasswordGenerated -match "[-!@#$%^&*_{}()?]" -and`

` $PasswordGenerated -match "(?-i)[A-Z]" -and `

` $PasswordGenerated -match "(?-i)[a-z]" -and `

` $PasswordGenerated -match "[0-9]" `

This validation is critical for only getting the complex passwords for output

The "(?-i)" part is needed since PowerShell by default is case-insensitive, this definition solves that part, and we need this since we really do care about the match being case-sensitive. [This blog post by Jake Bolton](https://ninmonkeys.com/blog/2020/11/21/using-case-sensitive-regular-expressions-in-powershell-tips/) covers the problem in detail.

Since all we do here is randomly grabbing strings and joining them, we're only working with a string object. Making the script fast and the output very simple, and since the output is just a simple string, it can be easily turned into a .txt file or used within [ConvertTo-SecureString](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.security/convertto-securestring?view=powershell-7.1)

### Lastly

This is a quite simple and short function, and I'm sure it wont cover all my password generating needs for the future, but hopefully for some time at least.

I hope this post got you thinking & curious about:

* regex validation
* do-while loops
* string manipulation
* case sensitivity
* self-made functions

 in Powershell!


### Happy coding

### /Emil
