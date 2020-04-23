function Get-TestRunSet {
    <#
    .DESCRIPTION
        This function will Gather TestRun data.
    .PARAMETER RestServer
        A Rest Server is required.
    .PARAMETER TestRunId
        A TestRunId Id is optional.
    .PARAMETER StatusId
        A StatusId Id is optional.
    .PARAMETER TestRun_Manager_ID
        A StatusId Id is optional.
    .EXAMPLE
        Get-TestRunSet -RestServer localhost -TestRunId 1
    .EXAMPLE
        Get-TestRunSet -RestServer localhost -StatusId 1
    .EXAMPLE
        Get-TestRunSet -RestServer localhost -TestRun_Manager_ID 1
    .NOTES
        This will return a hashtable of data from the database.
    #>
    [CmdletBinding(
        SupportsShouldProcess = $true,
        ConfirmImpact = "Low"
    )]
    [OutputType([hashtable])]
    [OutputType([Boolean])]
    param(
        [Parameter(Mandatory=$true)][string]$RestServer,
        [Parameter(Mandatory=$false)][int]$TestRunId,
        [Parameter(Mandatory=$false)][int]$StatusId,
        [Parameter(Mandatory=$false)][int]$TestRun_Manager_ID
    )
    begin {
        if ($TestRunId){
            # Filter on the TestRunId
            $Url = "/testrun?filter=ID,eq,$TestRunId&transform=true"
        } elseif ($StatusId){
            # Filter on the STATUS_ID
            $Url = "/testrun?filter=STATUS_ID,eq,$StatusId&transform=true"
        } elseif ($TestRun_Manager_ID) {
            # Filter on the TestRun_Manager_ID
            $Url = "/testrun?filter=TestRun_Manager_ID,eq,$TestRun_Manager_ID&transform=true"
        } else {
            # No Filter
            $Url = "/testrun?transform=true"
        }
    }
    process
    {
        if ($pscmdlet.ShouldProcess("Get-TestRunSet"))
        {
            try
            {
                Write-Log -Message "Gathering TestRun Data" -MsgType DEBUG -Logfile $Logfile -LogLevel $LogLevel
                # Make the rest call to Get the data
                Invoke-XesterRestCall -RestServer $RestServer -URI "$Url" -Method Get
            }
            catch
            {
                $ErrorMessage = $_.Exception.Message
                $FailedItem = $_.Exception.ItemName
                Throw "Get-TestRunSet: $ErrorMessage $FailedItem"
            }
        }
        else
        {
            # -WhatIf was used.
            return $false
        }
    }
}