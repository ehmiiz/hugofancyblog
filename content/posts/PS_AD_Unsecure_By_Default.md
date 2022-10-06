--- 

title: "PowerShell for Security: Continuous post of AD Weaknesses" 

date: 2022-10-05T08:23:11+01:00 

draft: false
comments: true

--- 
## Idea behind this post

Working with Active Directory for a living, you tend to pick up a thing or two about unsecure features, AD legacy "ideas" that does not make sense anymore, and the ever growing list of vulnerabilities being generated from the ADDS, ADCS & ADFS suite.

This post will serve as a way of remembering, learning and sharing with other AD admins about the things I've been working on in terms of defending Active Directory.

Each vulnerability section will consist of three parts:

- Problem
- Mitigation
- Script

This post is personal and ever changing. It's only purpose is to help others. Never run code from an untrusted source, always read the code and try it in a lab before running it in production.

## 0. Reason behind this post

### Problem:
A friend of mine was curious about AD security, and while out on lunch, I realized that what I've experianced over the past 7+ years working as an AD admin could not be covered over one lunch.

### Solution:
This blog will be the solution, I will simply share this post.

### Script:
```powershell
'url' | Set-Clipboard
```

## 1. Clear-text passwords in Sysvol (KB2962486)

### Problem:
Group policies are (partly) stored in the domain wide share named Sysvol.
Sysvol is a share that every domain user has read access to. A feature of group policy preferences (GPP), is the ability to store credentials in a policy, thus making use of the permissions of said account in an effective way.

The only problem is that the credentials are encrypted using a AES key, that's publically avalible [here.](https://learn.microsoft.com/en-us/openspecs/windows_protocols/ms-gppref/2c15cbf0-f086-4c74-8b70-1f2fa45dd4be?redirectedfrom=MSDN)
### Solution:
Patch your Domain Controllers so that admins cannot store credentials in sysvol: [MS14-025: Vulnerability in Group Policy Preferences could allow elevation of privilege](https://support.microsoft.com/en-us/topic/ms14-025-vulnerability-in-group-policy-preferences-could-allow-elevation-of-privilege-may-13-2014-60734e15-af79-26ca-ea53-8cd617073c30)

### Script:
This is a simple script that will match the cpassword row of the xml file, telling you what policy you need to fix:
```powershell
# Get domain
$DomainName = Get-ADDomain | Select-Object -ExpandProperty DNSRoot

# Build path
$DomainSYSVOLShareScan = "\\$domainname\SYSVOL\$domainname\Policies\"

# Check path recursivly for match
Get-ChildItem $DomainSYSVOLShareScan -Filter *.xml -Recurse | % {
    if (Select-String -Path $_.FullName -Pattern "Cpassword") {
        $_.FullName
    }
}
```
### Happy coding
