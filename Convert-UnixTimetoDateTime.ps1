<#
.SYNOPSIS
Convert unix epoch time to a DateTime object.

.DESCRIPTION
Convert unix epoch time to a DateTime object in UTC.

.PARAMETER UnixTime
Enter the unix epoch time.

.EXAMPLE
Convert-UnixTimeToDateTime -UnixTime 1501078786

Wednesday, July 26, 2017 2:19:46 PM

.NOTES
Created by: Jason Wasser @wasserja
Modified: 7/26/2017 10:22:06 AM 

.LINK
https://en.wikipedia.org/wiki/Unix_time
#>
function Convert-UnixTimeToDateTime {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [int]$UnixTime
    ) 
    $UnixConvertedDateTime = (New-Object DateTime(1970, 1, 1, 0, 0, 0, 0, [DateTimeKind]::Utc)).AddSeconds($UnixTime)
    Write-Verbose "Unix converted date time: $UnixConvertedDateTime"
    $UnixConvertedDateTime
}