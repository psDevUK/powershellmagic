---
branding:
  title: "Powershell Blog"
authors:
 - name: Adam Bacon
   email: adambacon1@hotmail.com
date: 2025-08-08
icon: bug
label: Scheduled Task Password
order: 92
---
# Powershell Magic [!badge variant="warning" text="Back once again with the Powershell :bacon: flavour"]

![An awesome comic about a computer related threat|500](/images/worldtr33.PNG)

## Scheduled Tasks

So I am sure you have used or know about scheduled tasks. They have been a part of Microsoft Windows built-in features for years and years, I can even use the word decades for how long this has been part of the operating system. Personally I think they are a bit old-skool and there are many new ways you could implement scheduled tasks without having to use scheduled tasks. 

One thing that automatically springs to mind is **Powershell Universal by Ironman Software** which has something built into it, which is like scheduled tasks on steriods. I love using Powershell Universal to be able to automate given problems, but also being able to produce a beautiful looking webpage from your powershell code. It really is amazing so check that out if you do not know about it, I seriously think this will blow your mind on what you can do:

[!ref Powershell Universal](https://powershelluniversal.com/)

When I started this job I soon found out that all the automation being done was using scheduled tasks to run certain scripts at certain times of the day. Personally I had never seen so many scheduled tasks setup like this, I mean there is just under 300 scheduled tasks all running which I have been the sole person managing for over a year, plus doing all the other things that come my way like projects, service now tickets, audits, security work. It keeps me busy and puts food on the table for my family and a roof over their heads which is the main reason I work. To be able to provide for my family.

## What was the problem?

Not that long ago I was informed there was a security threat and certain passwords needed to be changed immediately within Active Directory.  One of the accounts which needed this doing was the service account which runs all of the nearly 300 scheduled tasks. As soon as I was informed about this change I also knew that the ramifications of changing that service account password would also mean that nearly 300 scheduled tasks would all need the password updating in order to carry on working. If this was not done, then the scheduled tasks running would carry on using the last inputted password, which was not going to be valid anymore as the password had to be changed to resolve the security threat.

![WorldTr33 by Image Comics is a great read about a security threat spreading by mobile phones|500](/images/compromised.PNG)

## What was the solution?

So this is like a no-brainer to me, I know I needed to update all the scheduled tasks to be the new password that was being set.  I also needed to make sure that the secret server also had all references of this account and the password updated to, but this particular blog is just looking at the scheduled tasks. 

Again I am kind of laughing as I write this as I know so many Windows Admins would just choose the point and click route to update each and every scheduled task, but as I had nearly 300 to do, there was no way I was wasting my time doing this, as I firmly believe in **working smarter not harder** and providing the best you can for the company you work for by not wasting a whole day or more doing mundane tasks the slow point-and-click way. To me that is like putting your feet on the desk and picking your nose all day, as in not making the best use of the skills and time you have. 

I know far too many people choose this route of point-and-click because it is the way they have always done things, or might think it is too complicated to code. Well look, I only got GCSE's to my name, I never went to University and I do not hold any degrees to my name. However if you want something bad enough you can obtain it through hard work and never giving up. Hence when my first child was born who is now nearly 17 I wanted to provide more for her, as the job I was in at the time barely covered the bills, let alone the shopping. I wanted to earn more money in IT and the way I saw myself doing that would be to become a programmer, Powershell was the new language that had come out, and unlike many other languages out at the time, seemed to be a lot more readable, due to the way the Powershell team had constructed the verb-noun naming methods of the cmdlets. 

I do not see it as often these days but a lot of early Powershell scripters used to tweet or post on other social media a **one-liner bit of Powershell** that did something that might have taken almost 100 lines of code in Visual Basic. This encouraged me more to learn this language and one-day post about my own one-liners. Okay I failed on that in this blog as it is two lines of code not one line. Still using only two lines of code saved me having to repeat this same task on nearly 300 different scheduled tasks. Which as mentioned in my last blog is more likely going to lead to mistakes being made due to repeating the same task and being human, you could forget to do a task, you might spell the new password wrong, it might not copy and paste correctly if you included a white-space or something. Again that is why I choose to script and automate the method as you could try this on just one particular scheduled task, then if you know that worked without issues, it is then just a case of running this in a loop to process all the scheduled tasks.

## Code solution

```ps1 #
$Credential = Get-Credential
Get-ScheduledTask -TaskPath \your-script-directory\* | ForEach-Object {Set-ScheduledTask -TaskPath $_.TaskPath -TaskName $_.TaskName -User $Credential.UserName -Password $Credential.GetNetworkCredential().Password -Verbose}
```

![Sometimes it pays not to follow the crowd in a point-and-click world - WorldTr33 comic|500](/images/phones.PNG)

The solution allowed me to store the credentials which contained the new password into a variable without hardcoding any sensitive information. Then it was a case of obtaining all the scheduled task in the specific directory within scheduled tasks that the scripts ran from using the **Get-ScheduledTask** cmdlet. Then pipe that to a **Foreach-Object** which will then interate through all the scheduled tasks one at a time.
!!!
 **I like to think of this as when you get your shopping scanned at the checkout in a shop they scan one item at a time and the barcode is then giving the properties aka the product and price of that item** 
!!!
except in this case it is the properties of the given scheduled task, the task-path the task-name, and the username and password for each task. Finally using the **Set-ScheduledTask** to confirm what the details should be for each task processed. 

Again this is not send a person to the moon type of complex Powershell script but just keeping it simple to get the given problem accomplished in the least amount of time, making more effective use of my time for the rest of the day. 

!!!
No need to over-complicate things in life, sometimes life is complicated enough. 
!!!

I also knew this would give me a 100% success rate as I had tested it prior on just one scheduled task.  I mean I could have added this into a **try / catch** block of code, to follow best practices but I was very confident that there would not be any issues, so opted just to keep it simple and use the **verbose** parameter to show me the output of what it was doing. To my delight everything went as planned and shocked the person who presented this issue to me when I informed them it was all done and dusted. 

## Thank you

Thanks again for reading one of my **IT tales of problems**. I know there was nothing amazing in the code I shared in this blog, but hopefully it will help someone out there who is facing a similar problem, and will now look to use those couple of lines of goodness. Or hopefully it might inspire you to pick up a Powershell book after reading this blog realising that it is not a case of having to be a mad computer scientist to learn this language, and when you do learn it, it can become extremely powerful in just a few lines of code.

So to make you feel a bit more lively after digesting this information, I made a brand-new track last night so here it is, I hope you enjoy the music :musical_note:

https://www.youtube.com/watch?v=aDE6xL9vTo4

Until next time stay safe and take care.