---
title: "PowerShell Solution: AGPM unable to take control of a GPO"
date: 2022-09-08T14:56:09+02:00
draft: false
---

{{< figure
  src="/pics/oldkeyboard.jpg"
>}}

## Problem

If you enjoy the principle of least privileges, version control and doing big infrastructural changes in a safe manner, [Advanced Group Policy Management](https://docs.microsoft.com/en-us/microsoft-desktop-optimization-pack/agpm/) or AGPM, is an amazing tool.

AGPM itself has a few years on its back, and as we sysadmins tend to get easier and easier systems now days, legacy systems can mean complexity.

When combined with new sysadmins that has not been introduced to the concept of AGPM, uncontrolled GPOs might become a problem and the built in error messages are sadly not the greatest.


```text
(GPMC Error) could not take the ownership of the production GPO. Access is denied. (Exceptions from HRESULT : 0x80070005 (E_ACCESSDENIED)).
```
{{< figure
  src="/pics/error_code_meme.jpg"
>}}


Access denied is caused by the AGPM service-account not having the permission to take control of the GPO (not having control of a GPO in AGPM really does ruin the point of AGPM). Solving this problem involves giving the service-account the permissions needed, however it's a bit of a tricky thing to do.


## Solution

As we've established, we must add the correct permissions for the service-account to the GPO, easy right?
Luckily yes, because we know PowerShell!

{{< figure
  src="/pics/PowerShellHero.jpg"
>}}


To add the permissions, we need to understand how a GPO is stored. There's two places a GPOs data resides in, ActiveDirectory (GPC) & Sysvol (GPT).

### GPC

Group Policy Container (GPC), luckily the name is easy to remember because we already understand that AD consists of Organizational Units and... Containers.
The GPC is stored in AD, under "CN=,Policies,CN=System,DC=x,DC=x". Since it's an AD object, logically it has attributes describing the object version etc.

### GPT

Group Policy Template (GPT), is stored in the DC's system volume (sysvol), under the 'policies' subfolder.

The GPT stores the majority of GPO data, it contains a folder structure of files that describes the GPOs functionality, meaning it stores script files, administrative template-based policies and various other security settings.

### Replication

GPC uses AD replication, and GPT uses DFS-R since its in sysvol. This is important because we will edit the ACLs of both AD and sysvol in order to solve our issue.


### Editing ACL for GPC

Editing its ACL requires generating an ActiveDirectoryRights object with the desired access. This can be done multiple ways, [dsacls](https://docs.microsoft.com/en-us/previous-versions/windows/it-pro/windows-server-2012-R2-and-2012/cc771151(v=ws.11)), using [Set-ACL](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.security/set-acl?view=powershell-7.2) to name a few. In this case I had heard of an amazing module from [Simon Wahlin](https://twitter.com/SimonWahlin) called [DSACL](https://www.powershellgallery.com/packages/DSACL/1.0.0), so I can simply do the following:
```powershell
$ADRights = "CreateChild", "DeleteChild", "Self", "WriteProperty", "DeleteTree", "Delete", "GenericRead", "WriteDacl", "WriteOwner", "AccessSystemSecurity"
```

```powershell
Add-DSACLCustom -TargetDN $GPODN -DelegateDN $DelegateDN -ActiveDirectoryRights $ADRights  -InheritanceType Descendents -AccessControlType Allow

Add-DSACLCustom -TargetDN $GPODN -DelegateDN $DelegateDN -ActiveDirectoryRights $ADRights[0..8] -InheritanceType None -AccessControlType Allow
```

The 'TargetDN' in this case will be the GPCs distinguishedName, and the DelegateDN will be the distinguishedName of our AGPM service-account.
We run the cmdlet twice to mimic the way AGPM edits the ACL in a controlled GPO. AccessSystemSecurity was not needed in the 2nd ACE and therefore I ended up selecting the first 9 (0..8) ADRights.

### Editing the ACL for GPT

Since GPT is in sysvol, we now have the task of editing a filesystem ACL. This is different from a directory service ACL. There's many ways of doing this as well, [cacls](https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/cacls), and [Set-ACL](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.security/set-acl?view=powershell-7.2) works great. I ended up taking the easy way out and used [NTFSSecurity](https://www.powershellgallery.com/packages/NTFSSecurity/4.2.6), again another killer PowerShell module with 1,1mil downloads as of writing. And that's quite understandable considering this is how one can grant full control on a filesystem:

```powershell
Add-NTFSAccess -Path "\\DOMAIN\SYSVOL\DOMAIN.TEST\Policies\{$($GPOObject.Id)}" -AccessRights FullControl -Account 'DOMAIN\Service-Account-AGPM'
```

### Almost ready to solve!

As we have learned, GPC and GPT is a bit different. Sysvol and AD does replicate, but in different ways. Key take-away is that most likely we need to wait for replication in order for the AGPM server to understand that the rights are in fact in place. This took me around 15m, this could have been avoided had I done the changes on the same server.

Using the [AGPM module](https://docs.microsoft.com/en-us/powershell/module/agpm/add-controlledgpo?view=win-mdop2-ps), we're now ready to take control of the GPO, since we now have the access to do so.
```powershell
Get-Gpo -Name "TheUncontrolledGPO" | Add-ControlledGpo -PassThru
```

In my case, I had more then 1 uncontrolled GPO, to say the least.
Sadly the AGPM module doesn't have something like 'Get-UncontrolledGPO'.

What I ended up doing was to filter out all uncontrolled GPOs myself using Compare-Object, .

```powershell
$ControlledGPOS = Get-ControlledGpo
$UncontrolledGPOS = (Compare-Object $ControlledGPOS.Name (Get-GPO -All).DisplayName).InputObject

foreach ($GPO in $UncontrolledGPOS) {
    Get-Gpo -Name $GPO | Add-ControlledGpo -PassThru
}
```

You can of course also navigate within GPMC > ChangeControl > Uncontrolled > select all GPOs, rightclick, Control.



Congratulations on having a fully controlled AGPM environment.

## Discussion

Understanding where a GPO is stored is a nice way of understanding how they work. The reason behind having them stored in separate places most likely goes back to fact that AD is old, and back in the days, size mattered.
Having the GPT files in the AD database (.dit) would simply mean a huge increase in data for AD. Splitting things up and having the DCs taking a bit of storage was probably a good idea back then. 

On another note, notice my code in this solution was quite simple. Even thought we did some complex tasks. I was actively not trying to re-invent the wheel, and this is something that gets more important the 'harder' the task becomes. Using "blackbox" modules where we only follow the PowerShell standard way of typing out a cmdlet, can be a great way of achieving complex tasks with speed.
It's also important that when a "blackbox" module solves something for you, go back and try to dig deeper in what it actually did. I find this a good way of learning things in general.

### Happy coding

### /Emil
