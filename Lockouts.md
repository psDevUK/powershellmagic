---
branding:
  title: "Powershell Blog"
authors:
 - name: Adam Bacon
   email: adambacon1@hotmail.com
date: 2025-09-30
icon: lock
label: Locked Accounts
order: 83
---

# Powershell Magic [!badge variant="warning" text="Back once again with the Powershell :bacon: flavour"]

![Become an IT ninja after reading this blog|500](/images/IT_Ninja.png)

## Puppy Update
So after my totally amazing wife dealt with the advertising and posting of the pups on the internet and spending about 200 quid on promoting the advert, now looks like I am down to one last puppy. This week have had deposits put down on Ace and Miami, so this just leaves Cooper to find a home. I mean they are nearly 12 weeks old, but was starting to panic a little bit, that I was going to have 7 dogs in my house. Although I moved to a larger house due to having 5 daughters, I did not envisage on having more dogs. However Barney and his superman-seaman had other ideas, swear this should of gone into the world records for quickest dog breeding ever, literally 2 seconds, and to make it worse like a huge puddle on the floor, which I was informed I was cleaning up. So yeah to have got 7 puppies from maybe 1% of spunk, that should surely set a dog record somewhere. 

Anyway we are not here to discuss dog breeding, we are here to become a ninja in identifying locked accounts on your network in Active Directory.

![Do not let your office place overcome you with challenges|500](/images/street_scripter.png)

## LockoutStatus.exe
I am sure if you ever done IT support, you have had that call from the end user totally dumb-founded end-user on why their Active Directory account is locked and it has to be the computers fault as they know their password and would have never typed it incorrectly numerous times. 

So this takes me way back maybe like I think 19 years back to 2006.  I was working second-line support for this company, and this developer kept getting locked out every morning when he went to logon.  Like he could be working till home time with no issues, he left his laptop at work to prove he was not causing the account to lock out, and sure enough come the morning his account in Active Directory was locked out. 

Please remember this was like 19 years ago, and I didn't have a clue to why this was happening, was it a hacker, was it a ghost, was it something else? Just too many what-ifs happening in my head to even contemplate solving this mystery.  So some senior tech team members found this amazing tool **lockoutstatus.exe** which I had never heard of at the time, and just like all amazing things, it is still going strong today and can be found here: https://www.microsoft.com/en-us/download/details.aspx?id=15201&msockid=08d10ee51ced62733a53188c1d0d63cc

Ever since I found about about this tool, I made a special memory slot in my brain never to forget it, because it totally saved the day back in 2006. It ended up that this developer had a scheduled task checking for updates to some software he had installed, at like 4am every-morning.  As he left his laptop switched on (as electricity was way cheaper then and none of these posters to remind you to power off before going home) his laptop was trying to update this software with old stored credentials which was retrying numerous times, which then caused his account to get locked out. I will never forget that and the importance of lockoutstatus.exe to get to the bottom of a lockout saga.

Even this year I have used **lockoutstatus.exe** numerous times to solve why the account was locked, yes it is super-easy to just unlock an Active Directory account, but if that account should keep locking out then to me it is better to find the root cause of the issue to prevent it from keep happening.

![The code shown in this blog will make you a mega-sysadmin|500](/images/megasysadmin.png)

## So where's the code?

![Prevent yourself from seeing it as you vs the machine|500](/images/coderOfRage.png)

So you might be thinking well, you kind of done a spoiler alert and gave away what the blog is about and you may have already downloaded the **lockoutstatus.exe** already and thought this is what I been after I do not need any code.  Well my fellow reader, yes **lockoutstatus.exe** is epic, but there is a few things that I think could do with some jazzing up. Firstly, when you open the application, it is just empty, you need to manually enter the username of the account that you wish to unlock. Then once you do enter the account, you do get back all your Domain Controllers, and which one the account did the bad passwords on to get locked out, with the time it attempted the logons. However this then means that you need to either remote onto that Domain controller to now inspect the event-log security logs, or connect to the remote domain controller from your event-viewer if you have the permissions. Next your going to need to either filter the log or do a crazy amount of scrolling to locate the exact log which locked out that user. Depending on the size of your company with the amount of end users this can mean lots, and lots of scrolling to find the thing you are looking for.

I decided to stream-line this process by writing 3 functions that will do all this automatically for you. Firstly I was thinking would it not be better to keep on-top of all locked accounts on your domain to be one-step ahead of the problem. As in, instead of me having to know the username, show me all the current locked out users in Active Directory in date descending order, in an Out-GridView so I can then just click on a given account. Then from selecting the account automatically return the exact information **lockoutstatus.exe** retrieves but without having to rely on running an executable, as it just automatically does this from the first selection. Then finally after selecting the Domain Controller which the user was locked out on, for it to then automatically connect to the event logs of that given Domain Controller and do all the searching for you, which then returns the final Out-GridView window containing the information on why the account was locked, and most importantly the machine this happened on.

The final step which I did not include would be to then go through the event log on that given machine to at the time shown in the previous results, to pin-point was it the user typing this incorrectly, was this a scheduled task running, or possible the incorrect credentials provided on a service running. 

```# ps1
function Get-LockedADAccount {
    Write-Output "Collecting all locked AD accounts on domain please wait..."
    $Lockedout = Search-ADAccount -LockedOut | Select-Object Name, SamAccountName, DistinguishedName
    $people = foreach ($item in $Lockedout)
    {
        Get-ADUser -Identity $item.SamAccountName -Properties LastLogonDate,SamAccountName
    }
    $selected = $people | Select Name,LastLogonDate,samaccountname | sort lastlogondate -Descending | ogv -Title "Locked AD Accounts" -PassThru
    Write-Output "You have selected the user $($selected.SamAccountName) to look at"
    $selected | % {Get-LockoutStatus -username $_.SamAccountName}
}

function Get-LockoutStatus {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$Username
    )
    Write-Output "Gathering all the required details for $Username please wait..."
    # Get the user object
    $user = Get-ADUser -Identity $Username -Properties LockedOut, LastLogonDate, BadLogonCount, LastBadPasswordAttempt, DistinguishedName

    if (-not $user) {
        Write-Warning "User '$Username' not found in Active Directory."
        return
    }

    # Get all domain controllers
    $DCs = Get-ADDomainController -Filter *

    $results = foreach ($dc in $DCs) {
        try {
            $dcName = $dc.HostName
            $logonInfo = Get-ADUser -Identity $Username -Server $dcName -Properties LockedOut, LastLogonDate, BadLogonCount, LastBadPasswordAttempt

            [PSCustomObject]@{
                DCName                = $dcName
                LockedOut            = $logonInfo.LockedOut
                LastLogonDate        = $logonInfo.LastLogonDate
                BadLogonCount        = $logonInfo.BadLogonCount
                LastBadPasswordAttempt = $logonInfo.LastBadPasswordAttempt
            }
        } catch {
            Write-Warning "Failed to query $($dcName): $_"
        }
    }
    $selected = $results | Out-GridView -Title "Lockout Status for $Username" -PassThru
    Write-Output "About to show the details behind the account $Username being locked"
    $selected | % {Get-LockoutEventLog -DCName $_.DCName -SinceTime $_.LastBadPasswordAttempt -UserName $Username}
}

function Get-LockoutEventLog {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$DCName,

        [Parameter(Mandatory)]
        [datetime]$SinceTime,

        [string]$Username
    )

    Write-Host "Querying $DCName for lockout events since $SinceTime.."

    try {
        $filterHash = @{
            LogName      = 'Security'
            ID           = 4740
            StartTime    = $SinceTime
        }

        $events = Get-WinEvent -ComputerName $DCName -FilterHashtable $filterHash -ErrorAction Stop
        $parsed = foreach ($event in $events) {
            $xml = [xml]$event.ToXml()
            $targetUser = $xml.Event.EventData.Data | Where-Object { $_.Name -eq 'TargetUserName' } | Select-Object -ExpandProperty '#text'
            $callerComputer = $xml.Event.EventData.Data | Where-Object { $_.Name -eq 'TargetDomainName' } | Select-Object -ExpandProperty '#text'

            if ($Username -ne "$targetUser") {
                Write-Output "No data found in security log. Exiting script"
                break
            }

            [PSCustomObject]@{
                TimeCreated       = $event.TimeCreated
                TargetUserName    = $targetUser
                CallerComputer    = $callerComputer
                DCQueried         = $DCName
                Message           = $event.Message
            }
        }

        $parsed | Out-GridView -Title "Lockout Events on $DCName since $SinceTime"
    } catch {
        Write-Warning "Failed to query $($DCName): $_"
    }
}

Get-LockedADAccount
```

![Think of this as your Golden script to AD lockouts|500](/images/Golden.png)

Due to the confidential information returned from running this script, I have not included any screen shots as I love my job to much to put it at risk, plus even if I did use images from the output, I would have to draw loads of lines over the confidential data it is returning so thought I would leave it to you to run it, to see how epic this script is.

## Something to share
So been amazed at how good these Roland Compact devices sound, so done another J-6, P-6 combo, making more sounds of the kind of music I loved when I was younger before kids entered my life. I still do enjoy this kind of music but I know I am getting older, but here it is, enjoy! :musical_note:

https://www.youtube.com/watch?v=H6kK2zH9Rog

Till next time stay safe and take care.