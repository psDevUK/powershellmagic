---
branding:
  title: "Powershell Blog"
authors:
 - name: Adam Bacon
   email: adambacon1@hotmail.com
date: 2025-09-05
icon: flame
label: Runspaces
order: 89
---

# Powershell Magic [!badge variant="warning" text="Back once again with the Powershell :bacon: flavour"]

![Powershell is here to save the day|500](/images/ps.PNG)

## Puppy update

So after 5 of the 7 pups having to have their eyes tacked, and costing me over £2,500 in vet bills, the first puppy went to her new forever home, the couple are lovely and have a big garden and really nice house. So know she will be treated like a princess. I got 2 boys being sold tonight to a son and dad. So again nice that the two brothers will see each other even though with seperate people, and again really happy with the son and dad buying these as both were nice people who have previously owned a Shar Pei.

I mean it is so sad to see so many older Shar Peis being re-homed, to me a dog is for life, not for covid, or till circumstances change. Enough said on that as personally do not think there are enough laws to protect animals in the UK.  Like let us just say I know a family with a guide dog that is never walked, and left sometimes for 24 hours or more all alone, frquently being left at home all day alone. Mentioning no names, but to me this is neglect of the dog that was trained to improve someones life and yet their life (the dog) is now being made a living hell. But after looking this up apparently it is not illegal to never walk your dog.  Which to me is nuts as that is all part and parcel of owning a dog, I mean I walk mine 3 times a day, in my opinion there is no excuse not to walk your dog. Well enough moaning about bad dog owners, lets move on to this blogs topic.

![Feel so sorry and sad for this dog never being walked and left at home all day most days|500](/images/dog.PNG)

## Runspaces

I know I might not be famous, or an MVP like IT famous, but I have had good feedback on the blogs I been doing, which inspires me to write more. I had Cody reach out on LinkedIn for the one line of code in my last blog about unblocking files. I was like thanks, is there anything I could write a blog on which would interest you more. 

So folks we got Cody to thank for this blog. It is all going to be about runspaces in PowerShell and what they are and how to use them.

Now sadly I am not a genius who knows everything, so spoiler alert, I did do a tiny bit of research to make sure I could confidently write about something and also sound like I know what I am on about. Like I never finished college and never went to university to study, so literally just hold GCSEs to my name, as not everything made sense to me being taught in a room, by a person who can maybe only explain that subject or topic in their particular way and could never provide another easier to understand method.  For me having like a real-world comparison to compare that topic to greatly helps me understand it better. So here we go on me trying to compare it to something that is not PowerShell but will give you a visual concept in your head to understand it. So without rambling on to much let us first address the big question.

## What is a PowerShell runspace

![DupliKate from Invincible comics is like a runspace, one person (PowerShell session) able to spawn multiple versions of herself (runspaces) to complete the task quicker. Simple right.|500](/images/duplikate.PNG)

Runspaces are lightweight, isolated execution environments where PowerShell code can run independently. Think of them as threads tailored for PowerShell, allowing you to:

- Run multiple tasks simultaneously without launching separate powershell.exe processes.
- Maintain shared context (e.g., variables, modules) across threads if needed.
- Handle asynchronous execution with better control than background jobs.

They are especially useful when you're building automation that needs to scale such as pinging thousands of endpoints, processing logs, or running compliance checks across a large amount of machines. Runspaces are your new best friend to help complete the task/script in a much more timely manner.

!!!
**Do not worry let us break this down into a real-world scenario that you can relate to**
!!!

## Real-world scenario

Imagine PowerShell as a your local super-store (script), and every time you run a script, you are collecting the items you want to buy. Normally in this super-store, there is only one person working on the till to serve the customers (your main PowerShell session) working on one customer at a time. (single thread)

If like me and you hate waiting in queues, wouldn't it be great if that one person could serve multiple people at the same time, but it cannot because it is a single person aka thread and can only process one customer at a time. (or object like a computer)

So lets say the owner of this store comes in and sees the amount of people queuing to be served and thinks why don't I hire more staff to work on the different tills (runspaces), if I get three more staff working on tills we will be able to serve 4 customers at the same time.(runspace pools)

This in essence is exactly what runspaces are. The ability to have multiple check-out staff (multiple threads) all working in parallel, each serving their own queue of customers which then makes me as a customer checking out quicker to be processed as instead of just one person and one long queue, there is now a choice of 4 different tills to go to, which gets the job of paying for your items (running your script) a quicker process to complete. Each of these checkout staff is the equivalent to a runspace they are all different people working on their own till (runspace) but still all part of the same super-store (script). 

Hopefully after reading the above explanation this has allowed you to picture this in your head what runspaces are and how they can use multiple threads aka checkout staff to allow your PowerShell script aka the super-store a better way to process more customers (objects) instead of using the normal single thread, as in one checkout staff.

I am bad for this, as normally when I write code, say to apply a given fix to a list of computers, I process the list of computers (customers in the queue) in a foreach loop (single thread) and apply what needs doing in the script to the current item in that foreach loop processing one item at a time. Now hopefully you can see doing it this way is like having that single checkout worker on the till, and the list of computers to be processed in that foreach loop is like the queue of customers waiting to be served, PowerShell will only process one computer at a time, as by default it is just using a single thread to do the work you want doing.

Hopefully this is getting you thinking tell me more about runspaces, and I will, just hold on and keep reading. 

## Runspaces break-down
!!!
**Without runspaces:** One checkout staff member serves one customer at a time. Meaning customers wait longer to be served.
!!!
!!!
**With runspaces:** More checkout staff, each with their own checkout till. Serving multiple customers at once. Less time to be served
!!!

In PowerShell terms referring to the super-store example. Each runspace is a dedicated check out staff member with their own till which is the equivalent to a runspace.

Your main script is the super-store with customers shopping, picking items to buy. You can create a runspace pool, which is the same as hiring  multiple checkout staff members and using them to keep the queues as low as possible to be processed. Hopefully reading it like this will clarify the mystery behind runspaces and when to use them, and the benefits using runspaces. If not keep reading to find out more benefits of using them:

- **Speed:** Allows you to run things that need to be processed such as a list of computers in parallel. For example pinging 100 computers in one swoop instead of processing one computer at a time.
- **Efficiency:** By implementing run spaces is way more memory efficient than say launching 5 different PowerShell.exe consoles to work on. Runspaces use less memory than a console session.
- **Control:** Allowing you to manage what each runspace does, tracking the progress, and handling any errors that may occur.

Hopefully this is getting you thinking wow, I need to start using runspaces, but you maybe also thinking are runspaces compatible with the version of PowerShell I use?

## What versions of PowerShell support runspaces?

Believe it or not but runspaces are backwards compatible all the way from PowerShell version 2, up until the most recent, PowerShell version 7, lets break this down into a table to see this more easily.


PowerShell Version | Runspace Support |	Notes
---                |  ---             |   ---
v2.0	           | Supported	      | Legacy support; heavier syntax
v3.0–v5.1	       | Supported	      | Improved performance and syntax
PowerShell 7+	   | Supported	      | Still valid, though ForEach-Object -Parallel is often preferred for simple parallelism

## Code Example

As I admitted earlier, my normal choice of processing things is to do it in a foreach loop, so to keep this simple lets say I want to get all the services which are set to automatically start but are not currently running

```ps1 #
# Define your list of servers
$servers = @("Server01", "Server02", "Server03", "Server04", "Server05",
             "Server06", "Server07", "Server08", "Server09", "Server10")
# Process each computer one computer at a time
foreach ($server in $servers) {
    Get-Service -ComputerName $server | ? {$_.StartType -match "Automatic" -and $_.Status -ne "Running"}
}
```

Yes this works and as we are only processing 10 machines in this given case it probably won't take too long, but what if that list was 10,000 computers. That is a prime example of using the runspace method to process these, even if it does require a bit more code. Again to keep things simple, let us re-code the first example to then re-write this with using it with runspaces.

```ps1 #
# Define your list of servers
$servers = @("Server01", "Server02", "Server03", "Server04", "Server05",
             "Server06", "Server07", "Server08", "Server09", "Server10")

# Create a runspace pool
$runspacePool = [runspacefactory]::CreateRunspacePool(1, 5)  # Min 1, Max 5 threads
$runspacePool.Open()

# Create a collection to hold runspace jobs
$runspaces = @()

foreach ($server in $servers) {
    $powershell = [powershell]::Create()
    $powershell.RunspacePool = $runspacePool

    # Add the script block and pass the server name
    $powershell.AddScript({
        param($srv)
    # Add try catch block for error handling
        try {
            Get-Service -ComputerName $srv -EA Stop | ? {$_.StartType -match "Automatic" -and $_.Status -ne "Running"}
        } catch {
            [PSCustomObject]@{
                Server = $srv
                Error  = $_.Exception.Message
            }
        }
    }).AddArgument($server)

    # Start async execution
    $runspace = @{
        Pipe     = $powershell
        Status   = $powershell.BeginInvoke()
        Server   = $server
    }
    $runspaces += $runspace
}

# Collect results by creating an empty array to store the results in
$results = @()
foreach ($runspace in $runspaces) {
    $output = $runspace.Pipe.EndInvoke($runspace.Status)
    $results += $output
    $runspace.Pipe.Dispose()
}

# Close the runspace pool
$runspacePool.Close()
$runspacePool.Dispose()

# Display results
$results | Format-Table -AutoSize
```

Yeah there is a fair amount more code to type to run the same script using a runspace, but surely if this will allow your scripts to run quicker and get the end result quicker it is worth investing that time, and as we are only using a simple one line of code. As in finding all services on each given machine that should have started but are not currently running. Then, effectively the above example could be used as a template to just remove that one line of code, and add the code you want to process for your list of objects.

In the example above we have set it to effectively use up to 5 different checkout members of staff, and as the queue is only 10 customers long, as that is the amount of computers specified to process, in a perfect world 2 customers per queue, which as you can hopefully visualize will mean super quick checkout time. However your brain may also be thinking well how many runspace pools can I create?  This does depend on a few factors of the machine you are running the code from, so lets look at the below table to understand those factors.

Factor	                   | Impact
---                        | ---
CPU cores                  | More cores = more threads you can run efficiently
Memory	                   | Each thread consumes memory; too many can cause thrashing
Task complexity            | Lightweight tasks (e.g., pinging) scale better than heavy ones (e.g., file I/O, WMI queries)
Network latency	           | If tasks are mostly waiting on network responses, you can afford more threads
Thread management overhead | Too many threads can overwhelm the main thread managing them

Boom, I think that is a rap on runspaces what they are when to use them, and how to use them. Thank you for attending my class today on runspaces, it has been great to write this, and hopefully it has been insightful for you. Once again shout-out to Cody for asking for this to be blogged about. Mission complete.

## Something to share

I don't know why it took me as long as it did. But finally hooked up my J-6 to my DAW as an output midi, which then allowed me to identify the notes way easier than the manual. This then got me jamming, so I hope you enjoy the synthwave tune I put together last night :musical_note:

https://www.youtube.com/watch?v=Gt4MVWVGcfE

Till next time stay safe and take care.