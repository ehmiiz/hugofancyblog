---
title: "Solution: Restore Deleted Private key for EFS Encrypted Files"
date: 2022-06-15T12:39:23+01:00
draft: false
comments: true
---

![a](/pics/accessdenied_after_removal.png)

## Problem
You have encrypted files using the "File > Properties > Advanced > Encrypt content to secure data" feature in Windows, and have lost your certificates in your personal certificate store.


## Solution
A solution to this problem is to restore the private key used for encrypting your file system (EKU: Encrypting File System 1.3.6.1.4.1.311.10.3.4 ) that was generated upon encrypting your files.

The keypair to this certificate is stored in your Personal certificate store, luckily a copy of the public key is stored in your LocalMachine certificate store. This means we can restore the private key and enable decryption as long as the computer has not been reinstalled or lost.

### Step-by-step
1. This file is currently unecrypted. Let's encrypt is using the method discussed

![Secret!](/pics/file.png)

Rightclick the file > properties > advanced > encrypt content..

![encrypt_gui](/pics/encrypt_gui.png)
![encrypt_file](/pics/encrypt_file.png)

I will select 'Ecrypt the file only' in this case

![loc_icon](/pics/lock-icon.png)

The lock symbol indicates that the file is successfully encrypted. Under the hood, windows generated a self-signed certificate with a private/public keypair in my personal store and a certificate in my localmachine/addressbook only containing a public key.

2. Verify the certificates

![currentuser_certstore_cert](/pics/currentuser_certstore_cert.png)

Let's verify it's private key:

![private](/pics/currentuser_privatekey_true.png)

Let's verify the localmachine/addressbook certificate:

![cert_store_public](/pics/certstore_find_publickey.png)

![cert_store_public_private_key](/pics/localmachine_privatekey_false.png)

HasPrivateKey: False - tells us this certificate lacks the private key, and is somewhat useless for the decrypting of our file. We will now move on to the issue at hand

3. Delete the current users private key to simulate the issue

![delete_currentuser_privatekey_cert](/pics/delete_currentuser_privatekey_cert.png)

Let's try to query the certificate store to verify the lack of this deleted certificate

![after_deleted_privatekey](/pics/after_deleted_privatekey.png)

We are recursivly looking for the certificate in the root of the certificate store, and we only got one hit. Meaning the private/public keypair has been removed, together with the ability to decrypt our file:

![accessdenied_after_removal](/pics/accessdenied_after_removal.png)

The screenshot displays an attempt to move the file, as well as open it with notepad. Both failed due to a "lack of access".

4. Restoring the certificate using the public key in LocalMachine store

![restore_private_key](/pics/restore_private_key.png)

First, we move into the LocalMachine\AddressBook path in the certificate store, and we verify that it contains our public-key based certificate

We then utilize certutil to restore the private-key part of that we had before lost:
```powershell
certutil -repairstore addressbook '<insert thumbprint>'
```

![privatekey_after_restore_success](/pics/privatekey_after_restore_success.png)

Verify that the PrivateKey was infact restored

We have now restored the most critical part of the removal, but decryption will still fail, since windows will only query your personal store while the decryption process takes place. This means we will need to export this certificate, together with it's private key - and import it to your personal store.

5. Export / Import the key-pair to the Personal Store

![export_privateandpublic_key](/pics/export_privateandpublic_key.png)

Navigate to the mmc snap-in, import the Certificate snap-in, select Local Computer, and navigate to the 'Other People' folder

Right-click the certificate (this is the same certificate that we displayed in PowerShell after the restore process) All Tasks > Export...

![private_key_selected](/pics/private_key_selected.png)

Export the private key > Next

![allow_only_current_user](/pics/allow_only_current_user.png)

Use your currently logged on user > Next

![savetopath](/pics/savetopath.png)

Save to path

![import_current_user](/pics/import_current_user.png)

Navigate to the path, right-click > Install PFX, Current User > Next > Next > Next..

![successful_import](/pics/successful_import.png)

We have now moved the key-pair back to the personal store, and can now decrypt files

![successful_decrypt_and_write](/pics/successful_decrypt_and_write.png)

Verifying this by writing to the file, and getting it's content

![successful_open_doubleclick](/pics/successful_open_doubleclick.png)

Double-clicking the file now works as expected




## Discussion

We have now simulated an issue that unaware users can be exposed to, and solved it using PowerShell, the Certificate snap-in in mmc, and certutil.

Accidential deletion the private/public key-pair in the personal store can be quite common, since IT personel usually perform this, together with a GPUpdate, to re-enroll autoenrollment managed certificates. However, in this case the certificate will not re-enroll itself since it's a self-signed certificate, only used locally for ecryption/decryption. 

This problem be solved in this way for self-signed certificates, I would imagine that it's the most of cases.

If your Public Key Infrastructure enrolls "Encryption File System" certificates to domain users, a PKI admin could in theory export the certificate in the CA (as long as the private key is exportable, that is).

