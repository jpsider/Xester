[CmdletBinding()]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidGlobalVars", '')]
param (
    [Parameter(Mandatory=$true)]
    [string]$PropertiesPath
)

Import-Module PowerLumber
$host.ui.RawUI.WindowTitle = "XesterUI TestRun Manager"

# Gather the Properties from the tman.json file
$Properties = Get-Content -Path $PropertiesPath | ConvertFrom-Json

$TmanId = $Properties.ID
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
    $Global:Logfile = "$env:SystemDrive/XesterUI/testrun_manager/tman.log"
}

# Start endless loop! - set a variable that never gets changed.
Write-Log -Message "Starting XesterUI TestRun Manager" -Logfile $Logfile -LogLevel $LogLevel -MsgType INFO
$ManagerRunning = $true
Do {
    try {
        try{
            # Get the TestRun Manager Status from the RestServer
            $TmanData = Get-XsTmanData -RestServer $RestServer -TmanId $TmanId
            $STATUS_ID = $TmanData.STATUS_ID
            $WAIT = $TmanData.Wait
        }
        Catch {
            $ErrorMessage = $_.Exception.Message
            $FailedItem = $_.Exception.ItemName
            Write-Log -Message "Unable to Get Tman Data" -Logfile $Logfile -LogLevel $LogLevel -MsgType FATAL
            Throw "Unable to Get Tman Data"
        }


        # TODO
            # Roll Log (If Needed)



        try {
            # Update the Heartbeat & Logfile
            Update-XsTmanData -RestServer $RestServer -Status $STATUS_ID -TmanId $TmanId -TmanLogFile "$LogFile" | Out-Null
        }
        Catch {
            $ErrorMessage = $_.Exception.Message
            $FailedItem = $_.Exception.ItemName
            Write-Log -Message "Unable to Update Tman Data" -Logfile $Logfile -LogLevel $LogLevel -MsgType FATAL
            Throw "Unable to Update Tman Data"
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

                #TODO
                    # What are the things this manager should do?

                    # Determine number of running tests.
                    # Start Assigned Tests (Using jobs?)





            }
            # Starting Up
            3{
                Write-Log -Message "Manager Status is: $STATUS_ID - Starting Up - Performing Startup tasks." -Logfile $Logfile -LogLevel $LogLevel -MsgType INFO
                # Set the Status to Running (2)
                Write-Log -Message "Setting the Manager status to Running." -Logfile $Logfile -LogLevel $LogLevel -MsgType INFO
                $STATUS_ID = 2
                try{
                    Update-XsTmanData -RestServer $RestServer -Status $STATUS_ID -TmanId $TmanId | Out-Null
                }
                Catch {
                    $ErrorMessage = $_.Exception.Message
                    $FailedItem = $_.Exception.ItemName
                    Write-Log -Message "Unable to Update Tman Data" -Logfile $Logfile -LogLevel $LogLevel -MsgType FATAL
                    Throw "Unable to Update Tman Data"
                }
            }
            # Shutting Down
            4{
                Write-Log -Message "Manager Status is: $STATUS_ID - Shutting Down - Performing Shutdown tasks." -Logfile $Logfile -LogLevel $LogLevel -MsgType INFO
                
                #TODO
                    # Think about what should happen when one of these guys shuts down!
                    # Find all running jobs for this manager, kill the jobs, abort the tests?
                    # Find any Assigned tests, and set them back to queued
                
                
                # Set the Status to Shutdown (1)
                Write-Log -Message "Setting the Manager Status to Shutdown." -Logfile $Logfile -LogLevel $LogLevel -MsgType INFO
                $STATUS_ID = 1
                try{
                    Update-XsTmanData -RestServer $RestServer -Status $STATUS_ID -TmanId $TmanId | Out-Null
                }
                Catch {
                    $ErrorMessage = $_.Exception.Message
                    $FailedItem = $_.Exception.ItemName
                    Write-Log -Message "Unable to Update Tman Data" -Logfile $Logfile -LogLevel $LogLevel -MsgType FATAL
                    Throw "Unable to Update Tman Data"
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
            Update-XsTmanData -RestServer $RestServer -Status $STATUS_ID -TmanId $TmanId | Out-Null
            Start-Sleep -Seconds $WAIT
        }
        Catch {
            $ErrorMessage = $_.Exception.Message
            $FailedItem = $_.Exception.ItemName
            Write-Log -Message "Unable to Update Tman Data" -Logfile $Logfile -LogLevel $LogLevel -MsgType FATAL
            Throw "Unable to Update Tman Data"
        }
    }
    catch {
        $ErrorMessage = $_.Exception.Message
        $FailedItem = $_.Exception.ItemName
        Write-Log -Message "The TestRun Manager Crashed '$ErrorMessage $FailedItem', restarting in 5 seconds." -Logfile $Logfile -LogLevel $LogLevel -MsgType INFO
        Start-Sleep -Seconds 5
    }

} while ($ManagerRunning -eq $true)