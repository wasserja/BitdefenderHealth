<#
.SYNOPSIS
Get the publish date of the currently installed Bitdefender signatures.

.DESCRIPTION
Get the publish date of the currently installed Bitdefender signatures.

.PARAMETER TimeZone
Enter the timezone to which you wish to convert the datetime to. Bitdefender 
publishes in Eastern Europe Standard Time since they are from Romania.

.EXAMPLE
Get-BitdefenderSignatureDate

Wednesday, July 26, 2017 8:03:50 AM
.NOTES
Created by: Jason Wasser @wasserja
Modified: 7/26/2017 10:45:21 AM 
#>
function Get-BitdefenderSignatureDate {
    [CmdletBinding()]
    param (
        $TimeZone = (Get-WmiObject -Class win32_timezone | Select-Object -ExpandProperty StandardName)
    )
    
    begin {
    }
    
    process {
        $BitdefenderThreatScannerPath = 'C:\Program Files\Bitdefender\Endpoint Security\ThreatScanner'
        try {
            $BitdefenderUpdatePath = Get-Item -Path "$BitdefenderThreatScannerPath\Antivirus*\versions.id*"
            [xml]$BitdefenderVersionsFile = Get-Content -Path $BitdefenderUpdatePath
        
            # Bitdefender headquarters is in Eastern European Time Zone which also has daylight saving time.
            $BitdefenderSignatureDate = Convert-TimeZone -inputDateTime ([datetime]$BitdefenderVersionsFile.info.time.'#text') -fromTimeZone 'E. Europe Standard Time' -toTimeZone $TimeZone
            $BitdefenderSignatureDate
        }
        catch {
            Write-Warning -Message "Unable to determine the signature date."
            $BitdefenderSignatureDate = $null
            $BitdefenderSignatureDate
        }
        
    }
    
    end {
    }
}

