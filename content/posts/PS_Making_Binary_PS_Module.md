--- 
title: "PowerShell: C Sharp for PowerShell Modules" 
date: 2022-08-15T14:58:11+01:00 
draft: false
comments: false

--- 

{{< figure
  src="/pics/stack_books.jpg"
>}}

## My journey into C# so far

I've always been somewhat interested in programming, and PowerShell scripting and module making has put fire to that interest.
The natural next language to learn for me has always been C#, reason being it's easy to pick up if you already know PowerShell and it enables you to create binary PowerShell modules.

Some content I've devoured to increase my C# knowledge are:

- C# Fundamentals course on PluralSight by Scott Allen
- PowerShell to C# And Back, Book by Deepak Dhami & Prateek Singh

Various YouTube content and talks on building PowerShell Binary Modules using C#:
- Building Cross Platform PowerShell Modules by Adam Driscoll
- Writing Compiled PowerShell Cmdlets by Thomas Rayner

The above lists are things I've went through and I can honestly recommend.



## What's to come

I plan to further increase my knowledge with the books:
- The C# Player's Guide, Book by RB Whitaker
- C# In Depth, Book by Jon Skeet

As well as writing more modules and other C# related projects.

## The process of wrapping a binary module using a nuget package

1. Install a modern version of the dotnet cli together with a dotnet sdk suitable for that version

2. Init an empty git repo for the new code to live in

3. Navigate to the folder; dotnet new classlib. This will generate a dotnet class library, once compiled it will generate a DLL file that will be our module 

4. In the csproj file, to make the module compatible with Win PowerShell & PowerShell, we set the TargetFramework to "netstandard2.0"

5. Remove ImplicitUsings and Nullable Enabled. These are language features we do not need

6. dotnet add package PowerShell Standard.Library

7. dotnet add package thenugetpackage

8. dotnet publish. We have now added the packages needed to start wrapping the nuget package into a PowerShell module

9. To follow the official PowerShell repos naming standard, all the cmdlets are to be named: VerbNounCommand.cs

The following source code is commented to help one with a PowerShell background to understand it easier:


```Csharp
// Usings, similar to Import-Module
using System;
using System.Management.Automation;
using PasswordGenerator;

namespace PasswordGenerator
{
    // VerbsCommon contains a list of approved common verbs, the string Password is the Noun of the cmdlet
    [Cmdlet(VerbsCommon.New,"Password")]
    // Cmdletname : PSCmdlet, similar to Function Name {}
    public class GetGeneratedPasswordCommand : PSCmdlet
    {
        // [Parameter], default value is 16. If Get > Default, if set > set the value of the param
        private int _pwLengthDefault = 16;
        [Parameter]
        [ValidateRange(4,128)]
        public Int32 Length
        {
            get
            {
                return _pwLengthDefault;
            }
            set
            {
                _pwLengthDefault = value;
            }
        }

        private int _amountDefault = 1;
        [Parameter]
        public Int32 Amount
        {
            get
            {
                return _amountDefault;
            }
            set
            {
                _amountDefault = value;
            }
        }

        // Switch parameters, they turn true if specified
        [Parameter]
        public SwitchParameter IncludeSpecial { get; set; }
        [Parameter]
        public SwitchParameter IncludeNumeric { get; set; }
        [Parameter]
        public SwitchParameter IncludeUppercase { get; set; }
        [Parameter]
        public SwitchParameter IncludeLowercase { get; set; }

        protected override void ProcessRecord()
        {
            // for loop, same concept as in PowerShell
            for (int i = 0; i < Amount; i++)
            {
                if (!IncludeLowercase & !IncludeUppercase & IncludeSpecial & IncludeNumeric)
                {
                    var pwd = new Password(Length).IncludeSpecial().IncludeNumeric();
                    var password = pwd.Next();
                    WriteObject(password); 
                }
                else if (IncludeNumeric & !IncludeSpecial & !IncludeUppercase & !IncludeLowercase)
                {
                    var pwd = new Password(Length).IncludeNumeric();
                    var password = pwd.Next();
                    WriteObject(password);
                }
                else if (IncludeSpecial & !IncludeNumeric & !IncludeUppercase & !IncludeLowercase)
                {
                    var pwd = new Password(Length).IncludeSpecial();
                    var password = pwd.Next();
                    WriteObject(password); 
                }
                else if (!IncludeNumeric & !IncludeSpecial & IncludeUppercase & IncludeLowercase)
                {
                    var pwd = new Password(Length).IncludeLowercase().IncludeUppercase();
                    var password = pwd.Next();
                    WriteObject(password);
                }
                else if (!IncludeNumeric & !IncludeSpecial & !IncludeLowercase & IncludeUppercase)
                {
                    var pwd = new Password(Length).IncludeUppercase();
                    var password = pwd.Next();
                    WriteObject(password);
                }
                else if (!IncludeNumeric & !IncludeSpecial & !IncludeUppercase & IncludeLowercase)
                {
                    var pwd = new Password(Length).IncludeLowercase();
                    var password = pwd.Next();
                    WriteObject(password);
                }
                else if (!IncludeNumeric & IncludeLowercase & IncludeUppercase & IncludeSpecial)
                {
                    var pwd = new Password(Length).IncludeLowercase().IncludeUppercase().IncludeSpecial();
                    var password = pwd.Next();
                    WriteObject(password);
                }
                else if (!IncludeNumeric & IncludeLowercase & IncludeUppercase & IncludeNumeric)
                {
                    var pwd = new Password(Length).IncludeLowercase().IncludeUppercase().IncludeNumeric();
                    var password = pwd.Next();
                    WriteObject(password);
                }
                else if (!IncludeNumeric & !IncludeUppercase & IncludeSpecial & IncludeLowercase)
                {
                    var pwd = new Password(Length).IncludeLowercase().IncludeSpecial();
                    var password = pwd.Next();
                    WriteObject(password);
                }
                else if (!IncludeSpecial & !IncludeUppercase & IncludeLowercase & IncludeNumeric)
                {
                    var pwd = new Password(Length).IncludeLowercase().IncludeNumeric();
                    var password = pwd.Next();
                    WriteObject(password);
                }
                else if (!IncludeLowercase & !IncludeNumeric & IncludeUppercase & IncludeSpecial)
                {
                    var pwd = new Password(Length).IncludeUppercase().IncludeSpecial();
                    var password = pwd.Next();
                    WriteObject(password);
                }
                else if (!IncludeLowercase & !IncludeSpecial & IncludeUppercase & IncludeNumeric)
                {
                    var pwd = new Password(Length).IncludeUppercase().IncludeNumeric();
                    var password = pwd.Next();
                    WriteObject(password); 
                }
                else if (!IncludeUppercase & IncludeLowercase & IncludeNumeric & IncludeSpecial)
                {
                    var pwd = new Password(Length).IncludeLowercase().IncludeSpecial().IncludeNumeric();
                    var password = pwd.Next();
                    WriteObject(password); 
                }
                else if (!IncludeLowercase & IncludeUppercase & IncludeNumeric & IncludeSpecial)
                {
                    var pwd = new Password(Length).IncludeUppercase().IncludeSpecial().IncludeNumeric();
                    var password = pwd.Next();
                    WriteObject(password); 
                }
                else
                {
                    var pwd = new Password(Length).IncludeLowercase().IncludeUppercase().IncludeSpecial().IncludeNumeric();
                    var password = pwd.Next();
                    WriteObject(password); 
                }
            }
            
        }

    }
}

```

The rest is a matter of figuring out how the package works, and what it supports.
Make sure to try to get all the functionality of the package out in the PowerShell module. Obviously it might require you to make more cmdlets.

Next blog will be how I published my module to the PowerShell Gallery. Using Git, Github, PSGallery and PlatyPS.

Stay tuned!



### Happy coding

### /Emil
