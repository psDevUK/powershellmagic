<#
.SYNOPSIS
Removes files from a specified directory, optionally using parallel processing.

.DESCRIPTION
The Remove-Items function deletes files from a given directory and its subdirectories, matching an optional filter. It supports standard and parallel execution modes. In parallel mode, file removal is distributed across multiple runspaces for improved performance.

.PARAMETER Path
The path to the directory containing files to remove. Must be an existing directory.

.PARAMETER Filter
A wildcard filter to select files for removal. Defaults to '*' (all files).

.PARAMETER Throttle
[Parallel mode only] The maximum number of concurrent runspaces used for parallel file removal. Default is 10.

.PARAMETER MinRunspaces
[Parallel mode only] The minimum number of runspaces to use. Default is 1.

.EXAMPLE
Remove-Items -Path "C:\Temp" -Filter "*.log"
Removes all .log files from C:\Temp and its subdirectories.

.EXAMPLE
Remove-Items -Path "C:\Temp" -Filter "*.tmp" -Throttle 10 -MinRunspaces 2
Removes all .tmp files from C:\Temp and its subdirectories using parallel processing with up to 10 runspaces.

.NOTES
- Supports ShouldProcess for confirmation and WhatIf.
- Writes verbose output for each removed file.
- Writes warnings if files cannot be removed or if the path is invalid.
#>
function Remove-Items {
    [CmdletBinding(DefaultParameterSetName = 'Standard', SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Path,

        [string]$Filter = '*',

        [Parameter(ParameterSetName = 'Parallel')]
        [int]$Throttle = 10,

        [Parameter(ParameterSetName = 'Parallel')]
        [int]$MinRunspaces = 1
    )

    if (-not (Test-Path -Path $Path -PathType Container)) {
        Write-Warning "The specified path does not exist or is not a directory: $Path"
        return
    }

    $files = Get-ChildItem -Path $Path -Filter $Filter -File -Recurse

    if ($PSCmdlet.ParameterSetName -eq 'Standard') {
        foreach ($file in $files) {
            if ($PSCmdlet.ShouldProcess($file.FullName, "Remove file")) {
                try {
                    Remove-Item -Path $file.FullName -Force
                    Write-Verbose "Removed: $($file.FullName)"
                } catch {
                    Write-Warning "Failed to remove '$($file.FullName)': $($_.Exception.Message)"
                }
            }
        }
    }
    else {
        $VerbosePref = $VerbosePreference
        $runspacePool = [RunspaceFactory]::CreateRunspacePool($MinRunspaces, $Throttle)
        $runspacePool.Open()

        $runspaces = foreach ($file in $files) {
            $powershell = [PowerShell]::Create()
            $powershell.RunspacePool = $runspacePool

            $null = $powershell.AddScript({
                param($filePath, $verbosePref)
                $VerbosePreference = $verbosePref
                try {
                    Remove-Item -Path $filePath -Force
                    Write-Verbose "Removed: $filePath"
                } catch {
                    Write-Warning "Failed to remove '$filePath': $($_.Exception.Message)"
                }
            }).AddArgument($file.FullName).AddArgument($VerbosePref)

            [PSCustomObject]@{
                Pipe   = $powershell
                Status = $powershell.BeginInvoke()
            }
        }

        foreach ($rs in $runspaces) {
            $rs.Pipe.EndInvoke($rs.Status)
            $rs.Pipe.Dispose()
        }

        $runspacePool.Close()
        $runspacePool.Dispose()
    }
}