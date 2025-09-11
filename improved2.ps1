<#
.SYNOPSIS
Removes files from a specified directory, optionally using parallel processing.

.DESCRIPTION
The Remove-Items function deletes files from a given directory path, with support for filtering file names and recursive search. It can operate in standard mode or parallel mode, allowing for faster deletion of large numbers of files using runspaces. The function supports WhatIf and Confirm prompts for safe operation.

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