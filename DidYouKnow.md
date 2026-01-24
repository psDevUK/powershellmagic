---
branding:
  title: "Powershell Blog"
authors:
 - name: Adam Bacon
   email: adambacon1@hotmail.com
date: 2026-02-22
icon: question
label: Did you know
order: 81
---

# Powershell Magic [!badge variant="warning" text="Back once again with the Powershell :bacon: flavour"]

## Hello Powershell Enthusiasts! :wave:

I do apologise for the delay in posting new content. Life has been quite hectic lately, but I'm excited to share some interesting Powershell tidbits with you today. Thankfully, I have been using PowerShell for a long time, so certain things I do not even think about, other than to get using PowerShell and become a geek in a half-shell. However, not doubting the skills of others but it can be painful to watch how someone who does not know the mighty PowerShell do something in my opinion the hard way.

So, I thought I would share a few basic tips and tricks that might help you become more efficient in your PowerShell scripting journey. Covering little things that can make a big difference, when it comes to saving time and effort. In this blog I am going to cover numerous **did you know** PowerShell tips and tricks. So hopefully something in this blog will help you learn something new or at least remind you of a feature you may have forgotten about. So without further waffling, let's cover something I used to
hate at school.

## Math :abacus:

Although I have massive respoect for **Microsoft** I do sometimes think that certain things could have been updated over-time. Like entering the pagefile in megabytes. To me that is so 1990s or early y2k when the amount of RAM in a machine would only be megabytes.  However the year is 2026 and I am pretty sure everyone running a modern or half modern device has gigabytes of RAM not megabytes. Then unless your really old-school it can be confusing on how many megabytes to one gigabyte, and then either using a calculator or your brain to work out the large figure you need to type into the value fields. Thankfully PowerShell shines here, the fact you can do simple math conversion between known amounts of sizes KB / MB / GB / TB etc. If I wanted to set the minimum page size to 8GB for instance, I can simply type **8GB / 1MB** directly into the Powershell console which will then show mevthat there is **8192 Megabytes in 8 gigabytes. So if you are ever faced with the issue of trying to work out the amount of KB or MB you need to enter, then remember to reach to PowerShell for a quick answer.

## Time :watch:

Time is pretty important factor, it's how we know when to get up, when to start work, when to eat, when to walk the dog, when to collect the kids from school and many more things. However, when it comes to working out how many seconds until a given time it can be complicated. So many times, I have been faced with that fact a server can only be rebooted between this time and that time. If your work-place does not have a NOC team then it's not ideal to be either waiting after-work for that time or staying up late just to reboot a server at a given time. Again this has saved my :bacon: bacon loads of times using a good old **shutdown /f /r /t xxx** to reboot a server with the x's representing the number of seconds. For instance, if it is 4pm and you get told the server has to be rebooted at 10pm I know that I am looking at rebooting that server in 6 hours time.
**(New-TimeSpan -Start (Get-Date) -End (Get-Date).AddHours(6)).TotalSeconds**
Maybe that number is too frightening to look at and you just wanted a whole number instead of all the crazy decimal places. Again we can force PowerShell to use the built in **[math]** type accelerator to access the underlying .Net System.Math class.
**[math]::Round((New-TimeSpan -Start (Get-Date) -End (Get-Date).AddHours(6)).TotalSeconds,0)**
Now I could just **invoke-command** to that server to execute the shutdown in 6 hours which we know will be **21600** seconds time. **Invoke-Command Server1 {shutdown /f /r /t 21600}**
and I can enjoy the rest of my evening without worrying about rebooting the server at the specific time given.

## Out-GridView :computer:

The other day I logged onto a server which another engineer was working on, I saw that the had opened CMD.exe and had typed something along the lines of **pnputil /enum-drivers** to locate a driver on the server. However it made me feel a bit sea-sick watching them scroll up-and-down frantically trying to locate the given driver. So as I was on a Teams call with this other engineer I asked what they were looking for, I only got a part of the name, which then made me think about outputting all the results to Out-GridView and searching for that partial name. I know I could have used **Where-Object** but felt I could definitevely show this using a GUI output. So I used the following command to get all the drivers on the system we were both logged onto:

**Get-CimInstance Win32_PnPSignedDriver | Out-GridView** 

which then allowed me to type in the search at the top this partial name of the driver. Much easier than scrolling up-and-down, up-and-down.  Well at least in my opinion. I had to ask if they knew about the Out-GridView which the answer was no, but now they do!  Now you also know about this great visual output too!

## Select-String :open_book:

I look after 200+ scripts, as well as thousands of servers, and I do get asked quite frequently if there is a script that does something on a particular server, or if there is a script that looks at a specific application.  Well although I love my scripting I have inherited a lot of scripts when I took the job, so cannot remember every single script and what is inside that script, or which server might be in a script. Again PowerShell shines with the amazing **Select-String** cmdlet. So all I have to do to search through all the PowerShell scripts in a given folder for the 'keyword' I am after is:

Get-ChildItem C:\ScriptsFolder -recurse -filter *.ps1 | Select-String "keyword" | Select Path -unique

Obviously you will need to substiitute the path to the directory containing your files, and filter on the extension you know the keyword could be located in, but this will then return you the full file names of any matches it finds. Again nice and simple but super-handy to locate a specific word in a file. In this case recusively searching through all .PS1 PowerShell files.

## Here-String :registered:

So I remember a while ago, I got asked to assist a devloper on some code and why it was not working as planned. It just so happened that this script was doing a lot of database querying and was mental to see the layout of the PowerShell code with all the various quoting. Now I know not all scripts involve query databases, but if this devloper knew about **Here-String** in PowerShell I think it would have made their life a lot easier when writing the script. As instead of using numerous speech-marks to put the query in they could have done something like:
```# ps1
$dbQuery = @"
Select *
From Customers
Where Country = 'UK'
"@
```
So if you ever need to use something in your script to call multiple lines of text, which you want preserved in that exact layout, then the **Here-String** is the thing to use. 


## Something to share :musical_note:

So I remember the 90s of being the era when dance music was really popular, and super piano rifts that just made you want to get up and dance. So I have been making a lot of YouTube videos with the synths I own, and well this is my latest tune I put together.  I hope this brings back some happy memories if you. 

https://www.youtube.com/watch?v=UG7-WIotzIw