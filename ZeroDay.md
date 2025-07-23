---
meta:
  title: "Powershell Blog"
authors: 
 - name: Adam Bacon
   email: adambacon1@hotmail.com
date: 2025-07-23
icon: alert
label: Zero-Day Threats
order: 98
---
# Powershell Magic [!badge variant="warning" text="Back once again with the Powershell flavour"]

As promised in the landing page this time we are actually going to do some **powershell magic** which to me is being able to provide a script from scratch to deliver the solution to the given problem.

## Thinking...
![](/images/thinking.PNG)
I firmly believe in understanding and thinking of how you will provide a solution to the given problem, and to also have a back-out plan in-place if any changes are being involved. I do not influence violence by any means as the solution, but as the picture above shows, this lady has thought her way out of the problem she was presented with.

## Normal rules I follow
**Understand the problem** :confused: if you do not understand the problem ask for it t be explained again. Then look to apply a **solution which can be re-used to fix the given problem**. Normally this involves writing a function and providing certain criteria as parameters, so that you can then change the values of those parameters to meet the given problem you are trying to fix.

**Do not re-invent the wheel** :ferris_wheel: as in you could potentially go off on a mission to re-create something out there that already exists. So I strongly advise you at least **check out the Powershell gallery for any existing modules** that may already exist to help you solve the scripting quest you have been presented with.  You could also use code specific sites such as **GitHub** to see if something exists or something to inspire you. Yes at school you may have got yourself into big trouble as this is technically plagiarism but we are not at school anymore. 

**Do not spend too long looking for something else** :alarm_clock: to solve the problem for you, as in if you could do the task manually in ten minutes but you spend three hours looking for that solution, then to me that is not time well spent and being efficient. I tend to limit my time reasearching to a maximum of twenty minutes, as I knew this particular task would have taken a lot longer doing this manually, so even if I did not find any modules or scripts of interest I have only invested a maximum of twenty minutes of my time. 

**Get cooking up a solution** :cooking: as in start coding the solution to the problem, I like to **add comments** so that if someone else should need the code, or you show it to someone who does not fully understand code, they should be able to understand the comments you have made and read through those understanding what your script is going to do and the order it is doing it in.

## What was the problem? 
Hopefully as the link suggested the issue was numerous zero-day threats discovered from an article my boss had read
[!ref Security Article](https://www.forbes.com/sites/daveywinder/2025/05/15/microsoft-confirms-windows-is-under-attack---you-must-act-now/)
My boss wanted me to verify that each of those zero-day threats we had protection against in SCCM. Although SCCM is amazing in deploying various items across you network, I do find it extremely point and clicky and sometimes over-kill to get the information you are after. So I knew about the Configuration Manager module, as I have used it to build my own stream-lined SCCM dashbaord.  However how could I get all the CVE information from the website I was provided a link to and then double check that the fix had been setup in SCCM?

This is where you use twenty minutes of your time wisely, which led me to a module I had never heard of or used before [!ref MSRCSECURITYUPDATES](https://www.powershellgallery.com/packages/MsrcSecurityUpdates/1.9.5)

Using this module, I could reference any given CVE threat, then obtain the KB article number which has been released to fix that specific CVE threat. This would same me a lot of time from trying to obtain this off of the internet, and again save me a lot of point and clicking. :mouse2:

## What was your solution?

Although I did mention functions in my previous normal rules I follow, as this was the first time of being asked to provide this type of information in the two years and eleven months I have worked at this company, this did more seem like a one-off request. I normally write the script, then if I see that the script could be useful say to check this on numerous computers, and other filters, then yes I would most certainly make this into a function so that you do not have to manually edit the script each time. As this was a one-off request then I decided producing a script to provide the **answer of yes the patch is in SCCM and has been deployed** or **no these CVEs are not currently protected against in SCCM** was a good enough solid answer to the problem I was provided with. 

## The end solution

```ps1 #
# YOU NEED THE MSRCSECURITYUPDATES MODULE INSTALLED
$KBinformation = @()
# Create an array of the CVEs you wish to find more information on
$CVEs = @(
"CVE-2025-30397",
"CVE-2025-32709",
"CVE-2025-32701",
"CVE-2025-32706",
"CVE-2025-30400",
"CVE-2025-30386",
"CVE-2025-30377"
)
# now loop through each CVE to find out all the hotfixes for this threat
foreach ($CVE in $CVEs) {
    # Obtain the URL through the MsrcSecurityUpdates powershell module 
    $Url = (Get-MsrcSecurityUpdate -Vulnerability $CVE).value.cvrfurl
    # Download the webpage content which is now not in a dynamic form
    $WebContent = Invoke-WebRequest -Uri $Url
    # Convert this to xml so Powershell can read the contents as objects
    $XmlContent = [xml]$WebContent.Content
    # Now filter the results to the specific CVE and find the remediations for this CVE
    $KBinformation += ($XmlContent.cvrfdoc.Vulnerability | Where-Object CVE -EQ $CVE).Remediations.Remediation | Where-Object { $_.Description -ne $null -and $_.Description -match "^[0-9]" } | Select-Object -Unique description | Select-Object @{N = "CVE"; E = { $CVE } }, Description
}
# Create new empty array to store results in 
$results = @()
# Now using the CONFIGURATIONMANAGER module to check the status of each of these KB fixes in SCCM
Import-Module ConfigurationManager
# Setup the PSDrive for SCCM
New-PSDrive -Name "XXX" -Root "SCCM-SERVERNAME" -Description "ConfigMgr" -PSProvider CMSite
# Navigate to the SCCM site drive
Set-Location XXX:
foreach ($KB in $KBinformation) {
# Display outcome for each CVE processed
    try { $results += Get-CMSoftwareUpdate -ArticleId $($KB.Description) -fast -ErrorAction Stop | Select-Object @{N = "CVE"; E = { $($KB.CVE) } }, DateCreated, IsEnabled, IsDeployed, NumMissing, NumPresent, ArticleID, LocalizedDisplayName, LocalizedDescription, Severity }
    catch { Write-Host -ForegroundColor Yellow "Cannot find KB $($KB.Description) in SCCM" }
}
```

## Thank you
Again thanks for your time reading this article and hopefully this has given you some ideas :bulb: in your head on fixing a similar issue you may have been presented with at work, or just little tips used to be more effective in providing a scripted solution to any given problem. In total this took less than an hour to produce from the initial question being asked, and I was certain that the information returned was correct. Thankfully all patches did exist in SCCM and that was that. 

## Something to share
Recent times have been pretty emotional for me, especially with more recent news. I do find music can help, and even better if you can put a tune together to show how you are feeling. so I hope you enjoy this emotion tune I made :musical_note:

https://www.youtube.com/watch?v=wEJYvR8fw6E

Until next time, stay safe and see you again soon for another Powershell solution :grin: