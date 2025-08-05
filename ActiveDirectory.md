---
branding:
  title: "Powershell Blog"
authors: 
 - name: Adam Bacon
   email: adambacon1@hotmail.com
date: 2025-08-04
icon: accessibility
label: Active Directory
order: 94
---
# Powershell Magic [!badge variant="warning" text="Back once again with the Powershell :bacon: flavour"]

## Puppy update

So as mentioned in my last blog a couple of the puppies seemed to be having issues opening their eyes, which is common in the Shar-Pei breed, as they are so wrinkly basically their eyelids can roll in on the eyes, and needs immediate attention, as this can lead to more problems the main one blindness.

My wife and I took two to the vets immediately, not my local one as they had no appoinment slots, only to be informed that they were fine and was sent home, and the vet mentioned eye drops if it got worse. Less than a day later could see the pups were having discharge from the eyes, so phoned vet back.  Only to be told that the vet we saw was now on holiday, and no notes were left about the eye drops, which meant another consultation fee to pay and a different vet to see in my local vets.

Again seemed pretty pointless, as they did not know what eye drops to prescribe and they needed to contact this vet eye specialist in Bideford. My wife got on the case and contacted them directly, and another consultation fee and another visit. By now my wife had noticed that another pups eye had closed, just the one which was previously okay. So off we went to the vets for yet another consultation, but this time hopefully an answer to the problem.  So in total all these visits and the eye tacking operation which was required has now set me back I think £1,247 in total. So very grateful I have a job to have been able to pay for this, but yeah an unexpected cost which I could have done without, but I love my animals as they are part of the family, and although I plan to sell these pups minus the white one with a cone on it's head, as I do not think 10 dogs in the house is practical I still love them to bits and want the best for them.

![Got 3 cone head pups now](/images/pups.jpg)

So thankfully after all the drama of like visiting 3 different vets, finally got these little pups to the right vets who were amazing with the work they done, as they are only 3 weeks old.

## Background to issue

Right now I got all my puppy problems out the way I can now focus on writing a new problem and Powershell solution to that problem. The background to this problem is the **MemberOf** tab within a user account in **Active Directory**

Well that is not a problem in itself, infact it is really handy to show you would groups a particular user is a member of within Active Directory.  Not long after I started this job, I realised this is a big company with thousands and thousands of users. To further complicate things this is the first company I have worked at which uses **Role Based Access Control** aka RBAC. So although the 200+ scripts I look after which do all the on-boarding for users sometimes the data that these accounts are created off could not hold the right information (I have no control over the CSV data) and like the saying goes **bad data in bad data out** 
Despite raising this numerous times to fix the underlying issue, the people in-charge of the spreadsheet obviously like to keep me on my toes.  Also as not all people in the company might not appreciate the rules configured for RBAC you could have HR change loads of peoples departments, or job titles. This then means that those people are automatically removed from RBAC groups as they no longer meet the given criteria to be in that group. This then leads to being asked why **user A** can still access what they need but **user B** can now no longer access the things that they used to be able to access which was the same as **user A**

Although I am not office based I know that people will look at the **MemberOf** tab in **Active Directory** with two user accounts side-by-side and try to do a spot the difference between them.  Due to the size of the company I work for also adds a crazy amount of Active Directory groups. So this then becomes a mission to identify the missing group or groups due to the size of the lists shown.

![Do not let spotting the difference lead to situations like this](/images/clone.PNG)

## What was the problem?

Within the first month this problem had presented itself a few times, so wanting to make a good impression and solve this easily going forward I cooked up a very basic function.  Honestly I have now used this hundreds of times, and given it to numerous people in numerous IT departments as it has saved my :bacon: so many times when I get asked about why this account cannot do something when another account who should have the same access can.

!!!Occam’s Razor
Put simply, states: “the simplest solution is almost always the best.” It’s a problem-solving principle arguing that simplicity is better than complexity. Named after 14th-century logician and theologian William of Ockham, this theory has been helping many great thinkers for centuries.
!!!

Although I was not thinking good old Occam's Razor when I did this, I was thinking that this simple solution would solve this issue in no-time, and it was so simple I kept it as a basic Powershell function, sometimes the simple solution is the best solution. Just crazy how many times I have used this, and even the same people asking me who I have previously given this same function to still ask me, and I run this function, then the issue is revealed which group or groups are missing from one account that the other account has. 

## Get-ADGroupDifference

```ps1 #
Function Get-ADGroupDifference ($u1,$u2){
    $user1 = (get-aduser $u1 -Properties memberof).memberof | Get-ADGroup | sort name | Select-Object -expand name
    $user2 = (get-aduser $u2 -Properties memberof).memberof | Get-ADGroup | sort name | Select-Object -expand name
    $Global:groups = Compare-Object -ReferenceObject $user1 -DifferenceObject $user2 -IncludeEqual | Select @{n="GroupName";e={$_.InputObject}},SideIndicator,@{n="Same";e={if ($_.SideIndicator -eq '=='){"Equal Access"}}},@{n="$u1";e={if ($_.SideIndicator -eq '<='){$u1}}},@{n="$u2";e={if ($_.SideIndicator -eq '=>'){$u2}}}
    $groups| Out-Gridview 
}

Get-ADGroupDifference userA userB
```

You may have noticed that I use the **$Global** parameter here to store the outcome of the display. I also use the **Out-GridView** cmdlet to allow easy viewing, sorting and filtering of the data presented.

## Bonus solution

The bonus feature is putting this to even more use. If you have managed Active Directory you most likely have been asked that you want **userB** to have the same permissions or access as **userA** now I know a lot of people do tend to just copy accounts, but that is not best practices as you do not know exactly what you are copying, and if userB account already exists in Active Directory you do not want to be deleting that account and creating a new copied account as it will get a new GUID and will not match the cloud linked Active Directory account anymore and well it might seem a simple solution, but in this instance it is most certainly not the best solution or idea.  

So to achieve being able to say automatically give userB everything that userA has we can simply add a few more lines of code:

```ps1 #
Function Get-ADGroupDifference ($u1,$u2){
$user1 = (get-aduser $u1 -Properties memberof).memberof | Get-ADGroup | sort name | Select-Object -expand name
$user2 = (get-aduser $u2 -Properties memberof).memberof | Get-ADGroup | sort name | Select-Object -expand name
$Global:groups = Compare-Object -ReferenceObject $user1 -DifferenceObject $user2 -IncludeEqual | Select @{n="GroupName";e={$_.InputObject}},SideIndicator,@{n="Same";e={if ($_.SideIndicator -eq '=='){"Equal Access"}}},@{n="$u1";e={if ($_.SideIndicator -eq '<='){$u1}}},@{n="$u2";e={if ($_.SideIndicator -eq '=>'){$u2}}} # | ? GroupName -Match "doc"
$groups| Out-Gridview 
}
Get-ADGroupDifference userA userB
$missingGroups = $Global:groups | ? {$_.SideIndicator -EQ '<='} | Select -ExpandProperty GroupName

foreach ($group in $missingGroups){
    Add-ADGroupMember -Identity $group -members userB
    Write-host -ForegroundColor Green "Added userB to $group"    
    }
```

 This time a double-whammy solution to the age old problem of differences in Active Directory accounts. I know I could have even jazzed up this function for this blog, but **it is what it is** which has become my saying of late with all the unexpected news I have recently had. 

 ## Something to share
 Again I need to make some new beats but life has been rather hectic of late, so I hope you enjoy this tune I made not so long ago :musical_note:

https://www.youtube.com/watch?v=aN4zVYe-tB8