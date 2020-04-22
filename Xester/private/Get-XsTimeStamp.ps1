function Get-XsTimeStamp {
    <#
	.DESCRIPTION
		This function will return a TimeStamp.
    .PARAMETER RestServer
        A Rest Server is required.
	.EXAMPLE
        Get-XsTimeStamp
	.NOTES
        This will return a TimeStamp.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param()
    try
    {
        Get-Date -Format "MMddyyyy-HH:mm:ss"
    }
    catch
    {
        $ErrorMessage = $_.Exception.Message
        $FailedItem = $_.Exception.ItemName
        Throw "Get-XsTimeStamp: $ErrorMessage $FailedItem"
    }
}