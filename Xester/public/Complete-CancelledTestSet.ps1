function Complete-CancelledTestSet {
    <#
    .DESCRIPTION
        This function will set all Cancelled TestRuns to Aborted.
    .PARAMETER RestServer
        A Rest Server is required.
    .EXAMPLE
        Complete-CancelledTestSet -RestServer localhost
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
        if ($pscmdlet.ShouldProcess("Complete-CancelledTestSet"))
        {
            try
            {
                Write-Log -Message "Setting all Cancelled Tests to Complete-Aborted." -MsgType DEBUG -Logfile $Logfile -LogLevel $LogLevel
                # Get the List of Queued Tests.
                $TestRunSet = (Get-TestRunSet -RestServer $RestServer -StatusId 10).testrun
                foreach ($TestRun in $TestRunSet){
                    $TestRunId = $TestRun.ID
                    Write-Log -Message "Setting TestRunID: $TestRunId to Complete-Aborted." -MsgType DEBUG -Logfile $Logfile -LogLevel $LogLevel
                    Update-TestRun -RestServer localhost -Status 9 -TestRunId $TestRunId -Result 5 -TestRun_Manager_ID 9999 | Out-Null
                }
            }
            catch
            {
                $ErrorMessage = $_.Exception.Message
                $FailedItem = $_.Exception.ItemName
                Throw "Complete-CancelledTestSet: $ErrorMessage $FailedItem"
            }
        }
        else
        {
            # -WhatIf was used.
            return $false
        }
    }
}