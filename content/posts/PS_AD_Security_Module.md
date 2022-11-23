--- 
title: "PowerShell for Security: Get Important AD Answers from this module" 
date: 2021-04-25T08:23:11+01:00 
draft: true
comments: true

--- 
## Questions to AD Engineers

I started to work on a new module that I call [ADSEC](https://github.com/ehmiiz/PowerShell/tree/master/ADSEC).  
Its purpose is to answer the critical AD security related questions below:  

* Who can replicate secrets (password hashes) from an Active Directory domain?  
* Who can change security permissions on the AdminSDHolder object?  
* Who can change the membership of the Domain Admins security group?  
* Who can reset an Active Directory privileged user account's password?  
* Who can disable the use of Smartcards on an Active Directory user account?  

The module will contain 5 different cmdlets, and they will display the data needed to answer all of the above.

### Happy coding
