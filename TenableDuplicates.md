---
branding:
  title: "Powershell Blog"
authors: 
 - name: Adam Bacon
   email: adambacon1@hotmail.com
date: 2025-07-28
icon: codespaces
label: Tenable Duplicate Assets
order: 97
---
# Powershell Magic [!badge variant="warning" text="Back once again with the Powershell :bacon: flavour"]

Hello folks, yes this blog is a few days later than planned, and well there is a good reason for that. Unfortunately I was really sick :face_vomiting: all this weekend, but prior to that my wife had it Thursday night, then my youngest daughter, then my eldest daughter, then second eldest, then my third youngest daughter, then my second youngest daughter then I finally got it.  So was a very unpleasant twenty hours of that happening. Guess when you got a family my size and one of you gets ill then you are all bound to get it.

## Not feeling well
![](/images/sick.PNG)
!!!
Top Tip: Wearing a mask whilst puking your guts up is not a good idea.
!!!

Moving on swiftly let us talk about some more **Powershell magic** in applying a fix to the problem. 

## What was the problem?
 So the issue we are going to discuss is duplicate assets in Tenable. I know at first you may think well that has nothing to do with Powershell, and you are correct.  However I provided a solution using Powershell and the Tenable APIs to solve the given issue. 
Yes this is a problem that seems to have been talked about for years on the internet, but after spending time to look into the issue to see if there was a magic :mage: hotfix, or patch to apply to Tenable to resolve the issue and finding one did not exist. Then looking on various forums and seeing other Tenable customers were also suffering from this same issue, but no definitive resolution on how they solved it. 

[!ref Example of this problem](https://tenable.my.site.com/s/question/0D53a00006FccWECAZ/duplicate-assets-tenableio?language=en_US)

I did find that someone had set a particular registry entry to read-only which then meant Tenable had to use the next criteria to check if the machine is unique. This did make sense in my opinion but I had been informed that, that method had already been tried and did not work. 

## Contact the vendor
I wanted a proper Tenable solution to this, so I raised the support call with Tenable :telephone: who could confirm that the scanning to test if an asset was unique or not was done in this particular order (most useful information I was provided with):

1. Tenable UUID
2. BIOS UUID
3. MAC Address
4. NetBIOS Name
5. Fully Qualified Domain Name (FQDN)
6. IPv4 Address

 As the first option is checking the registry again that made sense to set that as read-only to force Tenable to try the next object in the list. Once again I was denied. 

 Although I had supplied numerous proof to Tenable that these duplicate assets existed, they wanted access and the passwords to look at the database. I asked for this information but as I was not supplied it from the securty team Tenable closed the call after 7 days of no reply.

 It did seem a bit :nut_and_bolt: **nuts that Tenable could not supply a fix to a problem that has existed for at least five years**, and just ask for access to your databases, instead of maybe providing checks to do in the database. Or checking specific scan settings, but sometimes it is what it is.
![Providing not so awesome support to paying customers](/images/joke.PNG)


 ## Plan B
 So although **plan A** did not go as planned, as in I was hoping the vendor would supply a permanent fix to the issue. I still had this issue with numerous duplicate assets in Tenable which I was also sure was affecting the CES **Cyber Exposure Score** by making this inflated as it was counting all the duplicates as unique assets, so any threats these duplicate assets had were being shown numerous times. :abacus:

 I had spent time :clock8: looking at a solution on the WWW and found only a potential solution to fix the issue, which I was not allowed to try as apparently it had already been tried. I had reached out directly to the vendor expecting some patch or specific setting which could be changed, but again the support I received, did not provide any information to solve this :cry: and **you** are still expected to fix the issue, seeming as **you** were the one who identified it. 

 I am not to good at planning things in a diagram format, but this was the plan in my head. **So my idea was grab all the assets that are in Tenable, dump them to a CSV file, then use a parameter to seach for particular naming conventions, group all those assets, sort them by descending order and skip the first result.** :exploding_head: Then all that are left in the group are duplicate assets that were not the most recently seen, meaning it was a stale duplicate record. 
![Provide your own solution to a problem, making sure it works](/images/planb.PNG)

  ## Research
  Despite the support I received from Tenable not being the best, as no answer could be provided, just more questions being asked to me. Tenable does have decent documentation on their API and how to use it:

  [!ref Tenable API documentation](https://developer.tenable.com/reference/navigate)
  
  There is quite a bit of information displayed here, due to there being a lot you can do in Tenable, and this provides the API way of doing each of those things. As hopefully you realise that I am not a :mouse: point and click type of guy.

  After looking at this documentation :yawning_face: I saw there was a method for exporting all the assets, and that is all I really needed as my idea I explained earlier would dump this information into a CSV as a lookup table for particular assets.

  ## Time to get cooking
  :male-cook: Unlike my previous post I wrote about, I knew from the get-go that I would most certainly be using this solution more than once to fix this issue, as sadly Tenable could never provide an answer to the problem.  As I know it was going to be used more than once, this to me made it worth while into making this into a function.  Maybe even two functions, one to gather all the Tenable assets, then another to find the duplicates.

  ```ps1 #
function Get-TenableAssets {
    [CmdletBinding()]
    param(
        # enter the output path to the CSV this must include .csv in the name
        [Parameter(Mandatory=$true,Position=0)]
        [ValidateNotNullOrEmpty()]
        $OutputCSV
    )
    #checking the parent directory exists to place the CSV in
    $parent = Split-Path $OutputCSV -Parent
    $csv = Split-Path $OutputCSV -Leaf
    if (-Not(Test-Path $parent -PathType Container))
    {
        Write-Host -ForegroundColor Yellow "The folder structure $parent does not exist, therefore the file $csv will not be created.  Exiting script"
        break
    }
    $accessKey = $YOUR_TENABLE_ACCESS_KEY
    $secretKey = $YOUR_TENABLE_SECRET_KEY
        $headers = @{
    "X-ApiKeys" = "accessKey=$accessKey; secretKey=$secretKey"
    }
    $headers.Add("accept", "application/json")
    $headers.Add("content-type", "application/json")
    $response = Invoke-WebRequest -Uri 'https://cloud.tenable.com/assets/v2/export' -Method POST -Headers $headers -ContentType 'application/json' -Body '{"chunk_size":4000}'
    $fileID = ($response.Content | ConvertFrom-Json).export_uuid
    $check = "https://cloud.tenable.com/assets/export/$fileID/status"
    do
    {
    write-host "checking report status, please wait this can take at least a good few minutes"
    $status = (invoke-webrequest -Uri $check -Method Get -Headers $headers).Content | ConvertFrom-Json
    Start-sleep -Seconds 120
    }
    until ($($status.status) -eq 'FINISHED')

    $Assetresponse = Invoke-WebRequest -Uri 'https://cloud.tenable.com/assets/export/status' -Method GET -Headers $headers
    $exports = $Assetresponse.Content | ConvertFrom-Json
    $exportuuid = $exports.exports[0].uuid
    $custom = @()
    $total = $exports.exports[0].total_chunks
    for ($i = 1; $i -le $total; $i++)
    { 
        Write-host "processing object $i of $total please wait..."
        $custom += (Invoke-WebRequest -Uri "https://cloud.tenable.com/assets/export/$exportuuid/chunks/$i" -Method GET -Headers $headers).content | ConvertFrom-Json
    }

    $custom  | select *id,@{n="last_seen";E={(Get-Date $_.timestamps.last_seen).ToString('yyyy-MM-dd')}},@{n="host";E={$_.network.hostnames}},@{n="ipv4";E={$_.network.ipv4s}},@{N="MAC";E={$_.network.mac_addresses}} | Export-Csv $OutputCSV -NoTypeInformation -Force
    write-host -ForegroundColor Green "All assets have now been exported to $OutputCSV"
}
  ```

  The above function will gather all the assets registered in Tenable and place them into a CSV. I know I am missing a help section I promise to do better on my next post, but as I was not publishing this anywhere, and I was going to be the one running it, I thought I should remember something like **Get-TenableAssets -OutputCSV C:\Temp\TenableAssets.csv** yes I know I could have used a more standard parameter like **path** or something similar, but I decided that **OutputCSV** was good enough for the job. This was my function after all. The more assets you have the longer this function will take to run. 

 Now I needed another function to actually sort the duplicates from the CSV file. Yes I know excel has this built-in to highlight duplicate values, but you would still then need to extract the UUID of the asset to delete, and I did not want to delete all duplicates, as I wanted to keep the one unique one, which would be the most recently seen by Tenable. 

  ```ps1 #
function Get-DuplicateTenableAssets {
param(
    # enter the full path to the CSV you wish to check for duplicates C:\Temp\TenableAssets.csv
    [Parameter(Mandatory=$true,Position=0)]
    $CSV,
    # enter a search pattern to search on like SERVER to find all SERVER duplicates
    [Parameter(Mandatory=$true,Position=1)]
    $Search
    )
    $custom = import-csv $CSV
    $search = $custom | ? {$_.host -match "$Search"} | select id,last_seen,host,ipv4
    $groupResults = $search | group -Property host | ? count -gt 1
    foreach ($item in $groupResults)
    {
        $currentHost = $($item.Name)
        Write-host "Processing $currentHost which in tenable has $($item.count) occurances of this same machine"
        $filter = $item.Group | Sort last_seen -Descending | Select -ExpandProperty id -Skip 1
        foreach ($item in $filter)
        {
            Write-Host "Removing $currentHost with the tenable_uuid of $item"
            $accessKey = $YOUR_TENABLE_ACCESS_KEY
            $secretKey = $YOUR_TENABLE_SECRET_KEY
            $headers = @{
                "X-ApiKeys" = "accessKey=$accessKey; secretKey=$secretKey"
            }
            $headers.Add("accept", "application/json")
            $headers.Add("content-type", "application/json")
            $body = @"
{
    "query": {
        "field": "host.id",
        "operator": "eq",
        "value": "$item",
        "hard_delete": true
    }
}
"@
    Invoke-WebRequest -Uri 'https://cloud.tenable.com/api/v2/assets/bulk-jobs/delete' -Method POST -Headers $headers -ContentType 'application/json' -Body $body
        }
    }
}
```

## Solution
By extracting all the Tenable assets with **Get-TenableAssets** function which I only needed to run once.  Then I could use the second function **Get-DuplicateTenableAssets** to search for various naming conventions that I knew duplicates fell under. Although I did not lower the CES as much as I might have hoped, this did go down by at least 15 points. If you work with Tenable you may also know that say fixing 500+ assets with a problem, might only lower the CES score by 1 point.  When I looked at it like that it did make me feel a bit better, and also proved to the doubters in the security team that the duplicate assets were indeed inflating the CES within Tenable. :boom:

## Something to share
Yes it is more music I want to share that I put together. I am sure that if you work in IT you most likely played arcade games or oldskool console games when you were younger.  So please enjoy this chiptune inspired music I put together :musical_note:

https://www.youtube.com/watch?v=3t7_y22pO1w




