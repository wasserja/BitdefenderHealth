<#
.SYNOPSIS
Get the status of the Bitdefender components.

.DESCRIPTION
Get the status of the Bitdefender components (i.e. antivirus, antispyware, firewall)

.PARAMETER BitdefenderComponentStatusFile
Enter the path to the Bitdefender Product.ActionCenter.conf json file.

.EXAMPLE
Get-BitdefenderComponentStatus

FirewallEnabled AntivirusEnabled AntispywareEnabled
--------------- ---------------- ------------------
true            true             true

.NOTES
Created by: Jason Wasser @wasserja
Modified: 7/26/2017 10:37:08 AM 
#>
function Get-BitdefenderComponentStatus {
    [CmdletBinding()]
    param (
        [validateScript( {Test-Path -Path $_})]
        [string]$BitdefenderComponentStatusFile = 'C:\Program Files\Bitdefender\Endpoint Security\settings\system\Product.ActionCenter.conf'
    )
    
    begin {
    }
    
    process {

        Write-Verbose "Getting the content of $BitddefenderComponentStatusFile"
        $BitdefenderComponentStatusContent = Get-Content -Path $BitdefenderComponentStatusFile
        Write-Verbose -Message "PowerShell version $($PSVersionTable.PSVersion.Major) detected"
        
        if ($PSVersionTable.PSVersion.Major -ge 3) {
            $BitdefenderComponentStatusJson = $BitdefenderComponentStatusContent | ConvertFrom-Json
        }
        else {
            [System.Reflection.Assembly]::LoadWithPartialName("System.Web.Extensions") | Out-Null
            $Serializer = New-Object System.Web.Script.Serialization.JavaScriptSerializer
            $BitdefenderComponentStatusJson = New-Object -TypeName PSCustomObject -Property $Serializer.DeserializeObject($BitdefenderComponentStatusContent)
        }

        
        $BitdefenderComponentStatusProperties = @{
            AntispywareEnabled = $BitdefenderComponentStatusJson.'Product.ActionCenter'.aspyStatus
            AntivirusEnabled   = $BitdefenderComponentStatusJson.'Product.ActionCenter'.avStatus
            FirewallEnabled    = $BitdefenderComponentStatusJson.'Product.ActionCenter'.fwStatus
        }
        $BitdefenderComponentStatus = New-Object -TypeName PSCustomObject -Property $BitdefenderComponentStatusProperties
        $BitdefenderComponentStatus
    }
    
    end {
    }
}