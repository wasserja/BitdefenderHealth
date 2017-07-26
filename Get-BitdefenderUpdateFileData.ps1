<#
.SYNOPSIS
Get the Bitdefender signature version, number, and update time.

.DESCRIPTION
Get the Bitdefender signature version, number, and update time.

.PARAMETER BitdefenderThreatScannerPath
Enter the path to the Bitdefender ThreatScanner folder.

.EXAMPLE
Get-BitdefenderUpdateFileData

ComputerName     : COMPUTER01
Version          : 7.72508
Signature number : 9697199
Update time GMT  : 1501066499
Update time      : 7/26/2017 10:54:59 AM

.NOTES
Created by: Jason Wasser @wasserja
Modified: 7/26/2017 10:53:22 AM 
#>
function Get-BitdefenderUpdateFileData {
    [CmdletBinding()]
    param (
        [ValidateScript({Test-Path -Path $_})]
        [string]$BitdefenderThreatScannerPath = 'C:\Program Files\Bitdefender\Endpoint Security\ThreatScanner'
    )
    
    begin {
    }
    
    process {
        $BitdefenderUpdatePath = Get-Item -Path "$BitdefenderThreatScannerPath\Antivirus*\Plugins\Update.txt"
        $UpdateFile = Get-Content -Path $BitdefenderUpdatePath
        $BitdefenderUpdateFileDataProperties = @{}
        $BitdefenderUpdateFileDataProperties.Add('ComputerName', $env:COMPUTERNAME)
        foreach ($Line in $UpdateFile) {
            $BitdefenderUpdateFileDataProperties.Add(($Line.Split(':')[0]).Trim(), ($Line.Substring($Line.IndexOf(':') + 1)).Trim())
        }
        
        # Changing Update time to [datetime]
        #$BitdefenderUpdateFileDataProperties['Update time'] = ([datetime]::ParseExact($BitdefenderUpdateFileDataProperties['Update time'],'ddd MMM dd HH:mm:ss yyyy',$null)).ToLocalTime()
        $BitdefenderUpdateFileDataProperties['Update time'] = (Convert-UnixTimeToDateTime -UnixTime $BitdefenderUpdateFileDataProperties['Update time GMT'])
        $BitdefenderUpdateFileData = New-Object -TypeName PSCustomObject -Property $BitdefenderUpdateFileDataProperties
        $BitdefenderUpdateFileData
    }
    
    end {
    }
}



