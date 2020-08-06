function Update-XsTmanData {
    <#
    .DESCRIPTION
        This function will Update the Tman Data
    .PARAMETER RestServer
        A Rest Server is required.
    .PARAMETER Status
        A Status is required.
    .PARAMETER TmanId
        A Tman Id is required.
    .PARAMETER TmanLogFile
        A TmanLogFile is optional.
    .EXAMPLE
        Update-XSTmanData -RestServer localhost -Status 2 -TmanId 1 -TmanLogFile "c:\test\test.log"
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
        [Parameter(Mandatory=$false)][string]$TmanLogFile,
        [Parameter(Mandatory=$true)][int]$TmanId
    )
    begin {
        $HeartBeat = Get-XsTimeStamp
        if(($null -eq $TmanLogFile) -or ($TmanLogFile -eq "")){
            $body = @{
                STATUS_ID = "$Status"
                Heartbeat = "$HeartBeat"
            }
        } else {
            $body = @{
                STATUS_ID = "$Status"
                Log_File = "$TmanLogFile"
                Heartbeat = "$HeartBeat"
            }
        }
        $body = $body | ConvertTo-Json
    }
    process
    {
        if ($pscmdlet.ShouldProcess("Update-XSTmanData"))
        {
            try
            {
                Write-Log -Message "Updating the Tman" -MsgType DEBUG -Logfile $Logfile -LogLevel $LogLevel
                # Make the rest call to update the data
                $Url = "/testrun_manager/$TmanId"
                Invoke-XesterRestCall -RestServer $RestServer -URI "$Url" -Method Put -Body $body
            }
            catch
            {
                $ErrorMessage = $_.Exception.Message
                $FailedItem = $_.Exception.ItemName
                Throw "Update-XSTmanData: $ErrorMessage $FailedItem"
            }
        }
        else
        {
            # -WhatIf was used.
            return $false
        }
    }
}