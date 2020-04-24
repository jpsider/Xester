function Get-TmanData {
    <#
    .DESCRIPTION
        This function will Gather TestRun data.
    .PARAMETER RestServer
        A Rest Server is required.
    .PARAMETER StatusId
        A StatusId Id is optional.
    .EXAMPLE
        Get-TmanData -RestServer localhost -StatusId 2
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
        [Parameter(Mandatory=$false)][int]$StatusId
    )
    begin {
        if ($StatusId){
            # Filter on the STATUS_ID
            $Url = "/testrun_manager?filter=STATUS_ID,eq,$StatusId&transform=true"
        } else {
            # No Filter
            $Url = "/testrun_manager?transform=true"
        }
    }
    process
    {
        if ($pscmdlet.ShouldProcess("Get-TmanData"))
        {
            try
            {
                Write-Log -Message "Gathering TestRun Manager Data" -MsgType DEBUG -Logfile $Logfile -LogLevel $LogLevel
                # Make the rest call to Get the data
                Invoke-XesterRestCall -RestServer $RestServer -URI "$Url" -Method Get
            }
            catch
            {
                $ErrorMessage = $_.Exception.Message
                $FailedItem = $_.Exception.ItemName
                Throw "Get-TmanData: $ErrorMessage $FailedItem"
            }
        }
        else
        {
            # -WhatIf was used.
            return $false
        }
    }
}