--- 
title: "PowerShell Solution: Script not digitally signed" 
date: 2021-02-11T08:23:11+01:00 
draft: false
comments: true

--- 

## “.ps1 is not digitally signed. The script will not execute on the system.” 

This error is clearly not really a typical error, but can be a blocker, nonetheless. It's more of a security feature than an error. 

  

Simple solution if you're running this script from another service, or as an Azure Runbook, before executing the Invoke-Command:   

`Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass` 

  

This will allow the powershell session process itself to bypass the Exec policy, and after termination the next powershell process has the default user or system policy. 

  

Another solution would be if you're executing the script from your own user:   

`Set-ExecutionPolicy RemoteSigned`

Further documentation regarding Set-ExecutionPolicy may be found [here](https://docs.microsoft.com/en-us/previous-versions/windows/it-pro/windows-powershell-1.0/ee176961(v=technet.10)?redirectedfrom=MSDN). 

Original blogpost that helped me solve this issue was found here: [here](https://caiomsouza.medium.com/). 
  
##  Happy coding