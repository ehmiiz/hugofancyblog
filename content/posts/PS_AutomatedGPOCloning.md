---
title: "PowerShell Solution: Automate GPO creations"
date: 2021-05-12T14:56:09+02:00
draft: false
---

## The headache of setting up recurring GPO's

I was faced with an issue not too long ago, and I spent quite some time trying to come up with an @automated solution to the problem. I thought that some hypothetical sysadmin might find themselves in a similar situation in the future, and this might save the hypothetical person some time.

The problem I was trying to solve was the following; How do we script the task of creating a new GPO with the same base settings but with different conditions (Strings (AD Groups, Hostnames), IP's, true/false), in an automated fasion?

The best answer to this question is; You probably shouldn't.

If the GPO planning is done carefully, you should not find yourself having this problem - since why would we want 10-100-1000 different GPOs doing basically the same thing? If we could use WMI filters, script-based, logically acting GPOs, the world would be a wonderful place.

## Reality hits you hard, bro

Let's be real, you either did the GPO planning yourself back in the 90's, or someones (probably awesome) dad did it. And he probably had a tight schedule, IT was probably understaffed already back then, and frankly, all companies might not have a [Mark Russinovich](https://en.wikipedia.org/wiki/Mark_Russinovich)-kind of guy, implementing flawless, scalable GPO plans for your organization.

Sadly the facts listed above does not help you in any way what so ever. Hopefully the rest of this blog post can.

## Technical bits

PowerShell and GPO's go quite nicly hand in hand, thankfully. Now starts the technical fun stuff. The following is what we need to solve:

Have a script that allows you to input a specific condition (City name, Group name, Computer name, yada yada), and have this script:

* Create a New GPO

* Set the specific GPO settings you need

* Link the GPO to the specific OU(s)

But how? GPO's are all XML and you really need GPMC to get the exact settings right, and I would rather not edit XML files in SYSVOL, what if I mess something up?

I'm glad you asked! Here's the kicker:

Since we're trying to automate the creation of a recurring GPO, there's already a GPO in place that does almost the exact thing you need. All we need to do is;

1. Create a similar GPO (disabled) alternatively use the production GPO (the one that someones dad created, aka DADGPO (tm) )

2. Backup this GPO to a safe(er) area (not sysvol)

3. Commit XML edits to change the desired condition

4. Create a new Blank GPO

5. Use Import-GPO's ID parameter, and input the edited GPO

6. Link the GPO to desired new OU

7. (optional) Be excited and tell everyone that you've just automated a process of EDITING AND CREATING new GPOs

This process solves two big issues, firstly it allows you to just edit the recurring GPO once, this would otherwise be a recurring task.

Secondly, it solves the issue with editing GPO's in production, since you should't tamper with XML files in a production sysvol. Instead the edits you do are directly done to the backup file that's outside of sysvol.

## Let us see some code already

This function lets you input

1. Name of the new GPO

2. Group name (DelegationGrouo) of the AD group you want to edit within the GPO settings

3. Domain name in case of multi-domain forest

Takes the input, and outputs a new GPO with the updated AD Group provided:

```powershell
function New-AdminPolicyGPO {
    param (
        $Name,
        $DelegationGroup,
        $Domain
    )
    Begin {

        # Insert whatever validation checks you need

        if (Get-GPO $Name -ErrorAction SilentlyContinue) {
            Write-Warning "GPO already exists"
            Break
        }
    
        if (Get-ADGroup $DelegationGroup) {
            $DelegationGroup = Get-ADGroup $DelegationGroup
        }
        else {
            Write-Warning "ADGroup not identified"
            Break
        }
    

    }
    Process {
    
    <#
        RootGPOs GUID needs to be changed to the DADGPO guid
        An easy way of getting GUID is to just run: 
        Get-GPO -All | ? DisplayName -Like "Name of gpo"
    #>

        $RootGPO = Get-GPO -Guid "D4DGP0-GU1D-D4DGP0-GU1D-D4DGP0-GU1D"

        # Create blank GPO and store it in a variable
        New-GPO $Name
        $GPO = Get-GPO $Name


        #Create path for backup gpo
        $BackUpPath = "$env:LOCALAPPDATA\BackupGPO\"
        if (Test-Path $BackUpPath) {
            $BackedupGPO = Backup-GPO -Guid $RootGPO.Guid -Path BackUpPath
        }
        else {
            New-Item -Path $BackUpPath -ItemType Directory
            $BackedupGPO = Backup-GPO -Guid $RootGPO.Guid -Path $BackUpPath
        }

        #Store XML file of backup gpo in variable
        $SuperLongAndFunString = "$BackUpPath{$($BackedupGPO.ID.GUID)}\DomainSysvol\gpo\Machine\Preferences\Groups\Groups.xml"
        if (Test-Path $SuperLongAndFunString) {
            try {
                # Play around with this part until Set-Content
                # changes the desired GPO setting

                $xml = Get-Content $SuperLongAndFunString

                $xml = $xml.Replace('"Domain\ADGroupName" action="ADD" sid="Whatever the SID is"', """$Domain\$
                ($DelegationGroup.Name)"" action=$('"ADD"') sid=""$($DelegationGroup.sid)""" ) #Edit XML
                
                Set-Content $SuperLongAndFunString -Value $xml -Verbose
                
                Import-GPO -BackupId $BackedupGPO.Id -Path $BackedupGPO.BackupDirectory -TargetName $GPO.DisplayName
            }
            catch {
                $Error[0]
                Break
            }
        }
        else {
            Break #Can't locate GPO from backup
        }
    }
}
```

## Lastly

This function serves as a base for you to use, and the point here is really to demonstrate the process of how you could tackle this problem. I would suggest playing around with get/set-content to get the desired outcome of the GPO settings in a lab env before even thinking about implementation to production.

In many cases, GPO setting changes are XML changes. PowerShell lets you configure anything within an XML file. The key to doing so is to understand the specific setting, so you can manipulate the backed up GPO's XML in your favor.

### Happy coding

### /Emil
