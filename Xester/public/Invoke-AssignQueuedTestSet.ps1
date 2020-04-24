function Invoke-AssignQueuedTestSet {
    <#
    .DESCRIPTION
        This function will set all Cancelled TestRuns to Aborted.
    .PARAMETER RestServer
        A Rest Server is required.
    .EXAMPLE
        Invoke-AssignQueuedTestSet -RestServer localhost
    .NOTES
        This will return a hashtable of data from the PPS database.
    #>
    [CmdletBinding(
        SupportsShouldProcess = $true,
        ConfirmImpact = "Low"
    )]
    [OutputType([hashtable])]
    [OutputType([Boolean])]
    param(
        [Parameter(Mandatory=$true)][string]$RestServer
    )
    begin {
    }
    process
    {
        if ($pscmdlet.ShouldProcess("Invoke-AssignQueuedTestSet"))
        {
            try
            {
                Write-Log -Message "Attempting to Assign Queued Tests." -MsgType DEBUG -Logfile $Logfile -LogLevel $LogLevel
                # Get the List of Queued Tests.
                $TestRunSet = (Get-TestRunSet -RestServer $RestServer -StatusId 6).testrun
                foreach ($TestRun in $TestRunSet){
                    $TestRunId = $TestRun.ID
                    # Query for Running TestRun Managers
                    $TmanList = (Get-TmanData -RestServer $RestServer -StatusId 2).testrun_manager
                    if(($TmanList | Measure-Object).count -ne 0){
                        :ManagerLoop foreach($TestRunManager in $TmanList){
                            $Tman_ID = $TestRunManager.ID
                            # Assign the test to the Manager and break the loop.
                            Write-Log -Message "Assigning TestRunID: $TestRunId to TmanID: $Tman_ID." -MsgType DEBUG -Logfile $Logfile -LogLevel $LogLevel
                            Update-TestRun -RestServer localhost -Status 7 -TestRunId $TestRunId -Result 6 -TestRun_Manager_ID $Tman_ID | Out-Null
                            break ManagerLoop
                        }
                    } else {
                        Write-log -Message "There are no TestRun Managers Available" -Logfile $logfile -LogLevel $logLevel -MsgType INFO
                    }
                }
            }
            catch
            {
                $ErrorMessage = $_.Exception.Message
                $FailedItem = $_.Exception.ItemName
                Throw "Invoke-AssignQueuedTestSet: $ErrorMessage $FailedItem"
            }
        }
        else
        {
            # -WhatIf was used.
            return $false
        }
    }
}