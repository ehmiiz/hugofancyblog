--- 
title: "PowerShell Solution: Install PFX certificate on servers"
date: 2022-11-16T08:13:11+01:00 
draft: false
comments: false

--- 


{{< figure
  src="/pics/Install-ADFSCertOnAllServers.png"
>}}

## Problem

As you may have guessed, this post will be about installing certificates using PowerShell.

Every year as someone working with identity topics, I am tasked with renewing certificates across the environment. Many services relies fully on valid certificates in order to function securely.

One critical service in particular that this scenario will cover is: `Active Directory Federation Services`, ADFS.

In most cases, you will have multiple ADFS servers, meaning, if your not automating already, you will need to install the SSL certificate manually (no fun experience on 10+ servers).

_There's more to say regarding specifically ADFS SSL certificates, that this post will not cover, however an installation will be needed in many of those scenarios as well._

## Solution

This solution covers how one could do this for ADFS servers, however it carries over to other services that requires a valid certificate as well.

To generate an pfx file out of an external certificate, I recommend using [The Digicert Cert Utility](https://www.digicert.com/support/tools/certificate-utility-for-windows) to generate the CSR (Certificate Signing Request) on the root server. Then simply import it using the digicert tool, and export the certificate to a .pfx file.

Here's an example of how to export an already installed certificate as a PFX file:

```powershell
$PfxPw = (Read-Host -Prompt 'Enter a password' -AsSecureString)

Get-ChildItem -Path cert:\localMachine\my\<thumbprint> | Export-PfxCertificate -FilePath C:\Cert\ssl_cert.pfx -Password $PfxPw
```

_It's important that the certificate gets imported on the server where the CSR was generated, in order to have a valid public/private keypair._

What we need to start out is:

1. The ADFS Root server with the pfx certificate exported
2. Access to all ADFS servers
3. WinRM/PowerShell remoting enabled environment

```powershell
# Local path to the certificate
$PFXPath = 'C:\Cert\ssl_cert.pfx'

# Credential object, we only use the password property
$Creds = Get-Credential -UserName 'Enter PFX password below' -Message 'Enter PFX password below'

# Path of the remote server we will copy to
$ServerCertPath = "C:\Cert\"

$InternalServers = "SERVER1", "SERVER2", "SERVER3"

foreach ($Server in $InternalServers) {

    # Creates a remote session
    $Session = New-PSSession -ComputerName $Server
    # Copies the certificate to the remote session
    Copy-Item -Path $PFXPath -ToSession $Session -Destination $ServerCertPath -Force -Verbose -ErrorAction Stop

    # Imports the pfx certificate using the credentials provided remotely
    Invoke-Command -Session $Session -ScriptBlock {

        Import-PfxCertificate -FilePath $using:ServerCertPath -CertStoreLocation Cert:\LocalMachine\My -Password $using:Creds.Password
        
    }
}
```

## Small Talk

And just like that, you've saved truckloads of time every year using PowerShell.

I highly recommend checking out more cmdlets based from the [pki](https://learn.microsoft.com/en-us/powershell/module/pki/?view=windowsserver2022-ps) and [Microsoft.PowerShell.Security module](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.security/?view=powershell-7.3). The script above displays how one can tackle a .pfx certificate, but using [Import-Certificate](https://learn.microsoft.com/en-us/powershell/module/pki/import-certificate?view=windowsserver2022-ps), you could do similar things with .cer files.

Also, one could eliminate the need for generating a password with using something like [Microsoft.PowerShell.SecretManagement](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.secretmanagement/?view=ps-modules). This module translates well into a lot of cmdlets in the pki/security module.



### Stay safe & happy coding!

### /Emil
