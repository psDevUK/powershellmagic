---
branding:
  title: "Powershell Blog"
authors:
 - name: Adam Bacon
   email: adambacon1@hotmail.com
date: 2025-08-15
icon: file-code
label: Querying Nutanix
order: 91
---
# Powershell Magic [!badge variant="warning" text="Back once again with the Powershell :bacon: flavour"]

## Another book idea :bulb:

![That feeling you might get at work being the go-to person to ask for things no-one else can do|500](/images/workload.png)

## Quick puppy update :dog:

As you know I had to get 3 of my puppies eyes tacked, well the two boys had both eyes done, but Frost the female only had one eye done, as the other eye was open and had no issues. However the day after the operation less than 24 hours, the eye that had not been tacked as it was fine was now closed up. Got back in contact with the vet who wanted to leave it for at least a month, due to the pup being so young and the dangers involved putting them under general anaesthetic. However after a week we went back to the vet for take 2 at this. Thankfully the pup went another round like the champ she is, and now has two fully open eyes. Frost is such a nice happy dog, no wonder the mrs wants to keep this one.

![Frost now has two open eyes, this picture was before the operation, when she was sleeping|500](/images/frost.jpg)


## The problem querying Nutanix :confused:

So nothing comes as a surprise to me at work, and on this particular day I got informed that we had a 3rd party looking after Nutanix, which was news to me. However there was a problem that they could not gather all the VMs on the different Nutanix prism servers. 

Okay well why was I suddenly being told this information? It transpired that the 3rd party company needed help in producing this list of VMs on each prism server.  Again you would kind of think well surely this 3rd party would be able to cook up something to solve this issue, as surely they must have other customers or have had this issue before?

Yes, your right to think that, but it wouldn't be another amazing Powershell blog if this was not now my problem to solve.  Let me get my costume ready...

![Stepping up to another challenge, let me go grab my cape, it's just another supreme day at work|500](/images/Supreme.png)

However I am always happy when people ask me to do something, mainly it gives me that confidence boost that they are asking you because they know you are capable of anything and being able to cook up scripts to solve any given issue.

I promise you this time you will be getting more than two lines of Powershell code, this should hopefully open the doorway to using Powershell and APIs. Now unlike VM Ware, Nutanix have not in my opinon done a great job implementing a Powershell module to make this task easy-peasy.  They do have a module, but this comes as an executable and well I personally could not get it working, it should have been a simple **Install-Module** but it turned into a mission to even be able to find the documentation, and the issues of it loading these as an executable and not getting it working, I turned to plan B. No that was not migrating the VM back to VM Ware where it is much easier to communicate with via a well designed Powershell module. No I went a different route, the only one I saw to be able to obtain the data requested

## The solution was to use the API :joystick:

So Nutanix has a half decent API documentation out there on their site, so this led to a bit of reading to understand how I could query this through Powershell and get the results this 3rd party company needed. After a bit of reading I cooked up the below script for them to run and produce the results.

```ps1 #
<#
.SYNOPSIS
    Retrieves a list of virtual machines from specified Nutanix servers and exports their details to a CSV file.

.DESCRIPTION
    This script connects to one or more Nutanix Prism Element clusters using provided credentials, retrieves information about virtual machines (VMs), and exports the VM names, IP addresses, and server names to a CSV file. It bypasses SSL certificate validation for API requests and supports multiple servers.

.PARAMETER Creds
    The PSCredential object containing the username and password for Nutanix API authentication. If not provided, prompts for credentials.

.PARAMETER Servers
    An array of Nutanix server hostnames or IP addresses to query. Defaults to a predefined list of five servers.

.NOTES
    - The script bypasses SSL certificate validation, which may pose a security risk in production environments.
    - The output CSV file is saved to C:\Temp\nutanix.csv by default.
    - Requires PowerShell and network connectivity to the Nutanix Prism Element clusters.

.EXAMPLE
    .\Get-NutanixMachines.ps1 -Creds (Get-Credential) -Servers @("nutanixserver1", "nutanixserver2")

    Prompts for credentials and retrieves VM information from the specified Nutanix servers.
#>
param(
    [Parameter(Mandatory = $true)]
    [PSCredential]$Creds = $(Get-Credential),

    [Parameter(Mandatory = $false)]
    [string[]]$Servers = @("nutanixserver1", "nutanixserver2", "nutanixserver3")
)

# Using credential information to use in script.
$accessKey = $Creds.UserName
$secretKey = $Creds.Password

# Convert the secure string password to plain text for API authentication
$BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($secretKey)
$ptp = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
$credPair = "$($accessKey):$($ptp)"

# Adding the TrustAllCertsPolicy class to bypass SSL certificate validation
Add-Type @"
    using System.Net;
    using System.Security.Cryptography.X509Certificates;
    public class TrustAllCertsPolicy : ICertificatePolicy {
        public bool CheckValidationResult(
            ServicePoint srvPoint, X509Certificate certificate,
            WebRequest request, int certificateProblem) {
            return true;
        }
    }
"@

# Bypass SSL certificate validation
[System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12  

# Create empty array to store results to
$names = @()
$cluster = @()
foreach ($server in $servers)
{
    Write-Host "Please wait processing the server $server this will take a moment..."
    $con = Test-Connection $server -Count 1
    $server_ip = $($con.IPV4Address.IPAddressToString) # Use the IP according the API used. v2/v3/v4 works in PC. For PE, use v2/v3
    $encoded = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($credPair))
    $header = @{"Authorization" = "Basic $encoded"}
    $Payload = @{
        kind   = "vm"
    } 
    $JSON = $Payload | convertto-json 
    $method = "post"
    $uri = "https://${server_ip}:9440/api/nutanix/v3/vms/list"
    $cluster_response = Invoke-RestMethod -Uri $uri -Method $method -Body $JSON -ContentType 'application/json' -Headers $header
    switch ([int]$cluster_response.metadata.total_matches)
    {
        {$_ -ge 1000}  {write-host -ForegroundColor red "There is over 1000 entries in $server $($_) vms exist";$Total = [math]::Round($_/400,0)}
        {$_ -le 999 -and $_ -gt 500} {write-host -ForegroundColor yellow "There is over 500 entries in $server $($_) vms exist";$Total = [math]::Round($_/500,0)}
        Default {write-host -ForegroundColor green "There less than 500 entries in $server $($_) vms exist";$Total = [math]::Round($_/500,0)}
    }
    switch ($Total)
    {
        {$_ -eq 0 -or $_ -eq 1} {
            $Payload = @{
                kind   = "vm"
                length = 500
                offset = 0
            } 
            $JSON1 = $Payload | convertto-json
            write-host "Running query 1"
            $cluster += Invoke-RestMethod -Uri $uri -Method $method -Body $JSON1 -ContentType 'application/json' -Headers $header

        }
        '2' {
            $Payload = @{
                kind   = "vm"
                length = 500
                offset = 0
            } 
            $JSON2 = $Payload | convertto-json
            write-host "Running query 1"
            $cluster += Invoke-RestMethod -Uri $uri -Method $method -Body $JSON2 -ContentType 'application/json' -Headers $header
            $Payload = @{
                kind   = "vm"
                length = 500
                offset = 500
            } 
            $JSON3 = $Payload | convertto-json
            write-host "Running query 2"
            $cluster += Invoke-RestMethod -Uri $uri -Method $method -Body $JSON3 -ContentType 'application/json' -Headers $header
        }
        '3' {
            $Payload = @{
                kind   = "vm"
                length = 500
                offset = 0
            } 
            $JSON4 = $Payload | convertto-json
            write-host "Running query 1"
            $cluster += Invoke-RestMethod -Uri $uri -Method $method -Body $JSON4 -ContentType 'application/json' -Headers $header
            $Payload = @{
                kind   = "vm"
                length = 500
                offset = 500
            } 
            $JSON5 = $Payload | convertto-json
            write-host "Running query 2"
            $cluster += Invoke-RestMethod -Uri $uri -Method $method -Body $JSON4 -ContentType 'application/json' -Headers $header        
            $Payload = @{
                kind   = "vm"
                length = 500
                offset = 1000
            } 
            $JSON6 = $Payload | convertto-json
            write-host "Running query 3"
            $cluster += Invoke-RestMethod -Uri $uri -Method $method -Body $JSON6 -ContentType 'application/json' -Headers $header
        }
        Default {Write-Host -ForegroundColor Yellow "I cannot determine how many vms there were"}
    }
}
Write-host "Now collecting all the results and putting into a custom psobject please wait..."
$names += foreach ($item in $($cluster.entities)){
    $vmName = $item.status.name
    if($item.status.resources.power_state -eq "ON"){
        $vmIPs = (($item.status.resources.nic_list.ip_endpoint_list.ip) -replace "{|}","") -join "-"
    }else{$vmIPs = "PoweredOff"}
    [pscustomobject]@{Name = $vmName; IPs = $vmIPs; Cluster = $($item.status.cluster_reference.name)}
}
$names | Export-Csv C:\Temp\nutanix.csv -NoTypeInformation -Force
```

## Boom job done :boom:

![Just another day at work for Powershell Man taking on all challenges thrown his way|500](/images/PowershellMan.png)

After emailing the script to the 3rd party and informing how to run it, and showing a snippet of the output I got prior when I ran the script, I got the reply from the 3rd party that this was **perfect** and exactly what they wanted. 

## Party time :musical_keyboard:

Thanks to all the awesome people checking out my music on these blogs.  This accounted for 33% of my traffic to youTube so that was great to see I got people checking out my blogs and checking out the music I am sharing. So please enjoy this thow-back with a 90s dance theme to it. Was really happy with this combined the two Roland Compacts I own to create this unique mix-up :musical_note:

https://www.youtube.com/watch?v=6AJr7YvnASs

Until next time stay safe and take care.

