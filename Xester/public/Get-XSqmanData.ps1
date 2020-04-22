function Get-XsQmanData {
    <#
.DESCRIPTION
    This function will Gather Qman data.
.PARAMETER RestServer
    A Rest Server is required.
.PARAMETER QmanId
    A Qman Id is required.
.EXAMPLE
    Get-XSqmanData -RestServer localhost -QmanId 1
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
    [Parameter(Mandatory=$true)][int]$QmanId
)
begin {
}
process
{
    if ($pscmdlet.ShouldProcess("Get-XSqmanData"))
    {
        try
        {
            Write-Log -Message "Getting the Qman Data" -MsgType INFO -Logfile $Logfile -LogLevel $LogLevel
            # Make the rest call to Get the data
            $Url = "/queue_manager/$QmanId"
            Invoke-XesterRestCall -RestServer $RestServer -URI "$Url" -Method Get
        }
        catch
        {
            $ErrorMessage = $_.Exception.Message
            $FailedItem = $_.Exception.ItemName
            Throw "Get-XSqmanData: $ErrorMessage $FailedItem"
        }
    }
    else
    {
        # -WhatIf was used.
        return $false
    }
}
}