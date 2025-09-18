---
branding:
  title: "Powershell Blog"
authors:
 - name: Adam Bacon
   email: adambacon1@hotmail.com
date: 2025-09-17
icon: dependabot
label: AI Assistant
order: 87
---

# Powershell Magic [!badge variant="warning" text="Back once again with the Powershell :bacon: flavour"]

## Random Ramble
So I get hooked on things, and once I am hooked I will spend a lot of time on the thing that has hooked me. So till recently this was making music in my spare time. I have always loved music but never really knew much on music theory, so I got hooked learning this and how to construct your own tunes within the DAW you use to make music. Then more recently I purchased some portable music equipment a chord synth, and a groovebox. Hence I keep dropping the something to share at the end of these blogs.

So the other night it got me thinking about these realistic videos that people are using AI to make for them, and some of them are really good or very believable the way they are done.  I mean think back to older 80s movies and the special effects compared to today are awful, but at the time it looked great. To have the power to use AI to make these amazing looking videos, is really mind blowing to me. Maybe in 30+ years these to will look really lame in comparison to the tech available. Hopefully I will live long enough to see that day.

Anyways the reason I am rambling is not only to fill up page space but share some of my own AI videos, but using the images I have also used AI to generate and included in previous blog pages, but I was amazed at from just a single image what AI could then produce from that. This is a video of the image I normally put at the top of each blog page, the PowerShell hero. With an upside-down PowerShell logo.

**If I was superhero I would certainly be saying things like this**

https://www.youtube.com/watch?v=xZnO9Sx4NLQ

## AI Help
Yes it has changed the way things are now being done since AI has been released to the public. Lots of companies are embracing AI and making it do the work for them, or using it to streamline processes to get faster results for either the business or end customer. Again it has also put certain people out of work, because now there is a dedicated AI assistant to do the work. A bit like the new self-service checkouts they have at many superstores these days, I am sure they have put people out of work too. As normally just one person monitoring all the self-service checkouts rather than having to employ someone for each checkout, now maybe 20 checkouts are all being used but now only one staff member managing them all. 

Although AI might not always produce 100% usable results, it certainly can assist you with building ideas.  I mean if AI was about when I got learning PowerShell it would feel like the holy grail, but at the same time I would not be able to spot the possible mistakes in the code it might produce, it might then have made me more reliant on AI other than the paper back books I bought to get me started. Even though when I read some of those books not much of it made sense, but I knew if I kept reading eventually things would stick in my brain. So please if you have started your journey scripting, and thinking of quitting after a few weeks or months because you still cannot write scripts first time, or the process takes days. That's fine, just keep learning you will get better, I should be living proof of that. 

This is another reason I write these blogs to hopefully encourage you as the reader to keep learning as I totally relate to this being a very long journey up a very steep mountain.  You will eventually reach the top by sticking to the goal of learning and climbing up that mountain by solving obstacles you are presented with using PowerShell and the things you have learnt.


https://www.youtube.com/watch?v=8FpeVFaF0S0

## Winners don't use AI
Back in the day that was Daley Thompson saying **Winners don't use drugs**, so to put a different spin on that switching drugs to AI as they are kind of similar as in if you rely on them to get through life then you will become a shell of the person you were. Not knowing how to use your own mind to get through the day and tapping into a new source of pure steriods aka AI.

Then again if you use it in moderation or for medical needs then I know it will help. Like since being diagnosed with ADHD I know without those pills every morning my brain does react differently, which then makes me act differently, maybe making rash decisions, or saying something before thinking of the impact of what you said and how you said it would have. 

By no means am I encouraging anyone to use drugs especially illegal ones, but today we are going to use AI to hopefully give us a boost when we need one, more like a good cup of tea in the morning, nothing better to start my day than a cup of tea

I like to think of AI as a side-kick. Because every good superhero always has a handy sidekick to help them out. This is how I see AI, as a sidekick to help me when my powers are running out, or I need a second opinion on something. I do struggle at times to find the solution, but I know I won't stop until I got that solution, and with the internet being as large as it is today, even with good googlefu searching techniques it can still sometimes take a very long time, to finally land on that webpage you were looking for that has a detailed solution to the exact same problem you are facing. 

## Let's get coding
A short while ago I spent £10 on API credit for https://platform.openai.com/ to be able to write my own assistant. Sadly this did not quite go to plan as I didn't read the small print, to realise I could not use the assistant to pull me back live results from the internet. However I ended up using google to build a custom search engine which then I could use PowerShell to use that and pull back the results automatically, then get AI to give me further insight on the results returned. 

To follow along with this, you will need API access to the AI of your choice. I mean even if you are stuggling financially like I have through the majority of my life, to spend just £10 on something you will certainly get amazing value for your money compared with the cost of living these days. As in you could burn £10 on literally nothing these days, where-as the amount of tokens you will get in your API bundle for £10, will certainly be worth it in my opinion. 

You might be thinking well I do not need to invest in API because the AI I use is free on the website. Yes that is true, but can you help automatically to influence the AI and automatically store the results it has produced as a .PS1 file in the directory of your choice?

Last night I got thinking about this side-kick approach, and thought of it from two different angles. The first being I might have some code, but I might want my side-kick to review and improve the code where possible. Or that same script might keep throwing an error that you want help on correcting, as you cannot quite figure it out.

The second idea was that maybe I don't have the script written yet, but I have an amazing idea for a script, and I would like that side-kick to help make my idea become reality by writing me the code to do it.

Then if that code written for me does not work, and produces an error, I could then re-run the function with the first parameter set on providing the script-file and the error it gives to then focus my side-kick on producing me a fully working script. 

## Code 

```ps1 #
<#
.SYNOPSIS
Invokes OpenAI's GPT model to either refactor an existing PowerShell script or generate a new one from a description.

.DESCRIPTION
This function sends a structured prompt to the OpenAI API to assist with PowerShell script generation or refactoring. It supports two modes:
- **FilePathSet**: Refactors an existing script, optionally fixing a known error.
- **DescriptionSet**: Generates a new script based on a user-provided description.

.PARAMETER FilePath
Path to the file containing code to refactor (if applicable).

.PARAMETER ErrorCode
Allows you to specify the error you are getting in the FilePath you provided for your script

.PARAMETER Description
Description of the task for generating new code.

.PARAMETER OutputFile
Output file name for saving results (default is "GPT_Output.ps1").

.EXAMPLE
# Refactor existing code in a specified file
Invoke-GPTCodeAssistant -FilePath "C:\Scripts\OldScript.ps1"

.EXAMPLE
# Refactor with Error Context
Invoke-GPTCodeAssistant -FilePath "C:\Scripts\OldScript.ps1" -ErrorCode "AccessDeniedException"

.EXAMPLE
# Generate a New Script from Description
Invoke-GPTCodeAssistant -Description "Create a script that monitors disk space and sends an email alert if usage exceeds 90%"

.EXAMPLE
# Specify Custom Output File to automatically save the script response provided
Invoke-GPTCodeAssistant -Description "List all running services and export to CSV" -OutputFile "ServicesReport.ps1"

.NOTES
- Requires the `OPENAI_API_KEY` environment variable to be set.
- Uses the `gpt-4o-mini` model via OpenAI's chat completion endpoint.
- Automatically extracts annotated code from markdown-style output.
- Designed for modular integration into automation pipelines or dev tooling.

#>


function Invoke-GPTCodeAssistant {
    [CmdletBinding(DefaultParameterSetName = "FilePathSet")]
    param(
        # FilePath mode: refactor existing script
        [Parameter(Mandatory=$true, ParameterSetName="FilePathSet")]
        [string]$FilePath,

        # Optional error code to tell GPT what went wrong
        [Parameter(Mandatory=$false, ParameterSetName="FilePathSet")]
        [string]$ErrorCode,

        # Description mode: generate new script from description
        [Parameter(Mandatory=$true, ParameterSetName="DescriptionSet")]
        [string]$Description,

        # Optional output file name
        [Parameter(Mandatory=$false)]
        [string]$OutputFile = "GPT_Output.ps1"
    )

    if (-not $env:OPENAI_API_KEY) {
        throw "Please set the OPENAI_API_KEY environment variable before running."
    }

    $headers = @{
        "Authorization" = "Bearer $env:OPENAI_API_KEY"
        "Content-Type"  = "application/json"
    }

    # Build GPT prompt depending on parameter set
    switch ($PSCmdlet.ParameterSetName) {
        "FilePathSet" {
            if (-not (Test-Path $FilePath)) {
                throw "File '$FilePath' does not exist."
            }
            $codeContent = Get-Content $FilePath -Raw

            if ($ErrorCode) {
                $userPrompt = @"
You are an expert PowerShell developer.
The following script produced an error with the code: $ErrorCode
Please fix the underlying issue in this code and refactor it.
Add a synopsis at the top and include inline comments explaining each line.
Script:
$codeContent
"@
            } else {
                $userPrompt = @"
You are an expert PowerShell developer.
Please refactor this code, add a synopsis at the top, and include inline comments explaining each line.
Script:
$codeContent
"@
            }
        }
        "DescriptionSet" {
            $userPrompt = @"
You are an expert PowerShell developer.
Please write a PowerShell script that accomplishes the following task:
$Description
Include a synopsis at the top and inline comments explaining each part of the code.
"@
        }
    }

    # Call OpenAI API
    $body = @{
        model = "gpt-4o-mini"
        messages = @(
            @{ role = "system"; content = "You are an expert PowerShell developer and code reviewer." },
            @{ role = "user"; content = $userPrompt }
        )
    } | ConvertTo-Json -Depth 10

    Write-Host "Sending request to OpenAI API..." -ForegroundColor Cyan
    $response = Invoke-RestMethod -Uri "https://api.openai.com/v1/chat/completions" -Headers $headers -Method Post -Body $body

    $annotatedCode = $response.choices[0].message.content

    # Extract code from ``` if present
    $match = [regex]::Match($annotatedCode, '```(?:powershell)?\s*(.*?)```', [System.Text.RegularExpressions.RegexOptions]::Singleline)
    if ($match.Success) {
        $justCode = $match.Groups[1].Value
    } else {
        $justCode = $annotatedCode
    }

    # Save to file
    Set-Content -Path $OutputFile -Value $justCode
}
```

- Parameter Sets: Uses [CmdletBinding()] with named parameter sets to enforce mutually exclusive modes (FilePathSet vs DescriptionSet).

- Environment Check: Validates presence of OPENAI_API_KEY early to avoid unnecessary execution.

- Prompt Construction: Dynamically builds a GPT prompt tailored to the selected mode and optional error context.

- API Call: Uses Invoke-RestMethod to send a chat-style request to OpenAI’s endpoint with structured roles (system, user).

- Markdown Parsing: Extracts code from triple-backtick blocks if GPT returns annotated markdown.

- Output Handling: Saves the final code to disk and returns it as a string for further use or inspection.

Hopefully this will help you in your PowerShell journey or help you build your own AI side-kick by editing the code above to fit your needs. I know this is not ground-breaking as in a worlds' first PowerShell AI assistant, but again will help you work smarter and not harder.

## Something to share
I still love piano rifts in dance music and how they used to send tingles down my spin when I used to go to raves, which looking back really does seem  a life-time ago. To show my love for dance music and piano rifts I put this tune together I hope you enjoy :musical_note:

https://www.youtube.com/watch?v=XSKG5c6X3QU

Until the next blog stay safe, and see you again soon.