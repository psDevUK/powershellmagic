---
branding:
  title: "Powershell Blog"
authors:
 - name: Adam Bacon
   email: adambacon1@hotmail.com
date: 2025-09-11
icon: megaphone
label: WhatIf
order: 88
---

# Powershell Magic [!badge variant="warning" text="Back once again with the Powershell :bacon: flavour"]

![Powershell is your best friend for automation in my opinion|500](/images/ps.PNG)

## What If

This to me, kind of reminds me of certain comic covers from a series Marvel done back in the day. Although I do not read Marvel comics I still loved the idea of a what if scenario, and how it could have completely changed the outcome of the as world we know it today.

![A Marvel What If comic cover|500](/images/whatif.PNG)

Although we are not here to talk about comics I just wanted to share that nugget of information from me to you. 

In this blog I want to cover the **-WhatIf** parameter. As back in the day when I was learning PowerShell I was trying to cram in as much information as my brain could take, and well I guess I misread something or took it too literally that adding **[CmdletBinding()]** at the top of your function would automatically provide the standard parameters to your function such as the below listed parameters:

- -Verbose
Enables detailed output for debugging or informational purposes.

- -Debug
Provides debugging information during execution.

- -ErrorAction
Specifies how errors are handled (e.g., Stop, Continue, SilentlyContinue, etc.).

- -ErrorVariable
Captures error messages into a specified variable.

- -WarningAction
Controls how warnings are handled.

- -WarningVariable
Captures warning messages into a specified variable.

- -OutVariable
Stores output in a specified variable.

- -OutBuffer
Specifies the number of objects to buffer before sending them through the pipeline.

- -WhatIf
Simulates the execution of the command, showing what would happen without making changes.

- -Confirm
Prompts for confirmation before executing an action.

Yeah my bad, I obviously missed something back in the day when I originally read this. Although these standard default parameters are available after adding **[CmdletBinding()]** to get the **Confirm** and **WhatIf** working correctly you do need to do a little extra coding to make this fully work as intended. This is what we are going to cover in this blog, as well as carrying on a little **runspace** magic as an additional parameter set, as the last blog covered runspaces. I thought I could add some extra-spice to the code I am going to share today to hopefully give you some inspiration on things you can do using PowerShell.

Also wanted to emphasize the use of the **-WhatIf** parameter and why you should be using it more in your PowerShell code, especially if you are modifying anything with **Add-,New-,Remove-,Set-** named cmdlets. As these are implementing a change, and wouldn't it be nice to know what will change before actually doing the change. As this could prevent you making a big mistake accidentally applying a change to the wrong item.

## Cmdlet Naming

Again another gotcha for me when learning PowerShell a long time ago, was thinking why is everything in singular on the cmdlet namings. Having used PowerShell for like over 15 years, I get why it was done like this as you are dealing with objects and for instance the cmdlet **Remove-Item** is just built to do exactly what it says, just to remove one item. Yes you could **Get-ChildItem** of a directory to get all the files in that directory, then pipeline this to a **Foreach-Object** then remove all of those files in that directory. However this needs you as the end-user to have a bit of knowledge on pipelining one cmdlet to another. So this got me thinking **What if the Powershell Team used plurals instead of singular cmdlet naming** 

![If only this comic was made, how awesome would that have been|500](/images/comic_cover.png)

I know this would not have as big of an impact as some of the What If comics out there, but it might have made sense for more people like myself when I was learning PowerShell many years ago.

So I will turn that idea into reality by creating a new function to act as a standard cmdlet but I will use the plural naming convention. Today folks we will cover **Remove-Items** a brand new advanced function I made especially for this blog, and implementing the **-WhatIf** parameter to run inside this function. To make this function more powerful and more like a true PowerShell cmdlet, we will add different parameter sets to enable the function to be run using traditional single thread approach, or having the ability to run the same function but using different parameters to enable the mighty runspaces feature to allow the end result to be processed a lot faster. However I did face a small PowerShell gotcha obstacle to overcome first

## Planning

In my personal opinion it is better to plan your functions before writing them, as you could possibly write the function then think damn, what if I had of included that capability or added this parameter, but the code is done already and your co-workers might be like kids in the back of a car, "Are we nearly there yet?" that pressure might then lead you to release the code into production without it being the best it could be. 

I do try an follow PowerShell best practices as this does make your code better, but maybe next time before just blindly writing out code, think about all the things you want your function to do and the parameters you will need, and maybe another whole set of parameters to use to have multiple parameter sets for the end-user to run depending on their scenario. 

Let us start small then increase the code as we go to fully understand implementing the **-WhatIf** into your functions. So lets drill it into our brains what we need to include as a minimum to get the **-WhatIf** working

```ps1 #
function Get-CurrentDate {
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Low')]
    param ()

    if ($PSCmdlet.ShouldProcess("System Clock", "Retrieve current date")) {
        $currentDate = Get-Date
        Write-Output "Current date is: $currentDate"
    } else {
        Write-Output "WhatIf: Retrieving current date would return the current system date. As in $(Get-Date)."
    }
}
```

So step one is we need to include something additional information inside the normal **[CmdletBinding()]** which gives the standard parameters in your function like discussed in the bullet points earlier. To include the **-WhatIf** and make it work, we need to add the following within the **[CmdletBinding()]** to **[CmdletBinding(SupportsShouldProcess = $true)]** which will let PowerShell know we want to support the **-WhatIf** and **-Confirm** parameters, I ended up adding **ConfirmImpact = 'Low'** but,  **this is not required, to have this function supporting WhatIf and Confirm** I just figured as a best practise to include this, and will explain in a bit why.

Next we need to determine if the **-WhatIf** parameter has actually been passed in by the user running the function. So to do this bit of magic we can use a simple **if / else** block to determine if it was passed or not. The **IF** code runs if **-WhatIf was not passed** but we still need to explain what will happen on the target aka the computer clock in this case, and the action it will take using this code **$PSCmdlet.ShouldProcess("System Clock", "Retrieve current date")** so with this bit of code we are saying, this is what the function would do if we ran this command without a whatif. As in the target we are going to deal with is the **System Clock** and the action that will be taken **Retrieve the current date** 

It might seem confusing on the else block of the code running when the **-Whatif** parameter was passed. The reason why it doesnt run in the if statement of the code is due to **$PSCmdlet.ShouldProcess** will be **$true** if **-Whatif was not used** thus making **$PSCmdlet.ShouldProcess to $false** if the user did supply the **-Whatif** parameter. 

As a bonus as it stands this function also supports the **-Confirm** parameter if supplied to confirm you want to actually run the function. In the script I share in a moment, you will notice an extra few things nested within **[CmdletBinding()]** which is the **DefaultParameterSetName** as I have the ability to call the function using either one parameter set or another parameter set, and specify the name of your parameter set you want to make the default one is why you would include this. Also as the function I am about to share, will change something on the system as in delete files, I have set the **ConfirmImpact** to high to reflect this, as the default **$ConfirmPreference** is set to high by default, so the end user will be prompted to confirm the action about to happen even if they did not specify **-Confirm**

Due to this function only reading the current date and not modifying anything, I have reflected that with **ConfirmImpact = Low** so unless the **-Confirm** parameter is passed to the function it will not prompt you for confirmation, but we could have left this out entirely, and the **-Confirm** parameter would have still worked, but just thinking about making it more understandable, and following best practises.  This is why you would use the **ConfirmImpact** within the **CmdletBinding** to specify the impact it could have on the system, and if it is automatically prompting you to confirm or not when running. 

Take the function just listed **Get-CurrentDate** as a core building block to implementing **-WhatIf** and **-Confirm** parameters like a double whammy into your functions for that extra bit of spicy ricey flavour.  Making your function behave more like an official PowerShell cmdlet.

As mentioned think about the parameters you will want to be available to your end-user running a function you design. If you maybe include too many parameters then break those down into specific parameter sets, or if you only want parameters x and y to be availble running it one way, and parameter z as the only choice if the function is to be run another way.  Parameter sets within functions allow the end user to use your function using parameter A set, or parameter B set and maybe even parameter C set depending on the amount of parameters you have, and if you only want parameters to be available in a certain way when running the function.  In the code I am about to share, I wanted the ability to either remove files using a single thread or multiple run-spaces to make it a bit like pressing that nitro button you wish you had in your car. 

Please look at the synopsis it is following best practises to include these in your functions or scripts to give the end user an idea about what the code will do, and examples of using the function.  I have added comments within the code to explain little bits of code at a time, but the main thing about this for me was implementing the **-WhatIf** parameter in either parameter set passed.

## Note to self

!!!
PowerShell runspaces do not natively support the -WhatIf parameter. The -WhatIf parameter is a feature of cmdlets and advanced functions that implement the ShouldProcess method. Runspaces, on the other hand, are a lower-level construct used for running PowerShell code in parallel or asynchronously, and they do not inherently understand or process -WhatIf.

However, you can design the scripts or cmdlets executed within a runspace to support -WhatIf by implementing ShouldProcess in those scripts or cmdlets. This way, the logic for -WhatIf is handled within the code being executed, not by the runspace itself.

If you need to simulate -WhatIf behavior in a runspace, you would need to explicitly pass the -WhatIf parameter to the cmdlets or functions being executed within the runspace, assuming they support it.
!!!



## Remove-Items

The moment you have all been waiting for, the code section. Originally I was just going to make this a lot more simple. However I thought the code would not live up to the PowerShell language if it was not super powerful. So I thought about things that could go wrong when using this function, like the directory path specified not existing, if no files were returned in the directory specified then there would be nothing to remove. Giving the ability to filter on particular file-types, which could then be more useful to the end user if a particular directory keeps filling up with say *.LOG files, then you got the ability to delete all those files using the one cmdlet instead of piping the output to another cmdlet to do the work. I then thought about the stupid amount of times you get the windows timer showing you the progress of deletions when deleting large amounts of files via the GUI, and wouldn't it be super powerful to make that super fast by using runspaces to process the deletions in batches to make it quicker. Finally wanted to make sure that the **-WhatIf** parameter really did work in both the different parameter sets defined within the function. I did use this function last night when testing it, and damn this removed things quicker than the time it takes to blink your eyes, it really is that fast.

!!!
Disclaimer: I want you to understand that this is removing files. So please do not go off and try this on a mission critical server, then send bad karma my way, please test on a personal device deleting none important files first, and using the -WhatIf parameter to make sure you 100% understand how to use this and the consequences of using it.  Thank you.
!!!

```ps1 #
<#
.SYNOPSIS
Removes files from a specified directory, optionally using parallel processing.

.DESCRIPTION
The Remove-Items function deletes files from a given directory path, with support for filtering file names and recursive search. It can operate in standard mode or parallel mode, allowing for faster deletion of large numbers of files using runspaces. The function supports WhatIf and Confirm prompts for safe operation. Although Confirm is redundant when using parallel mode.

.PARAMETER Path
The path to the directory containing files to remove. Must be an existing directory.

.PARAMETER Filter
A filter string to select files for removal. Defaults to '*' (all files).

.PARAMETER Throttle
Specifies the maximum number of parallel runspaces to use when running in parallel mode. Valid values are 1 to 20.

.PARAMETER MinRunspaces
Specifies the minimum number of runspaces to use in parallel mode. Valid values are 1 to 9.

.EXAMPLE
Remove-Items -Path "C:\Temp" -Filter "*.log"
Removes all .log files from C:\Temp and its subdirectories.

.EXAMPLE
Remove-Items -Path "C:\Temp" -Filter "*.tmp" -Throttle 5 -MinRunspaces 2
Removes all .tmp files from C:\Temp using parallel processing with up to 5 runspaces.

.NOTES
- Supports ShouldProcess for WhatIf and Confirm.
- Parallel mode is activated by specifying Throttle or MinRunspaces parameters.
- Verbose output is available for removed files.
- Handles errors gracefully and provides warnings for failures.
#>

function Remove-Items {
    [CmdletBinding(DefaultParameterSetName = 'Standard', SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    param (
        # Path to the directory
        [Parameter(Mandatory = $true)]
        [string]$Path,
        # File filter (wildcard pattern)
        [string]$Filter = '*',
        # Maximum number of concurrent runspaces
        [Parameter(ParameterSetName = 'Parallel')]
        [ValidateRange(1, 20)]
        [int]$Throttle = 10,
        # Minimum number of runspaces to use
        [Parameter(ParameterSetName = 'Parallel')]
        [ValidateRange(1, 9)]
        [int]$MinRunspaces = 1
    )
    # Validate path to ensure it exists
    if (-not (Test-Path -Path $Path -PathType Container)) {
        Write-Warning "The specified path does not exist or is not a directory: $Path"
        return
    }
    # Get files to remove
    $files = Get-ChildItem -Path $Path -Filter $Filter -File -Recurse
    #  Standard removal
    if ($PSCmdlet.ParameterSetName -eq 'Standard') {
        foreach ($file in $files) {
            if ($PSCmdlet.ShouldProcess($file.FullName, "Remove file")) {
                try {
                    Remove-Item -Path $file.FullName -Force -ErrorAction Stop
                    Write-Verbose "Removed: $($file.FullName)"
                } catch {
                    Write-Warning "Failed to remove '$($file.FullName)': $($_.Exception.Message)"
                }
            }
        }
    }
    # Parallel removal
    else {
        $VerbosePreferenceValue = $VerbosePreference
        # Create runspace pool
        $runspacePool = [RunspaceFactory]::CreateRunspacePool($MinRunspaces, $Throttle)
        $runspacePool.Open()
        # Batch files to limit number of runspaces
        $batchSize = [Math]::Ceiling($files.Count / $Throttle)
        $fileBatches = @()
        if ($files.Count -gt 0) {
            for ($i = 0; $i -lt $files.Count; $i += $batchSize) {
                $fileBatches += ,$files[$i..([Math]::Min($i + $batchSize - 1, $files.Count - 1))]
            }
        }
        # Start runspaces
        $runspaces = foreach ($batch in $fileBatches) {
            $powershell = [PowerShell]::Create()
            $powershell.RunspacePool = $runspacePool
            $Simulate = $WhatIfPreference
            $null = $powershell.AddScript({
                param($filePaths, $verbosePreferenceValue, $simulate)
                $VerbosePreference = $verbosePreferenceValue
                $results = @()
                foreach ($filePath in $filePaths) {
                    if ($simulate) {
                        $results += "WhatIf: Would remove $filePath"
                    } else {
                        try {
                            Remove-Item -Path $filePath -Force -ErrorAction Stop
                            $results += "Removed: $filePath"
                        } catch {
                            $results += "Failed to remove '$filePath': $($_.Exception.Message)"
                        }
                    }
                }
                return $results
            }).AddArgument($batch.FullName).AddArgument($VerbosePreferenceValue).AddArgument($Simulate)
            # Create custom object to track runspace and its status
            [PSCustomObject]@{
                Pipe   = $powershell
                Status = $powershell.BeginInvoke()
            }
        }
        # Wait for all runspaces to complete
        foreach ($rs in $runspaces) {
            try {
                $output = $rs.Pipe.EndInvoke($rs.Status)
                foreach ($line in $output) {
                    Write-Host $line
                }
            } catch {
                Write-Warning "Runspace error: $($_.Exception.Message)"
            } finally {
                if ($null -ne $rs.Pipe) {
                    $rs.Pipe.Dispose()
                }
            }
        }
        # Clean up runspace pool
        $runspacePool.Close()
        $runspacePool.Dispose()
    }
}
```

Boom there you have it, how to implement the **-WhatIf** parameter in a traditional approach, and implementing it to support runspaces which as mentioned is not supported by default.  I hope this blog has been insightful for you, and hopefully you made it through reading it without being left with lots more questions in your head, or just thinking what the flip...I write these blogs to help others and share information on using PowerShell to complete things automatically instead of being a point and click person to fix something.

## Something to share
Been loving the retro synth vibe lately, and spent the evening making this tune a few nights back.  This is a complete tune and was really happy with how it sounded so was worth the time in my opinion spending an evening doing it. I hope you enjoy this music too :musical_note:

https://www.youtube.com/watch?v=sthPIxkYukE

Until the next blog stay safe, and see you again soon.