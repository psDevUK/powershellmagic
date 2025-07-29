---
branding:
  title: "Powershell Blog"
authors: 
 - name: Adam Bacon
   email: adambacon1@hotmail.com
date: 2025-07-29
icon: bell
label: Nessus Plugin ID 63155
order: 96
---
# Powershell Magic [!badge variant="warning" text="Back once again with the Powershell :bacon: flavour"]

## Welcome Back

Today we will cover another tale from the depths of the IT world on how Powershell can save your :bacon: when being tasked with a problem to solve. To me the main problem is, the :mouse: and a crazy amount of sysadmins out there prefer to use this :mouse: to point and click there way through any issue. I think some people must see it as their sword to fight off all the problems swaying it about all day and using a lot of the working day using this :mouse: of theirs to click there way through any given problem.  

![Do not worry people I have my mighty point and click mouse to save the day](/images/mouse.PNG)

People the year is not 1995 anymore, it is 2025 and to me the :mouse: is just a big drain on the time it takes to fix the problem. Plus leading to possible errors clicking on the wrong item or object and then leading to more delays or possible issues. Then with the amount of servers some people look after, like myself this number is a bit under 3,000 then to say fix even 200 of this number with a specific fix taking the point and click route is just going to take forever. 

## Microsoft Windows Unquoted Service Path Enumeration

I will be looking at a particular threat that exists out in the wild-west of Windows and how using a bit of :brain: power and the mighty Powershell to resolve this issue in a flash. More information on this threat can be found right here:

[!ref Nessus Plugin ID 63155](https://www.tenable.com/plugins/nessus/63155)

Again what I do not understand is for a paid for product like Tenable they do provide you with a solution for most of the issues, but the solution is like so half-assed in my opinion just like this particular issue we are focusing on today. Like if this only affects Windows boxes, and requires the same fix to be applied as in placing quotes around the service path which contains spaces, then why the heck does Tenable not provide a Powershell solution to the problem? As all Windows boxes these days run Powershell, and even if your company is still running on 2008 servers or something crazy like that, you can still use Powershell. 

The only benefit of the paid for version of Tenable is that it will identify the service at fault, allowing you to specifically go to that particular area. I do not know how much Tenable costs, but it does seem bonkers that a massive anti-threat provider cannot provide the solution to make things easier for sysadmins out there who might not be able to write their own non-point-and-click solution to the given problem.

## Break it down

No I do not mean perform run DMC dance-off moves I mean lets break this problem down. 

1. It affects Windows machines
2. It is related to a service having spaces in the path
3. It will always be in the same registry location

Armed with this information and a little bit of thinking, this seems a perfect time to cook up a delicious script to fix the issue. So I might have only 20 machines to fix, but setting up remote desktop to each of those machines, then logging on, then opening the registry, then navigating to the specific registry area, then tracking down the exact service which needs quotes around it, all seems way over-kill. Especially if it really affects say 200 machines now your looking at spending possibly days doing the same mind-numbing point and click routine. Not good use of your skils or :brain: power.

![A bit like riding a super-powered bike, whilst scraping a ninja sword along the ground. Total over-kill except this looks super-cool over-kill, you pointing a clicking your mouse will never look this cool](/images/nemesis.PNG)

## My Solution

So for a long-time Powershell has supported the **Invoke-Command** cmdlet to make life less point and clicky, by allowing you to run commands against remote computers. However this does rely on you having certain 'things' configured for this to happen correctly, one of these being that port 5985 is accessible on the remote machine from the machine you are running these commands. 

I also built my own Tenable dashboard, to make it easy to find all machines with a particular pluginid threat, and the ability to the export those machines to a CSV from the mighty **Powershell Universal** which is an **AMAZING** product. So I visit my dashboard I type in the plugin id for this problem which then gives me all the affected machines. I then export that list to a CSV so I have an array of machine names to apply this given solution to. 

Going to use a handy function I use in a lot of my scripts when running commands remotely against remote machines to make sure the machine has the port 5985 open before trying to **invoke-command** as again this can slow down your script considerably waiting for this to time out, when you could just do a simple check prior to make sure that the required port is open to allow remoting. 

The script starts off defining this handy function **Test-Port** which will then load it into memory to allow you to use it throughout that powershell session you are running. 

Next I am defining the array of Windows machines this fix needs to be applied to which was gained through Tenable.

As the exact same thing needs to be done on each machine although the service name may vary I took the approach of using a regular expression with the knowledge that the services in question are running off of the **C:** drive. This allowed the solution to not rely on me having to specify a specific path, and use a more one-size-fits-all approach to the method. 

Any unquoted services found, will then have the needed speech quotes put around them. :boom: 

**Mission Accomplished** :sunglasses:


```ps1 #
function Test-Port 
{
    param (
        [string]$Computer,
        [int]$Port = 5985,
        [int]$Millisecond = 2000  # Set your desired timeout in milliseconds
    )

    # Initialize a TcpClient object
    $Test = New-Object -TypeName Net.Sockets.TcpClient

    # Attempt connection with the specified timeout
    $result = $Test.BeginConnect($Computer, $Port, $null, $null).AsyncWaitHandle.WaitOne($Millisecond)

    # Cleanup
    $Test.Close()

    # Return the result (True if successful, False otherwise)
    return $result
}

$Machines = @(
"Server1",
"Server2",
"Server3",
"Server4"
)

foreach ($Machine in $Machines)
{
    if (-not(Test-Port -Computer $Machine -Port 5985))
    {
        write-Host -ForegroundColor Yellow "Cannot connect to $Machine"
    }
    else
    {
        write-Host "Processing $Machine for unquoted reg service paths" -ForegroundColor Green
        $servs = invoke-command -Computer $Machine -ScriptBlock {Get-ChildItem 'HKLM:\SYSTEM\CurrentControlSet\Services' | Select -ExpandProperty Name | % {Split-Path $_ -Leaf}}
        $output = invoke-command -Computer $Machine -ScriptBlock{
            foreach($service in $using:servs)
            {
                try{
                    $value = Get-ItemPropertyValue "HKLM:\SYSTEM\CurrentControlSet\Services\$service" -Name ImagePath -ErrorAction Stop
                    [pscustomobject]@{
                        Service = $service
                        RegistryPath = "HKLM:\SYSTEM\CurrentControlSet\Services\$service"
                        ImagePath = $value
                        Machine = $(hostname)
                    }  
                }
                catch{
                    Write-Host -foreground Yellow "The path does not exist $($error.exception.message)"
                }
                
            }
        }
        $Total = ($output.imagepath | Select-string "^C:\\.*\s.*exe").count
        if($Total -ge 1){
            Write-Host -ForegroundColor Yellow "I have found a total of $Total services with spaces in the paths unquoted"
            $output = ($output | ? ImagePath -Match "^C:\\.*\s.*exe" | Select Machine,ImagePath,RegistryPath,Service)
            $output
            for ($i = 0; $i -lt ($Total - 1); $i++)
            { 
                Write-Host "Fixing $($output[$i].RegistryPath) on machine$($output[$i].RegistryPath) please wait..." -ForegroundColor Green
                $Machine = $($output[$i].Machine)
                $RegistryPath = $($output[$i].RegistryPath)
                $currentValue = $($output[$i].ImagePath)
                $newValue = """$currentValue"""
                Invoke-Command -ComputerName $Machine -ScriptBlock {
                    Set-ItemProperty $using:RegistryPath -Name ImagePath -Value $using:newValue -Verbose            
                }
            }
        }
    }
}
```

## Thank you 

Thanks for taking the time to read this blog, and if you work for Tenable and you need someone to provide easy-to-use solutions to the vulnerabilities your software exposes then please get in touch as looking for new job opportunities. On that note, will leave you with some chilled out music I made a little while back. 

https://www.youtube.com/watch?v=7JwBj5krhwI
