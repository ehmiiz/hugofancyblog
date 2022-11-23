--- 
title: "PowerShell Automation: Generate an Azure Access Review Report using Microsoft Graph!" 
date: 2021-09-09T14:58:11+01:00 
draft: true
comments: true

--- 
Access reviews are critical for organizations that values up-to-date On-prem AD groups & Azure AD Groups.

Various audit & compliance teams will most likely value data from reviewers decision high, all this data can be found using the Microsoft Graph. This blog post will go into details on how you could:

1. Create an app registration in Azure AD
2. Delegate API permissions to the app:
``` 
Application:	AccessReview.Read.All
```
3. Create a token secret to store in an Automation account
4. Creating a Azure Automation Runbook
5. Creating a script that uses Microsoft Graph, PowerShell and Export-CSV to generate the final Access review list

Lets get started!

## Pre-reqs

Before we get started there are some pre-requierments needed, I'm asuming the following;
* Read has Global Admin rights in the Azure tenant, needed for the admin consent
* The read has maintainer right to an Azure Automation account


## App registration and Permissions

## Azure Automation & Shared variables

## PowerShell script for Access Review / Graph

 

## 