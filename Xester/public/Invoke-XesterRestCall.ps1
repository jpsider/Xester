function Invoke-XesterRestCall
{
    <#
	.DESCRIPTION
		This function will Perform a Rest Call to a Specific XesterUI Server.
    .PARAMETER RestServer
        A Rest Server is required.(Hostname or IP, not full URL)
    .PARAMETER URI
        A URI is required.
    .PARAMETER Method
        A Method is Required.
    .PARAMETER Body
        A Method is Optional.
	.EXAMPLE
        Invoke-XesterRestCall -RestServer localhost -URI "/queue_manager/1?transform=true" -Method Get
	.NOTES
        This will return a hashtable of data from the PPS database.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory = $true)][string]$RestServer,
        [Parameter(Mandatory = $true)][string]$URI,
        [ValidateSet("GET", "POST", "PUT", "DELETE")]
        [Parameter(Mandatory = $true)][string]$Method,
        [Parameter(Mandatory = $false)]$Body
    )
    try
    {
        $fullURL = "http://" + $RestServer + "/XesterUI/api/index.php" + $URI
        if ($null -eq $Body)
        {
            $RestParams = @{
                Method = "$Method"
                URI    = "$fullURL"
            }
        }
        else
        {
            $RestParams = @{
                Method = "$Method"
                URI    = "$fullURL"
                Body   = $Body
            }
        }
        Write-Log -Message "RestCall Details; FullUrl: $FullURL - Method: $Method" -LogLevel $LogLevel -MsgType DEBUG -Logfile $Logfile | Out-Null
        Invoke-RestMethod @RestParams
    }
    catch
    {
        $ErrorMessage = $_.Exception.Message
        $FailedItem = $_.Exception.ItemName
        Throw "Invoke-XesterRestCall: $ErrorMessage $FailedItem"
    }
}