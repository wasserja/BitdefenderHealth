<#
.SYNOPSIS
Convert a DateTime object from one timezone to another.

.DESCRIPTION
Convert a DateTime object from one timezone to another.

List valid time zone identifiers.
[System.TimeZoneInfo]::GetSystemTimeZones().id


.PARAMETER inputDateTime
Enter a valid datetime object.

.PARAMETER fromTimeZone
Enter a valid timezone identifer.

.PARAMETER toTimeZone
Enter a valid timezone identifer.

.EXAMPLE
Convert-TimeZone -inputDateTime '7/20/2017 5:00 PM' -fromTimeZone 'UTC' -toTimeZone 'Eastern Standard Time'

Thursday, July 20, 2017 1:00:00 PM

.NOTES
Created by: Jason Wasser @wasserja
Modified: 7/26/2017 10:26:52 AM 
#>
function Convert-TimeZone {
    [CmdletBinding()]
    param (
        [datetime]$inputDateTime = (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'),
        [string]$fromTimeZone = "E. Europe Standard Time",
        [string]$toTimeZone = [System.TimeZoneInfo]::Local.Id
    )
    
    begin {

        function Test-TimeZone {
            param (
                $TimeZone
            )
            $ValidTimeZones = [System.TimeZoneInfo]::GetSystemTimeZones()
            Write-Verbose -Message "Validating time zone $TimeZone"
            # $IsValidTimeZone = $ValidTimeZones.id -contains $TimeZone
            $IsValidTimeZone = ($ValidTimeZones | Select-Object -ExpandProperty Id) -contains $TimeZone
            Write-Verbose -Message "Timezone $TimeZone is $IsValidTimeZone"
            $IsValidTimeZone

        }
    }
    
    process {

        # Validate time zones
        if ((Test-TimeZone -TimeZone $fromTimeZone) -and (Test-TimeZone -TimeZone $toTimeZone)) {
            Write-Verbose -Message "Timezones have been validated."
            Write-Verbose -Message "Converting $inputDateTime from $fromTimeZone to $toTimeZone"
            $outputDateTime = [System.TimeZoneInfo]::ConvertTimeBySystemTimeZoneId(
                $inputDateTime, $fromTimeZone, $toTimeZone)

            Write-Output $outputDateTime
        }
        else {
            Write-Error "Invalid time zone entered."
        }
    }
    
    end {
    }
}


