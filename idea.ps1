<#
.SYNOPSIS
Removes all files matching a specified filter from a directory, with optional parallel execution.

.DESCRIPTION
The Remove-Items function deletes files from a given directory and its subdirectories based on a filter. 
It supports standard sequential removal or parallel removal using runspaces for improved performance. 
The function also supports WhatIf and Verbose output for safe and informative execution.

.PARAMETER Path
Specifies the path to the directory from which files will be removed. This parameter is mandatory.

.PARAMETER Filter
Specifies the file filter (wildcard pattern) to select files for removal. Defaults to '*' (all files).

.PARAMETER Throttle
Specifies the maximum number of concurrent runspaces when using parallel execution. Defaults to 10.

.PARAMETER MinRunspaces
Specifies the minimum number of runspaces to use in parallel execution. Defaults to 1.

.EXAMPLE
Remove-Items -Path "C:\Temp" -Filter "*.log"
Removes all .log files from C:\Temp and its subdirectories sequentially.

.EXAMPLE
Remove-Items -Path "C:\Temp" -Filter "*.tmp" -Throttle 5
Removes all .tmp files from C:\Temp and its subdirectories in parallel, using up to 5 concurrent runspaces.

.NOTES
- Supports ShouldProcess for WhatIf and Confirm prompts.
- Requires appropriate permissions to remove files.
- Use with caution, as removed files cannot be recovered.

#>
function Remove-Items {
    [CmdletBinding(DefaultParameterSetName = 'Standard', SupportsShouldProcess = $true)]
    param (
        # Path to the directory
        [Parameter(Mandatory = $true, ParameterSetName = 'Standard')]
        [Parameter(Mandatory = $true, ParameterSetName = 'Parallel')]
        [string]$Path,
        # File filter (wildcard pattern)
        [Parameter(ParameterSetName = 'Standard')]
        [Parameter(ParameterSetName = 'Parallel')]
        [string]$Filter = '*',
        # Maximum number of concurrent runspaces
        [Parameter(ParameterSetName = 'Parallel')]
        [int]$Throttle = 10,
        # Minimum number of runspaces to use
        [Parameter(ParameterSetName = 'Parallel')]
        [int]$MinRunspaces = 1
    )
    # Validate path to ensure it exists
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
                }
                catch {
                    Write-Warning "Failed to remove '$($file.FullName)': $($_.Exception.Message)"
                }
            }
        }
    }
    elseif ($PSCmdlet.ParameterSetName -eq 'Parallel') {
        # Ensure preferences are defined
        $VerbosePref = $VerbosePreference
        # Prepare ShouldProcess results
        $ShouldProcessList = @()
        foreach ($file in $files) {
            $ShouldProcessList += $PSCmdlet.ShouldProcess($file.FullName, "Remove file")
        }
        # Create runspace pool
        $runspacePool = [RunspaceFactory]::CreateRunspacePool($MinRunspaces, $Throttle)
        $runspacePool.Open()
        $runspaces = @()
        # Start runspaces
        for ($i = 0; $i -lt $files.Count; $i++) {
            $file = $files[$i]
            $shouldProcess = $ShouldProcessList[$i]
            $powershell = [PowerShell]::Create()
            $powershell.RunspacePool = $runspacePool

            $null = $powershell.AddScript({
                    param($filePath, $verbosePref, $shouldProcess)
                    $VerbosePreference = $verbosePref
                    if ($shouldProcess) {
                        try {
                            Remove-Item -Path $filePath -Force
                            Write-Verbose "Removed: $filePath"
                        }
                        catch {
                            Write-Warning "Failed to remove '$filePath': $($_.Exception.Message)"
                        }
                    }
                }).AddArgument($file.FullName).AddArgument($VerbosePref).AddArgument($shouldProcess)
            # Start the asynchronous execution
            $runspaces += [PSCustomObject]@{
                Pipe   = $powershell
                Status = $powershell.BeginInvoke()
            }
        }
        # Wait for all runspaces to complete
        foreach ($rs in $runspaces) {
            $rs.Pipe.EndInvoke($rs.Status)
            $rs.Pipe.Dispose()
        }
        # Clean up runspace pool
        $runspacePool.Close()
        $runspacePool.Dispose()
        
        
    }
}