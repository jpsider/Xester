function Update-TestRun {
    <#
    .DESCRIPTION
        This function will Update the TestRun Data - Simple fields.
    .PARAMETER RestServer
        A Rest Server is required.
    .PARAMETER TestRunId
        A TestRunId Id is required.
    .PARAMETER Status
        A Status is required.
    .PARAMETER Result
        A Result is required.
    .PARAMETER TestRun_Manager_ID
        A TestRun_Manager_ID is required.
    .EXAMPLE
        Update-TestRun -RestServer localhost -Status 2 -TestRunId 1 -Result 2 -TestRun_Manager_ID 1
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
        [Parameter(Mandatory=$true)][string]$RestServer,
        [Parameter(Mandatory=$true)][int]$Status,
        [Parameter(Mandatory=$true)][int]$TestRunId,
        [Parameter(Mandatory=$true)][int]$Result,
        [Parameter(Mandatory=$true)][int]$TestRun_Manager_ID
    )
    begin {
        $body = @{
            STATUS_ID = "$Status"
            RESULT_ID = "$Result"
            TestRun_Manager_ID = "$TestRun_Manager_ID"
        }
        $body = $body | ConvertTo-Json
    }
    process
    {
        if ($pscmdlet.ShouldProcess("Update-TestRun"))
        {
            try
            {
                Write-Log -Message "Updating the TestRun ID: $TestRunId" -MsgType DEBUG -Logfile $Logfile -LogLevel $LogLevel
                # Make the rest call to update the data
                $Url = "/testrun/$TestRunId"
                Invoke-XesterRestCall -RestServer $RestServer -URI "$Url" -Method Put -Body $body
            }
            catch
            {
                $ErrorMessage = $_.Exception.Message
                $FailedItem = $_.Exception.ItemName
                Throw "Update-TestRun: $ErrorMessage $FailedItem"
            }
        }
        else
        {
            # -WhatIf was used.
            return $false
        }
    }
}