---
branding:
  title: "Powershell Blog"
authors:
 - name: Adam Bacon
   email: adambacon1@hotmail.com
date: 2025-08-23
icon: rocket
label: Selenium
order: 91
---

# Powershell Magic [!badge variant="warning" text="Back once again with the Powershell :bacon: flavour"]

![Powershell is here to save the day|500](/images/ps.PNG)

## What is Selenium?

So Selenium is a tool to automate the web browser you use. This does not come included in Windows and you will need to download a few things to get this party started. The more modern method seems to be playwright, but to use that I would need to be coding in playwright and then running the script for playwright. 

As I want to keep as PowerShell focused as possible Selenium allows you to use code straight from your code editor. Although this is not using PowerShell cmdlets it is using the dotnet from PowerShell to control various aspects. If you have not dabbled with Selenium before then if you follow along this should be something cool to add to your PowerShell toolkit in automating web browsing.

I know you might be thinking well why would I want to automate browsing the web? Do not worry we will get to that shortly. 


## How do I get Selenium?

Okay so your interested in getting selenium? Good I can walk you through this, it's not too complicated. Firstly I am only going to describe the process for Microsoft Windows users, not because I do not like other operating systems, but this is the operating system I prefer and use over other operating systems. 

Also I am just going to focus on Microsoft Edge. It is the browser I use, and it is built into modern Windows Operating systems. If you are still on Internet Explorer then you need to stop using that as it got retired a long time ago. 

So on the root of my C:\ drive I created a folder/directory called **WEBDRIVER** if you are following along I would recommend to do the same. Then I downloaded the latest Microsoft Edge driver.  You can obtain that from the link below

[!ref Download the Microsoft Edge Driver here:-](https://developer.microsoft.com/en-us/microsoft-edge/tools/webdriver/?form=MA13LH)

After you downloaded this, add the executable to the newly created **WEBDRIVER** directory, then add this path aka **C:\WEBDRIVER** to the computers Path variable in advanced system options. 

As your Microsoft Edge browser should be up-to-date you now need to download two more things to get this rolling

[!ref Download the Selenium Web Driver here:-](https://www.nuget.org/packages/Selenium.WebDriver)

Once this is downloaded and extracted place this into the same **C:\WEBDRIVER** directory. Then finally you need to download and rinse and repeat with the following selenium support package.

[!ref Download the Selenium Support package from here:-](https://www.nuget.org/packages/Selenium.Support)

All these things should now be living in the newly created directory, and that newly created directory should be added to the system PATH built-in variable

I appreciate this is a few hurdles to jump before using Selenium but once it is done which does not take long you can now use this awesome automated web browser tool.

## What was the problem?

Although I have nothing against job-sites as they help you find employment and applying for jobs. As you know I hate pointing and clicking my way through life, so would it not be awesome to run a script, that would go to a particular job-site and then automatically accept the cookies and log you in, and then set the criteria for the type of work you are looking for, then automatically apply for all the jobs, then automatically move through the pagnation at the bottom of the page and rinse and repeat the job applying process. Yes hopefully you can see why this would be beneficial as it can potentially allow you to apply for a crazy amount of jobs without you having to do anything other than run the script.

So the problem for me was manually having to use a job-site to manually search and apply for jobs.  I know you might think I am just being lazy, but I wanted to get my CV out there to as many agencies as possible to increase my chances of getting employed. So as I truely believe computers were built to do the hard work for us, lets make your computer crunch some applications for us. 

![Everyone needs a knight in armor to come save the day|500](/images/stgeorge.png)

## What was the solution?

I ended up writing a function to complete this task of searching and applying for jobs for me. I have included a synopsis, but I just want to clarify I was using **PowerShell 7** to run this function, and I also added the following to my **PowerShell 7 Profile aka the $profile**

```
$env:SeleniumPath = 'C:\WebDriver\'
$env:SeleniumDriver = 'C:\WebDriver\Selenium.WebDriver.4.34.0\lib\netstandard2.0\WebDriver.dll'
$env:SeleniumSupport = 'C:\WebDriver\selenium.support.4.34.0\lib\netstandard2.0\WebDriver.Support.dll'
```

I also added my email address and password as shown in the example, but obviously not going to post this here. Please note this only works for **https://www.totaljobs.com/** which is one of the sites I found a good number of **UK** based jobs on. I did need to spend time right clicking certain fields or links to obtain the unique ID for that element, then was able to use Selenium to do all the hard work for me.  You could look at using this as a template and modifying the various HTML element IDs to a job-site you use if you are based outsite the United Kingdom. 

## Find-TotalJobs Function

```ps1 #
<#
.Synopsis
   Automates applying for jobs on totaljobs.com
.DESCRIPTION
   Uses Selenium and Powershell to automate the applying for various jobs on totaljobs.com this will only automatically apply for jobs that do not require you to go to the external company website
.EXAMPLE
   Find-TotalJobs -SeleniumSupportFilePath $env:SeleniumSupport -SeleniumDriverFilePath $Env:SeleniumDriver -SeleniumPath $env:SeleniumPath -Email $env:emailaddress -Password $env:totaljobsPassword -JobTitle "powershell" -JobType 'Work From Home'
.EXAMPLE
   Find-TotalJobs -SeleniumSupportFilePath $env:SeleniumSupport -SeleniumDriverFilePath $Env:SeleniumDriver -SeleniumPath $env:SeleniumPath -Email $env:emailaddress -Password $env:totaljobsPassword -JobTitle "Infrastructure Analyst" -JobType 'Permanent' -Location 'Devon'
.NOTES
   You need to have Selenium downloaded and configured prior to using this function as it relies on Selenium to do the hard work for you
.COMPONENT
   The component this cmdlet belongs to is KNight of the round-table Sir Adam Bacon
.FUNCTIONALITY
   Automatically apply for numerous jobs without you having to do it, on totaljobs.com
#>
function Find-TotalJobs
{
    [CmdletBinding()]
    Param
    (
        # Enter the full path to where you have the WebDriver.Support.dll for Selenium on your system
        [Parameter(Mandatory=$true,Position=0)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({if (-not (Test-Path $_)) {throw "$_ is not a valid path to the dll file needed"}return $true})]
        [System.IO.FileInfo]$SeleniumSupportFilePath,

        # Enter the full path to where you have the WebDriver.dll for Selenium on your system
        [Parameter(Mandatory=$true,Position=1)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({if (-not (Test-Path $_)) {throw "$_ is not a valid path to the dll file needed"}return $true})]
        [System.IO.FileInfo]$SeleniumDriverFilePath,

        # Enter the full path for the system path to the Selenium folder containing the msedgedriver.exe
        [Parameter(Mandatory=$true,Position=2)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({if (-not (Test-Path $_)) {throw "$_ is not a valid path to the dll file needed"}return $true})]
        [System.IO.FileInfo]$SeleniumPath,

        # Enter your email address that you have registered with on TotalJobs.com
        [Parameter(Mandatory=$true,Position=3)]
        [ValidateScript({if ($_ -notmatch '^[^@\s]+@[^@\s]+\.[^@\s]+$'){throw "'$_' is not a valid Email address"}return $true})]
        [string]$Email,

        # Enter your password for the TotalJobs website
        [Parameter(Mandatory=$true,Position=4)]
        [ValidateNotNullOrEmpty()]
        [String]$Password,

        # Enter the job title of the job you are looking for such as "Infrastructure Analyst"
        [Parameter(Mandatory=$true,Position=5)]
        [ValidateNotNullOrEmpty()]
        [String]$JobTitle,

        # Enter the job location you are looking to obtain a job in, such as Devon
        [Parameter(Position=6)]
        [String]$Location,

        # Optional selecting the type of work you are looking for
        [Parameter(Position=7)]
        [ValidateSet("Permanent","Work From Home","Contract","Part Time")]
        [String]$JobType,

        # Optional to select to return jobs that meet a particular salary
        [Parameter(Position=8)]
        [ValidateSet("30,000","40,000","50,000","60,000","70,000","80,000","90,000")]
        [String]$JobSalary,
        
        # Optional to select the start page that the searches begin on, this is from the pagnation along the bottom this is defaulted to 1 but can be changed
        [Parameter(Position=9)]
        [int]$StartPage = 1,

        # Optional to select the end page that the searches end on, this is from the pagnation along the bottom this is defaulted to 7 but can be changed
        [Parameter(Position=9)]
        [int]$EndPage = 7
    )

    Begin
    {
        # Load Selenium DLLs
        Add-Type -Path $SeleniumSupportFilePath
        Add-Type -Path $SeleniumDriverFilePath

        # Setup Edge driver
        $edgeOptions = New-Object OpenQA.Selenium.Edge.EdgeOptions
        $service = [OpenQA.Selenium.Edge.EdgeDriverService]::CreateDefaultService("$SeleniumPath")
        $driver = New-Object OpenQA.Selenium.Edge.EdgeDriver($service, $edgeOptions)

        # Create WebDriverWait (10 seconds timeout)
        $wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait($driver, [TimeSpan]::FromSeconds(10))

        # Step 1: Navigate to jobsite page and accept cookies
        $driver.Navigate().GoToUrl("https://www.totaljobs.com/account/signin")

        try {
            $cookieAcceptButton = $wait.Until([System.Func[OpenQA.Selenium.IWebDriver, OpenQA.Selenium.IWebElement]] {
                    param($d)
                    try {
                        $el = $d.FindElement([OpenQA.Selenium.By]::Id("ccmgt_explicit_accept"))
                        if ($el.Displayed -and $el.Enabled) { return $el }
                    }
                    catch {
                        return $null
                    }
                    return $null
                })
            if ($cookieAcceptButton) {
                $cookieAcceptButton.Click()
                Start-Sleep -Seconds 1
            }
        }
        catch { }
        # Enter email
        $emailField = $wait.Until([System.Func[OpenQA.Selenium.IWebDriver, OpenQA.Selenium.IWebElement]] {
        param($d)
        try {
            $el = $d.FindElement([OpenQA.Selenium.By]::CssSelector("input[data-testid='email-input']"))
            if ($el.Displayed) { return $el }
        }
        catch { return $null }
        return $null
        })
        $emailField.Clear()
        $emailField.SendKeys("$Email")

        # Enter password
        $passwordField = $wait.Until([System.Func[OpenQA.Selenium.IWebDriver, OpenQA.Selenium.IWebElement]] {
                param($d)
                try {
                    $el = $d.FindElement([OpenQA.Selenium.By]::CssSelector("input[data-testid='password-input']"))
                    if ($el.Displayed) { return $el }
                }
                catch { return $null }
                return $null
            })
        $passwordField.Clear()
        $passwordField.SendKeys("$Password")

        # Click login button
        $signInButton = $wait.Until([System.Func[OpenQA.Selenium.IWebDriver, OpenQA.Selenium.IWebElement]] {
                param($d)
                try {
                    $el = $d.FindElement([OpenQA.Selenium.By]::CssSelector("button[data-testid='login-submit-btn']"))
                    if ($el.Displayed -and $el.Enabled) { return $el }
                }
                catch { return $null }
                return $null
            })
        $signInButton.Click()
        Start-Sleep -Seconds 3

        # Search Field
        $searchField = $wait.Until([System.Func[OpenQA.Selenium.IWebDriver, OpenQA.Selenium.IWebElement]] {
                param($d)
                try {
                    $el = $d.FindElement([OpenQA.Selenium.By]::CssSelector("input[data-at='searchbar-keyword-input']"))
                    if ($el.Displayed) { return $el }
                }
                catch { return $null }
                return $null
            })
        $searchField.Clear()
        $searchField.SendKeys("$JobTitle")

        if($null -ne $Location)
        { 
        # Location Field
        $searchField = $wait.Until([System.Func[OpenQA.Selenium.IWebDriver, OpenQA.Selenium.IWebElement]] {
                param($d)
                try {
                    $el = $d.FindElement([OpenQA.Selenium.By]::CssSelector("input[data-at='searchbar-location-input']"))
                    if ($el.Displayed) { return $el }
                }
                catch { return $null }
                return $null
            })
        $searchField.Clear()
        $searchField.SendKeys("$Location")
        }

        # Click Search button
        $searchButton = $wait.Until([System.Func[OpenQA.Selenium.IWebDriver, OpenQA.Selenium.IWebElement]] {
                param($d)
                try {
                    $el = $d.FindElement([OpenQA.Selenium.By]::CssSelector("button[data-at='searchbar-search-button']"))
                    if ($el.Displayed -and $el.Enabled) { return $el }
                }
                catch { return $null }
                return $null
            })
        if ($searchButton) { Write-Host "Button found, clicking..." } else { Write-Host "Button not found." }
        $searchButton.Click()


        if($null -ne $JobType)
        {
            $wfhElement = $wait.Until([System.Func[OpenQA.Selenium.IWebDriver, OpenQA.Selenium.IWebElement]] {
                    param($d)
                    try {
                        $el = $d.FindElement([OpenQA.Selenium.By]::XPath("//a[@data-at='facet-link' and normalize-space(text())='$JobType']"))
                        if ($el.Displayed -and $el.Enabled) { return $el }
                    }
                    catch { return $null }
                    return $null
                })

            # Click the link if found
            if ($wfhElement) {
                Write-Host "Clicking link..."
                $wfhElement.Click()
            }
            else {
                Write-Host "Link not found or not clickable."
            }
        }
        if($null -ne $JobSalary)
        {
            # Wait for the salary filter link to appear by data-at attribute
            $salaryLink = $wait.Until([System.Func[OpenQA.Selenium.IWebDriver, OpenQA.Selenium.IWebElement]] {
                param($d)
                try {
                    $el = $d.FindElement([OpenQA.Selenium.By]::XPath("//a[@data-at='facet-link' and normalize-space(text())='at least £$($JobSalary)']"))
                    if ($el.Displayed -and $el.Enabled) { return $el }
                }
                catch { return $null }
                return $null
            })

            if ($salaryLink) {
                Write-Host "Clicking 'at least £$JobSalary' salary filter..."
                $salaryLink.Click()
            } else {
                Write-Host "Salary filter not found."
            }
        }
        #Page should now only contain the matching jobs for the criteria selected

    }
    Process
    {
        # Get the new URL
        $currentUrl = $driver.Url
        Write-Host "Navigated to: $currentUrl"

        # Now you can use this as your base for pagination
        $page = $StartPage
        $maxPages = $EndPage

        while ($page -lt $maxPages) {
            $pagedUrl = "$($currentUrl)?page=$page"
            $driver.Navigate().GoToUrl($pagedUrl)
            # Get all job links
            $jobLinks = $driver.FindElements([OpenQA.Selenium.By]::CssSelector("a[href*='/job/']"))
            # Store the original tab
            $originalTab = $driver.CurrentWindowHandle
            foreach ($link in $jobLinks) {
                $href = $link.GetAttribute("href")
                if ($href -and $href.StartsWith("https://www.totaljobs.com/job/")) {
                    Write-Host "Opening: $href"
                    # Open job tab
        $driver.ExecuteScript("window.open(arguments[0], '_blank');", $href)
        Start-Sleep -Seconds 1

        # Switch to job tab
        $jobTab = $driver.WindowHandles[-1]
        $driver.SwitchTo().Window($jobTab)

        try {
            $applyButton = $wait.Until([System.Func[OpenQA.Selenium.IWebDriver, OpenQA.Selenium.IWebElement]] {
                param($d)
                try {
                    $el = $d.FindElement([OpenQA.Selenium.By]::CssSelector("button[data-testid='harmonised-apply-button']"))
                    if ($el.Displayed) { return $el }
                } catch { return $null }
                return $null
            })

            if ($applyButton) {
                $buttonText = $applyButton.Text.Trim()
                $isDisabled = -not $applyButton.Enabled

                if ($isDisabled -and $buttonText -match "Already applied") {
                    Write-Host "Already applied — skipping job."
                    $driver.Close()  # Close job tab
                    $driver.SwitchTo().Window($originalTab)
                } else {
                    Write-Host "Button found, clicking..."
                    $handlesBefore = $driver.WindowHandles
                    $applyButton.Click()
                    Start-Sleep -Seconds 3

                    # Detect new tab
                    $handlesAfter = $driver.WindowHandles
                    $newTabs = $handlesAfter | Where-Object { $handlesBefore -notcontains $_ }

                    if ($newTabs.Count -gt 0) {
                        Write-Host "New tab detected — switching and closing..."
                        $driver.SwitchTo().Window($newTabs[0])
                        Start-Sleep -Seconds 1
                        $driver.Close()  # Close new tab
                        $driver.SwitchTo().Window($jobTab)
                        $driver.Close()  # Close job tab
                        $driver.SwitchTo().Window($originalTab)
                        continue  # Skip rest of logic
                    }

                    # Proceed with sendApplication
                    $nextButton = $wait.Until([System.Func[OpenQA.Selenium.IWebDriver, OpenQA.Selenium.IWebElement]] {
                        param($d)
                        try {
                            $el = $d.FindElement([OpenQA.Selenium.By]::CssSelector("button[data-testid='sendApplication']"))
                            if ($el.Displayed -and $el.Enabled) { return $el }
                        } catch { return $null }
                        return $null
                    })

                    if ($nextButton) {
                        Write-Host "Clicking 'Send Application'..."
                        $nextButton.Click()
                        Start-Sleep -Seconds 6
                    } else {
                        Write-Host "No follow-up button found — skipping job."
                    }

                    $driver.Close()  # Close job tab
                    $driver.SwitchTo().Window($originalTab)
                }
            }
        } catch {
            Write-Host "Error finding apply button: $_"
            $driver.Close()
            $driver.SwitchTo().Window($originalTab)
        }
                }
            }
            $page++
        }
    }
    End
    {
        Write-Host "Script Finished..."
    }
}
```

## Boom another task smashed using PowerShell 

Yes I could have made this function better, I could have done more things with it, but it ticked the boxes I needed at the time and as this was a personal project I did not want to be spending a long-time putting this altogether. The longest part of this task was mainly finding all those pesky unique IDs for the various web-elements I needed to interact with, by right clicking on that element on the webpage then choosing inspect, and inspecting the code to find the unique ID to identify just that element.

I know this was a tad different from the work dilemma problems I have been documenting, but this was still a real-world problem and it was work related in a way as in obtaining employment.

Thankfully after using this and getting my phone ringing quite a bit the following day, which proved it really did work in getting me noticed by recruitment agencies, I had a last moment save in my current position.  I was due to finish working for my company on the 22nd of this month. It was a really sad time as this has been my first dream job I have had, and it ticks all the boxes for me, so to find another job like the one I currently got was difficult. Due to living in the middle of no-where now, this also really restricted the jobs I could apply for, as many of the jobs I could have applied for were at least a 6 hour drive one-way.  So factor in traffic, and the return journey plus the full day at work, I would be working including travelling for over 20+ hours a day. This would have been impossible to do in the long run, and I would never get to see my 5 daughters and wife, as we all live together. Honestly getting that call to give me the option to stay was like the best thing that has happened.

## Something to share

As always I got some beats to share if you fancy a listen. :musical_note: This is throw-back beat I done to celebrate when music sounded good, and life was more simple. :musical_note:

https://www.youtube.com/watch?v=4W_JyVGVhLU