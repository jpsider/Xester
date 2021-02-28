[CmdletBinding()]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidGlobalVars", '')]
param (
    [Parameter(Mandatory=$true)]
    [string]$PropertiesPath
)

Import-Module PowerLumber
$host.ui.RawUI.WindowTitle = "XesterUI Queue Manager"

# Gather the Properties from the qman.json file
$Properties = Get-Content -Path $PropertiesPath | ConvertFrom-Json

$QmanId = $Properties.ID
$Global:Logfile = $Properties.Logfile
$LogDir = $Properties.LogDir
$RestServer = $Properties.RestServer
$Global:LogLevel = $Properties.LogLevel

# If LogDir is blank, Set a default
If(($LogDir -eq "") -or ($null -eq $LogDir)){
    $LogDir = "$env:SystemDrive/XesterUI/"
}

# If Logfile is blank, Set a default value
If(($Logfile -eq "") -or ($null -eq $Logfile)){
    $Global:Logfile = "$env:SystemDrive/XesterUI/queue_manager/qman.log"
}

# Start endless loop! - set a variable that never gets changed.
Write-Log -Message "Starting XesterUI Queue Manager" -Logfile $Logfile -LogLevel $LogLevel -MsgType INFO
$ManagerRunning = $true
Do {
    try {
        # TODO
            # Write a function to delete all old logs in the XesterUI directory
            # Clear Qman Logs older than 3 days
            # Clear Tman Logs older than 3 days
            # Clear TestRun Logs older than 7 days

        # Get the Qman Status from the RestServer
        try {
            $QmanData = Get-XSqmanData -RestServer $RestServer -QmanId $QmanId
            $STATUS_ID = $QmanData.STATUS_ID
            $WAIT = $QmanData.Wait
        }
        Catch {
            $ErrorMessage = $_.Exception.Message
            $FailedItem = $_.Exception.ItemName
            Write-Log -Message "Unable to Get Qman Data" -Logfile $Logfile -LogLevel $LogLevel -MsgType FATAL
            Throw "Unable to Get Qman Data"
        }

        # TODO
            # Roll Log (If Needed)

        # Update the Heartbeat & Logfile
        try{
            Update-XsQmanData -RestServer $RestServer -Status $STATUS_ID -QmanId $QmanId -QmanLogFile "$LogFile" | Out-Null
        }
        Catch {
            $ErrorMessage = $_.Exception.Message
            $FailedItem = $_.Exception.ItemName
            Write-Log -Message "Unable to Update Qman Data" -Logfile $Logfile -LogLevel $LogLevel -MsgType FATAL
            Throw "Unable to Update Qman Data"
        }

        # Switch on the STATUS_ID
        Switch ($STATUS_ID) {
            # Shutdown
            1 {
                Write-Log -Message "Manager Status is: $STATUS_ID - Shutdown - Not Doing anything." -Logfile $Logfile -LogLevel $LogLevel -MsgType INFO
            }
            # Running
            2 {
                Write-Log -Message "Manager Status is: $STATUS_ID - Running - Performing normal tasks." -Logfile $Logfile -LogLevel $LogLevel -MsgType INFO
                # Abort Cancelled Tests
                Write-Log -Message "Aborting Cancelled Tests." -Logfile $Logfile -LogLevel $LogLevel -MsgType INFO
                Complete-CancelledTestSet -RestServer $RestServer
                # Review Submitted Tests
                Write-Log -Message "Updating Submitted Tests" -Logfile $Logfile -LogLevel $LogLevel -MsgType INFO
                Update-SubmittedTestSet -RestServer $RestServer
                # Assign Queued Tests
                Write-Log -Message "Assigning Queued Tests." -Logfile $Logfile -LogLevel $LogLevel -MsgType INFO
                Invoke-AssignQueuedTestSet -RestServer $RestServer
            }
            # Starting Up
            3{
                Write-Log -Message "Manager Status is: $STATUS_ID - Starting Up - Performing Startup tasks." -Logfile $Logfile -LogLevel $LogLevel -MsgType INFO
                # Set the Status to Running (2)
                Write-Log -Message "Setting the Manager status to Running." -Logfile $Logfile -LogLevel $LogLevel -MsgType INFO
                $STATUS_ID = 2
                try {
                    Update-XsQmanData -RestServer $RestServer -Status $STATUS_ID -QmanId $QmanId | Out-Null
                }
                Catch {
                    $ErrorMessage = $_.Exception.Message
                    $FailedItem = $_.Exception.ItemName
                    Write-Log -Message "Unable to Update Qman Data" -Logfile $Logfile -LogLevel $LogLevel -MsgType FATAL
                    Throw "Unable to Update Qman Data"
                }
            }
            # Shutting Down
            4{
                Write-Log -Message "Manager Status is: $STATUS_ID - Shutting Down - Performing Shutdown tasks." -Logfile $Logfile -LogLevel $LogLevel -MsgType INFO
                # Set any Queued Tests back to Submitted.
                Reset-QueuedTestSet -RestServer $RestServer
                # Set the Status to Shutdown (1)
                Write-Log -Message "Setting the Manager Status to Shutdown." -Logfile $Logfile -LogLevel $LogLevel -MsgType INFO
                $STATUS_ID = 1
                try {
                    Update-XsQmanData -RestServer $RestServer -Status $STATUS_ID -QmanId $QmanId | Out-Null
                }
                Catch {
                    $ErrorMessage = $_.Exception.Message
                    $FailedItem = $_.Exception.ItemName
                    Write-Log -Message "Unable to Update Qman Data" -Logfile $Logfile -LogLevel $LogLevel -MsgType FATAL
                    Throw "Unable to Update Qman Data"
                }
            }
            # Unknown
            default {
                Write-Log -Message "Manager Status is: $STATUS_ID - Unknown - Exiting Manager Process in 3 Seconds." -Logfile $Logfile -LogLevel $LogLevel -MsgType INFO
                $ManagerRunning = $true
                $WAIT = 3
            }
        } # End Switch

        # Perform the wait
        Write-Log -Message "Waiting $WAIT seconds before next loop." -Logfile $Logfile -LogLevel $LogLevel -MsgType INFO
        # Update the Heartbeat
        try {
            Update-XsQmanData -RestServer $RestServer -Status $STATUS_ID -QmanId $QmanId | Out-Null
            Start-Sleep -Seconds $WAIT
        }
        Catch {
            $ErrorMessage = $_.Exception.Message
            $FailedItem = $_.Exception.ItemName
            Write-Log -Message "Unable to Update Qman Data" -Logfile $Logfile -LogLevel $LogLevel -MsgType FATAL
            Throw "Unable to Update Qman Data"
        }
    }
    catch {
        $ErrorMessage = $_.Exception.Message
        $FailedItem = $_.Exception.ItemName
        Write-Log -Message "The Queue Manager Crashed '$ErrorMessage $FailedItem', restarting in 5 seconds." -Logfile $Logfile -LogLevel $LogLevel -MsgType INFO
        Start-Sleep -Seconds 5
    }

} while ($ManagerRunning -eq $true)