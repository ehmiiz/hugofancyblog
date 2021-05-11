--- 

title: "PowerShell for Security: Generate a X-Platform Password Generator using Powershell 7" 

date: 2021-05-10T14:58:11+01:00 

draft: false
comments: true

--- 
## Creating a Password generator

Password generators can be very simple and fun to build, and I thought that publishing my own history with creating them can be a good source for knowledge for other scripters, hence this post :)

My first version of Get-GeneratedPassword was created in Powershell 3.0, and at that point I didn't have that many requirements, the usecase for the function was basically to stash it in my $profile to quickly set new passwords for various AD accounts.

 However the first version was based on a dotnet class method, Adam Bertram does a great job covering how to wrap this in a module: [[System.Web.Security.Membership]::GeneratePassword](https://adamtheautomator.com/random-password-generator/)

 The class does bring a dependency on the the specific dotnet class, and for me, this approach started to bring errors in Powershell cores early versions.

## Updated version

This is my attempt at creating my own password generator [Get-GeneratedPassword.ps1](https://github.com/ehmiiz/PowerShell/blob/master/Get-GeneratedPassword.ps1).  

### My Requirements was the following

* Cover AD Default complexity rules
* Useable in other scripts
* X-platform
* No dependencies outside of Powershell 7

### The base

The function starts of by enforcing some of the requirements using ValidateRange, and a default value for the `-Amount` parameter  
`[ValidateRange(6, 30)]
[int32]$PwLength`

Since AD's complexity rule is enforcing at least 6 chars, this range checks that requirement box.

`[int32]$Amount = 1`

The default value solves the issue of just running the cmdlet without the `-Amount` parameter

Next up is the whole idea behind the script, instead of using a dotnet class, or some other dependency, I'll just generate my own string of chars to pick from:

` $pwdvalues = "-!@#$%^&*_{}()?0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz" `

By using a [do-until loop](https://devblogs.microsoft.com/scripting/powershell-looping-understanding-and-using-dountil/), I can simply abuse Get-Random:  
` $PasswordGenerated = ($pwdvalues.tochararray() | Sort-Object { Get-Random })[1..$PwLength] -join '' `

 until my desired count of complex passwords are achieved by validating them through some regex validations:

`$PasswordGenerated -match "[-!@#$%^&*_{}()?]" -and`

` $PasswordGenerated -match "[A-Z]" -and `

` $PasswordGenerated -match "[a-z]" -and `

` $PasswordGenerated -match "[0-9]" `

This validation is critical for only getting the complex passwords for output

Since all we do here is randomly grabbing strings and joining them, we're only working with a string object. Making the script fast and the output very simple, and since the output is just a simple string, it can be easily turned into a .txt file or used within [ConvertTo-SecureString](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.security/convertto-securestring?view=powershell-7.1)

### Lastly

This is a quite simple and short function, and I'm sure it wont cover all my password generating needs for the future, but hopefully for some time at least.

I hope this post got you thinking about regex validation, do-while loops, and string manipulation in Powershell!

Feel free to visit my github to steal, fork or improve my pwd-gen yourself.

### Happy coding
