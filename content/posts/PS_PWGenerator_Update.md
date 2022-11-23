--- 
title: "PowerShell for Security: PassWord Gen Part 2" 
date: 2022-07-04T14:58:11+01:00 
draft: false
comments: false

--- 
## Did it again

2021-05-10 - [I wrote an article on Password Generators](https://blog.ehmiiz.tech/powershell-for-security-generate-a-x-platform-password-generator-using-powershell-7/).

The goal of that pass-gen was to have a script in my $Profile that would simply work on both PowerShell 5.1 & PowerShell 7+. The goal was also to cover AD complexity rules, and it did just that.

## However,

This time I've taken a whole new bull by the horn. While looking for a nuget package for password generators, out of curiosity on how a .net/C# developer would tackle the challenge that is coding a password generator, I stumbled upon "[PasswordGenerator](https://www.nuget.org/packages/PasswordGenerator/)".

To my surprise, the package has reached 1.6 million(!!!) downloads. I figured this package must be something special, some sort of holy grail of pass gens. And while I'm no C# expert, I'm always up for a challenge!

So I shamefully forked the repository and started working on a binary PowerShell cmdlet that would mimic the nuget package. 7 versions and 29 commits later, "[BinaryPasswordGenerator](https://www.powershellgallery.com/packages/BinaryPasswordGenerator/1.0.1)" was born!


### It's fast...

![Fast](/pics/FastPWGen.png)


### It's customizable

The cmdlet is highly customizable, just like the nuget package. This opens up a new usecase area that the former script did not cover:

- Backend engine for generating passwords, in GUI/Web senarios (like a nuget package)
- PIN/One Time Pass generations (usually 4-8 digit codes)
- More user-friendly passwords (example: lowercase + numeric)
- Supports up to 128 char length passwords
- It's wicked fast, meaning it scales better


### Examples


```powershell
# By default, all characters available for use and a length of 16

# Will return a random password with the default settings

New-Password
```

```powershell
# Same as above but you can set the length. Must be between 4 and 128

# Will return a password which is 32 characters long

New-Password -Length 32
```

```powershell
# Same as above but you can set the length. Must be between 4 and 128

# Will return a password which only contains lowercase and uppercase characters and is 21 characters long.

New-Password -IncludeLowercase -IncludeUppercase -Length 21
```


```powershell
# You can build up your reqirements by adding parameters, like -IncludeNumeric

# This will return a password which is just numbers and has a default length of 16

New-Password -IncludeNumeric
```

```powershell
# As above, here is how to get lower, upper and special characters using this approach

New-Password -IncludeLowercase -IncludeUppercase -IncludeSpecial
```

```powershell
# This is the same as the above, but with a length of 128

New-Password -IncludeLowercase -IncludeUppercase -IncludeSpecial -Length 128
```

```powershell
# One Time Passwords

# If you want to return a 4 digit number you can use this:

New-Password -IncludeNumeric -Length 4
```

### Using together with other PowerShell modules:


```powershell

# Convert to SecureString
$pw = New-Password | ConvertTo-SecureString -AsPlainText -Force

# Set a password in your SecretVault using Secret Store/Management
Set-Secret -Name 'User' -Secret (New-Password -Length 128) -Vault PSVault

Get-Secret User
System.Security.SecureString

Get-Secret User -AsPlainText
u%4EkQlMpVjPnO5VM5tYcnUE!F!D3wvhB8w595LXqIEAny1XC4OVn4\x!1Q79Nlj!QwK!zBVkFUAHVy44iEIO2icVE0meAz3YEWudP9UdKrjbrp8nJ8DECVll2Uq!kt5

```



### Happy coding

### /Emil
