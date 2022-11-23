--- 
title: "PowerShell Productivity tip: Working with History" 
date: 2022-05-16T08:05:11+01:00 
draft: false
comments: false

--- 



{{< figure
  src="https://images.unsplash.com/photo-1580136579312-94651dfd596d?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1317&q=80"
>}}


One thing I've always done while hacking along in the terminal is working with my command-line history. There's quite a few ways to do so currently, so I thought i'd share some of my favorite ones.

## Different ways of viewing your history
- To view your current sessions history, PowerShell creates an alias for the cmdlet Get-History -> h. Simple as that.
```powershell
h
```
- To view your over-all history in your current environment, PSReadLine is your friend: 
```powershell
cat (Get-PSReadLineOption).HistorySavePath
```
Viewing the txt-file of PSReadLines history can be a lifesaver if you work with colleagues that tend to never document their solutions. You could modify the HistorySavePath property of your own output, to view someone else's history on a shared server/computer.
```powershell
cat (Get-PSReadLineOption).historysavepath.Replace("$env:USERNAME","Your-Colleague-That-Did-Not-Docx-It")
```


## History Tend To Repeat Itself
As we all know, we humans always have a need to re-run history. Without being political about it, here's some examples on how you could do this in PowerShell

```powershell
r 25
```
It's that simple. In your current session, each command you enter will be available in your Get-History (h). Each history entry has an ID. The cmdlet behind the alias r (Invoke-History) will execute your history based on the ID you provide. In the example above, I'm executing my 25'th command inputed in my terminal.

{{< figure
  src="https://i.imgur.com/O4y0isj.png"
>}}

## But there's more!
```powershell
PS C:\Users\Emil\git> #25<tab>
PS C:\Users\Emil\git> Write-Host "Tomorrow is monday!!!" -ForegroundColor (Get-Random "Green","Yellow","Blue")
```
The following is PowerShell Black-Magic, and is's really useful. It saves you the trouble of copy-pasting your history.

Simply view your history, memorize the ID, hit '#' and the ID, followed by a 'tab' and you have it printed ready to be executed in your terminal.

{{< figure
  src="https://i.imgur.com/fw4C055.png"
>}}


## Help!
If you've read this far and desire more reading, run the following one-liner
```powershell
gcm *-history | % { help $_.name -s }
```
To be clear:
```powershell
Get-Command *-history | ForEach-Object { Get-Help $_.Name -ShowWindow }
Get-Help about_history
```
Hopefully this was a decent history-lesson for someone!

### Happy coding

### /[Emil](https://twitter.com/ehmiiz)
