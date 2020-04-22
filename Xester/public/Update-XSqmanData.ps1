function Update-XsQmanData {
    <#
.DESCRIPTION
    This function will Update the Qman Data
.PARAMETER RestServer
    A Rest Server is required.
.PARAMETER Status
    A Status is required.
.PARAMETER QmanId
    A Qman Id is required.
.PARAMETER QmanLogFile
    A QmanLogFile is optional.
.EXAMPLE
    Update-XSqmanData -RestServer localhost -Status 2 -QmanId 1 -QmanLogFile "c:\test\test.log"
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
    [Parameter(Mandatory=$false)][string]$QmanLogFile,
    [Parameter(Mandatory=$true)][int]$QmanId
)
begin {
    $HeartBeat = Get-XsTimeStamp
    if(($null -eq $QmanLogFile) -or ($QmanLogFile -eq "")){
        $body = @{
            STATUS_ID = "$Status"
            Heartbeat = "$HeartBeat"
        }
    } else {
        $body = @{
            STATUS_ID = "$Status"
            Log_File = "$QmanLogFile"
            Heartbeat = "$HeartBeat"
        }
    }
    $body = $body | ConvertTo-Json
}
process
{
    if ($pscmdlet.ShouldProcess("Update-XSqmanData"))
    {
        try
        {
            Write-Log -Message "Updating the Qman" -MsgType INFO -Logfile $Logfile -LogLevel $LogLevel
            # Make the rest call to update the data
            $Url = "/queue_manager/$QmanId"
            Invoke-XesterRestCall -RestServer $RestServer -URI "$Url" -Method Put -Body $body
        }
        catch
        {
            $ErrorMessage = $_.Exception.Message
            $FailedItem = $_.Exception.ItemName
            Throw "Update-XSqmanData: $ErrorMessage $FailedItem"
        }
    }
    else
    {
        # -WhatIf was used.
        return $false
    }
}
}