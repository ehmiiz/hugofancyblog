--- 

title: "PowerShell for Automation: Simple Hyper-V VM-Creation script" 

date: 2021-12-21T14:58:11+01:00 

draft: false
comments: false

--- 
## Meet [Labmil](https://github.com/ehmiiz/labmil).
Labmil is a script I made to solve a problem. AutomatedLab is too "Heavy" for my taste, and I need a standard way of generating Hyper-V VMs for labs.

## Some design alternatives
First of, I wanted to try out working with environment variables, so that's a thing in this script. Second, I rely on the user to be able to ForEach stuff for scaling, this was manly a choice from my part because I know I will be it's main user.

Read the examples in the Github page to understand what I mean with "rely on the user to be able to ForEach stuff".

## Non-Features
The script has some Non-Features, meaning it's basically a feature for the script, by not being there.

Non-Features are cool because it makes the script unique in some ways, without any extra effort.

For example;

- It is much more robust, since it's simple enough not to touch the application layer.
- It only uses 1 parameter after initial run
- It enables you as an sysadmin/engineer to do the whole set-up (not automating the staging part)
- It's only focus is Hyper-V VMs

