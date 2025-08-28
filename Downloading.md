---
branding:
  title: "Powershell Blog"
authors:
 - name: Adam Bacon
   email: adambacon1@hotmail.com
date: 2025-08-28
icon: cloud
label: Downloading
order: 90
---

# Powershell Magic [!badge variant="warning" text="Back once again with the Powershell :bacon: flavour"]

![Powershell is here to save the day|500](/images/ps.PNG)

## Puppy Update

![This is Miami who had his eyes tacked they are looking so good now|500](/images/miami.PNG)

Damn these puppies are costing me a fortune before I even fully sold one.  Another two pups needed their eyes tacking, so that set me back another £600, had them micro-chiped and jabbed the previous week was another £600.  Then plus the £1000 I spent getting three pups eyes tacked and yeah they are now all eating about 4 meals a day. Plus feeding the other 3 dogs I own and it's all stacking up.  Just proper thankful I am keeping my current job else I would be going crazy with all these vet bills, as over £2,000 spent out on vet bills alone.

Right moan over, lets tackle a new problem using the mighty PowerShell with a little bit of :bacon: added. 

## New Problem

So today I was reading my personal emails after work, and got an email from **MIDIKLOWD** about a bundle offer they were doing. I certainly enjoy a bargin, and well this also seemed to good to be true, 188 midi and wav packs for £30 instead of £99. Each of these packs were being sold separately for like £10 each.  So in theory buying all these individually was £1,880.  So yeah I was like damn show me the goods, what do I get with this?

![MIDIKLOWD Bundle Offer|500](/images/midiklowdBundle.PNG)

After scrolling through the list I thought why not, was happy with the packs on offer and 188 was a crazy amount. I spent enough on vet bills might as well treat myself to something nice, but for a fraction of the price.

## What has this got to do with PowerShell?

Okay so the PowerShell will come shortly, but just wanted to explain the background to this issue, to see why I thought sod this I need some **Magic :bacon: PowerShell**. So After I bought the pack I got an email to download them, this then took me to a dedicated webpage with the 188 packs to download, but the issue was there wasn't one download all packs button, there was a 188 different links to click like so:

![MIDIKLOWD Bundle Offer Download Page|500](/images/midiklowd.PNG)

Another thing was these hyperlinks had a limited download time, so I needed to download these as soon as possible, else a number of days will pass, and the links would have expired. You should know by now, if there is one thing I detest is pointing and clicking.  I was thinking **damn** there is no-way I am sitting here like for hours clicking and downloading. Although to tell the truth I did start to download the first few, but the size of some of these packs were over 1GB so it was not going to be something that could be completed without watching a lot of paint drying so to speak.

Again I totally believe that computers are meant to do the hard or boring work, so us humans can do more interesting things, like writing the code to make the computer do the chore instead of you. Or even better spending the time you would of been manually downloading these links to write a blog about it to share with other PowerShell people out there. 

!!!
Top Tip: Pressing **CTRL + U** brings up the source code for the webpage you are on within the browser
!!!

I had inspected one of the hyperlinks prior to this, and this showed me where the file was being held.  Looking through the source code of the page I could see all the links began with something like: **https://bzglfiles\.s3\.ca-central-1** so the next plan was pressing **CTRL+A** to highlight all the webpage source code, then **CTRL+C** open up good old notepad and a **CTRL+V** to paste this into the notepad and then saving this text file in a memorable location. 

So now I had all the source code to the webpage containing the 188 links I needed to download in a dedicated text file. Next step was to get scripting a solution to obtain just the hyperlinks from this text file, then place the hyperlinks into their own text file. Having each hyperlink on a seperate line, then magically download each of the given hyperlinks to a specified location. Here we go a script to help me do just that: 

```ps1 #
# Define the input and output paths
$sourcePath = "$env:userprofile\Documents\page.txt"
$outputPath = "$env:userprofile\Downloads\midiklowd_links.txt"

# Create a Regex pattern to match href URLs pointing to amazonaws
$pattern = 'href="(https://bzglfiles\.s3\.ca-central-1\.amazonaws\.com[^"]+)"'

# Extract the matches from the above Regex expression  
$matches = Select-String -Path $sourcePath -Pattern $pattern -AllMatches | ForEach-Object {
    $_.Matches | ForEach-Object { $_.Groups[1].Value }
}

# Decode HTML entities and save each of these hyperlinks to a file
$decoded = $matches | ForEach-Object { [System.Net.WebUtility]::HtmlDecode($_) }
$decoded | Set-Content -Path $outputPath

Write-Host "Extracted $($decoded.Count) URLs to $outputPath"
```

## Next Step...

So this now produced me a text file containing each hyperlink on a line of its own. The final line of the code above outputted that 188 URLs had been extracted to the specified output file.  Now it was just a case of downloading each hyperlink which was a zip file then moving onto the next hyperlink to download within the text file containing each hyperlink on a seperate line. I wanted to download one link at a time, as I found the more you try and download then the total-speed is split across the amount you are downloading, I was able to hit 5MB a second downloading just one file at a time, rather than trying to download say 4 files and the speed then dropping to under a megabyte per second per file, as this meant the total time to download each file significantly increased. As I now had the list of hyperlinks to download, next step was to execute downloading each of those whilst I go walk the dogs.

```ps1 #
# Path to your list of URLs
$urlsPath = "$($env:userprofile)\Downloads\midiklowd_links.txt"

# Path to where you want to store the downloaded ZIP files 
$downloadFolder = "$($env:userprofile)\Downloads\MidiKlowdBundle"
New-Item -ItemType Directory -Path $downloadFolder -Force | Out-Null

# Read URLs and download one by one
Get-Content $urlsPath | ForEach-Object {
    $url = $_.Trim()
    if ($url -match "^https://bzglfiles\.s3") {
        $fileName = [System.IO.Path]::GetFileName($url.Split("?")[0])
        $destination = Join-Path $downloadFolder $fileName
        Write-Host "Downloading $fileName..."
        
        # Setup a try catch block to handle any errors, should there be a problem
        try {
            Invoke-WebRequest -Uri $url -OutFile $destination -UseBasicParsing -ErrorAction Stop
            Write-Host "Completed: $fileName`n"
        } catch {
            Write-Warning "Failed: $fileName"
        }
    }
}
```

![Saved a lot of hassle by automating all these downloads|500](/images/midiklowdBundle2.PNG)

## Mission Complete


So it did take longer than the dog walk took to download all 188 music midi packs, but this was a whopping 61.5GB of files, and so glad I didn't have to manually click each link and sit there staring at the screen whilst it downloaded, as that would have drived me nuts, with all that pointing and clicking and manually waiting. There were a few more steps to be done, as these were downloaded from the internet, under the properties of the file, you had the option to then unblock the file. I did not want to be doing this 188 times either, so thought simple, I will use PowerShell to do this, yes I do use aliases for cmdlets as makes it a lot quicker to type, but do not fall into bad habbits and make sure that all your production code uses full cmdlet names. 

```ps1 #
(gci -Path $env:USERPROFILE\Downloads\MidiKlowdBundle -Filter *.zip).fullname | % {Unblock-File $_ -Confirm:$false}
```

I could now use the **Expand-Archive** cmdlet to then extract each of these zips, I was a bit paranoid on doing this on all zips I downloaded as if they were 61.5GB zipped I am looking at it being bigger once un-zipped. Plus I wanted to spend time checking out these packs one-by-one and figured to do just that. Then spent a good couple of hours tonight listening to a few of these packs, instead of me spending that time just downloading each of these packs. 

I will make sure I add a video to this page once I record a mega mix of some of these new sounds I have purchased.

## Message behind this blog

![Powershell once again saved the day|500](/images/psman.PNG)