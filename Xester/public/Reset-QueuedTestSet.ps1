function Reset-QueuedTestSet {
    <#
    .DESCRIPTION
        This function will Update the TestRun Data - Simple fields.
    .PARAMETER RestServer
        A Rest Server is required.
    .EXAMPLE
        Reset-QueuedTestSet -RestServer localhost
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
        if ($pscmdlet.ShouldProcess("Reset-QueuedTestSet"))
        {
            try
            {
                Write-Log -Message "Setting all Queued Tests to Submitted." -MsgType DEBUG -Logfile $Logfile -LogLevel $LogLevel
                # Get the List of Queued Tests.
                $TestRunSet = (Get-TestRunSet -RestServer $RestServer -StatusId 6).testrun
                foreach ($TestRun in $TestRunSet){
                    $TestRunId = $TestRun.ID
                    Write-Log -Message "Setting TestRunID: $TestRunId to Submitted." -MsgType DEBUG -Logfile $Logfile -LogLevel $LogLevel
                    Update-TestRun -RestServer localhost -Status 5 -TestRunId $TestRunId -Result 6 -TestRun_Manager_ID 9999 | Out-Null
                }
            }
            catch
            {
                $ErrorMessage = $_.Exception.Message
                $FailedItem = $_.Exception.ItemName
                Throw "Reset-QueuedTestSet: $ErrorMessage $FailedItem"
            }
        }
        else
        {
            # -WhatIf was used.
            return $false
        }
    }
}