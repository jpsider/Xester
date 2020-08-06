function Get-XsTmanData {
    <#
    .DESCRIPTION
        This function will Gather TestRun Manager data.
    .PARAMETER RestServer
        A Rest Server is required.
    .PARAMETER TmanId
        A Qman Id is required.
    .EXAMPLE
        Get-XStmanData -RestServer localhost -TmanId 1
    .NOTES
        This will return a hashtable of data from the XesterUI database.
    #>
    [CmdletBinding(
        SupportsShouldProcess = $true,
        ConfirmImpact = "Low"
    )]
    [OutputType([hashtable])]
    [OutputType([Boolean])]
    param(
        [Parameter(Mandatory=$true)][string]$RestServer,
        [Parameter(Mandatory=$true)][int]$TmanId
    )
    begin {
    }
    process
    {
        if ($pscmdlet.ShouldProcess("Get-XStmanData"))
        {
            try
            {
                Write-Log -Message "Getting the Tman Data" -MsgType DEBUG -Logfile $Logfile -LogLevel $LogLevel
                # Make the rest call to Get the data
                $Url = "/testrun_manager/$TmanId"
                Invoke-XesterRestCall -RestServer $RestServer -URI "$Url" -Method Get
            }
            catch
            {
                $ErrorMessage = $_.Exception.Message
                $FailedItem = $_.Exception.ItemName
                Throw "Get-XStmanData: $ErrorMessage $FailedItem"
            }
        }
        else
        {
            # -WhatIf was used.
            return $false
        }
    }
}