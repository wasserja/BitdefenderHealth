<#
.SYNOPSIS
Test a Windows service to see if it exists, is running, and is automatic.

.DESCRIPTION
Test a Windows service to see if it exists, is running, and is automatic.

.PARAMETER ServiceName
Enter the name of a service.

.EXAMPLE
Test-Service -ServiceName wscsvc

IsRunning Name   ServiceExists IsAutomatic
--------- ----   ------------- -----------
     True wscsvc          True        True

.NOTES
Created by: Jason Wasser @wasserja
Modified: 7/26/2017 10:29:34 AM 
#>
function Test-Service {
    [CmdletBinding()]
    param (
        [string]$ServiceName = 'EPSecurityService'
    )

    try {
        $Service = Get-Service -Name $ServiceName -ErrorAction Stop
        if ($Service) {
            $ServiceDetails = Get-WmiObject -Class win32_service -Filter "Name = '$ServiceName'"
            $ServiceHealthProperties = @{
                Name          = $Service.Name
                ServiceExists = $true
                IsRunning     = [bool]($Service.Status -eq 'Running')
                IsAutomatic   = [bool]($ServiceDetails.StartMode -eq 'Auto')
            }
            $ServiceHealth = New-Object -TypeName PSCustomObject -Property $ServiceHealthProperties
            $ServiceHealth
        }
    }
    catch {
        $ServiceHealthProperties = @{
            Name          = $ServiceName
            ServiceExists = $false
            IsRunning     = $false
            IsAutomatic   = $false
        }
        $ServiceHealth = New-Object -TypeName PSCustomObject -Property $ServiceHealthProperties
        $ServiceHealth
    }
}