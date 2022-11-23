--- 
title: "PowerShell for Automation: Simple Hyper-V VM-Creation script" 
date: 2021-12-21T14:58:11+01:00 
draft: false
comments: false

--- 
## Meet [Labmil](https://github.com/ehmiiz/labmil).
Labmil is a script I made to serve a specific usecase. When [AutomatedLab](https://automatedlab.org/en/latest/) is overkill, and when you don't want to skip the installation phase of the lab.

![Displaying the cmdlet](https://i.imgur.com/uBIzjmx.png "Get-GeneratedPassword")

## Features
- Quickly put the Windows Server ISO-file to good use
- It's a simple script for anyone to modify for personal needs
- It outputs a customobject
- Create multiple VM's using PowerShell logic

## Non-Features
The script has a few non-features.
Non-Features are cool because it makes the script unique and useful in certain senarios.


- Not touching the VMs application layer makes it simple and less prone to error
- It only has two parameters, and only one of them is mandatory after initial run, adding simplicity
- It enables you as an sysadmin/engineer to do the whole set-up. Giving you more work to do yourself, meaning more labbing!
- It's only focus is Hyper-V VMs

## How I like to do my labs
1. Spin up the VMs you plan on labbing with using New-LabmilVM.ps1
2. Install the server with wanted settings and partitions
3. Use Windows Terminal's split-tab functionallity, together with 
```powershell
Enter-PSSession -VMName $Name
```
To have one tab open with each newly created Lab-VM.

Happy labbing!