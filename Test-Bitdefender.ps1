<#
.SYNOPSIS
Test the health of the Bitdefender Endpoint Security Tools.

.DESCRIPTION
Test the health of the Bitdefender Endpoint Security Tools.

This function will check Bitdefender
* is installed
* is running
* is service healthy
* is up to date
* is antivirus enabled
* is antispyware enabled
* is firewall enabled
* aggregate health of above checks
* signature version
* signature number
* signature published date
* signature update time

.PARAMETER ComputerName
Enter a computer name

.PARAMETER BitdefenderProcessName
Enter the name ofthe Bitdefender process to check

.PARAMETER BitdefenderInstallationPath
Enter the path to the Bitdefender installation

.PARAMETER Credential
Enter a credential for establishing remote PowerShell session with ComputerName

.EXAMPLE
Test-Bitdefender -ComputerName COMPUTER01 -Credential $Credential

ComputerName                    : COMPUTER01
IsBitdefenderInstalled          : True
IsBitdefenderProcessRunning     : True
IsBitdefenderServiceHealthy     : True
IsBitdefenderUptodate           : True
IsBitdefenderAntivirusEnabled   : true
IsBitdefenderAntispywareEnabled : true
IsBitdefenderFirewallEnabled    : true
IsBitdefenderHealthy            : True
SignatureVersion                : 7.72508
SignatureNumber                 : 9697199
SignatureDate                   : 7/26/2017 8:03:50 AM
SignatureUpdateTime             : 7/26/2017 10:54:59 AM

.NOTES
Created by: Jason Wasser @wasserja
Modified: 7/26/2017 10:58:24 AM 
#>
function Test-Bitdefender {
    [CmdletBinding()]
    param (
        [parameter(
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
        [string[]]$ComputerName = $env:COMPUTERNAME,
        [string]$BitdefenderProcessName = 'epsecurityservice',
        [string]$BitdefenderInstallationPath = 'C:\Program Files\Bitdefender\Endpoint Security\epsecurityservice.exe',
        [System.Management.Automation.PSCredential]$Credential = [System.Management.Automation.PSCredential]::Empty
    )
    
    begin {

        
        function Test-BitdefenderProcess {
            param (
                [string]$BitdefenderProcessName
            )

            try {
                $BitdefenderProcess = Get-Process -Name $BitdefenderProcessName -ErrorAction Stop
                if ($BitdefenderProcess) {
                    $IsBitdefenderProcessRunning = $true
                    $IsBitdefenderProcessRunning
                }
                
            }
            catch [Microsoft.PowerShell.Commands.ProcessCommandException] {
                Write-Warning "Unable to find process $BitdefenderProcessName on $env:COMPUTERNAME"
                $IsBitdefenderProcessRunning = $false
                $IsBitdefenderProcessRunning
            }
            catch {
                Write-Warning $_.Exception.Message
                $IsBitdefenderProcessRunning = $false
                $IsBitdefenderProcessRunning
            }
            
        }


        function Test-BitdefenderInstallationPath {
            param (
                [string]$BitdefenderInstallationPath
            )

            $IsBitdefenderInstalled = Test-Path -Path $BitdefenderInstallationPath
            if (!($IsBitdefenderInstalled)) {
                Write-Warning "Unable to find $BitdefenderInstallationPath on $env:COMPUTERNAME"
            }
            $IsBitdefenderInstalled

        }



    }
    
    process {        
        foreach ($Computer in $ComputerName) {

            try {
                # Setup remote PowerShell session
                Write-Verbose -Message "Establishing remote session to $Computer"
                $Session = New-PSSession -ComputerName $Computer -Credential $Credential -ErrorAction Stop

                # Is Bitdefender Installed
                Write-Verbose -Message "Check if Bitdefender is installed at $BitdefenderInstallationPath."
                $IsBitdefenderInstalled = Invoke-Command -Session $Session -ScriptBlock ${function:Test-BitdefenderInstallationPath} -ArgumentList $BitdefenderInstallationPath

                if ($IsBitdefenderInstalled) {
                    # Is Bitdefender Running
                    Write-Verbose -Message "Check if $BitdefenderProcessName is running."
                    $IsBitdefenderProcessRunning = Invoke-Command -Session $Session -ScriptBlock ${function:Test-BitdefenderProcess} -ArgumentList $BitdefenderProcessName

                    # Is Bitdefender Security Service configured
                    $BitdefenderSecurityServiceName = 'EPSecurityService'
                    Write-Verbose -Message "Check Bitdefender service $BitdefenderSecurityServiceName"
                    $BitdefenderService = Invoke-Command -Session $Session -ScriptBlock ${function:Test-Service} -ArgumentList $BitdefenderSecurityServiceName
                    $IsBitdefenderServiceHealthy = $BitdefenderService.ServiceExists -and $BitdefenderService.IsRunning -and $BitdefenderService.IsAutomatic


                    # Load helper functions into remote session
                    Import-SessionFunction -FunctionName Convert-UnixTimeToDateTime -Session $Session
                    Import-SessionFunction -FunctionName Convert-TimeZone -Session $Session

                    # Is Bitdefender up to date
                    Write-Verbose -Message "Check if Bitdefender is up to date"
                    $BitdefenderSignatureDate = Invoke-Command -Session $Session -ScriptBlock ${function:Get-BitdefenderSignatureDate}
                    Write-Verbose "Bitdefender signature date: $BitdefenderSignatureDate"
                    $BitdefenderUpdateFileData = Invoke-Command -Session $Session -ScriptBlock ${function:Get-BitdefenderUpdateFileData}

                    $IsBitdefenderUptodate = (New-Timespan -Start $BitdefenderSignatureDate -End (Get-Date)).TotalDays -le 1

                    # Check Bitdefender component status
                    Write-Verbose -Message "Checking Bitdefender component status"
                    $BitdefenderComponentStatus = Invoke-Command -Session $Session -ScriptBlock ${function:Get-BitdefenderComponentStatus}
                    $IsBitdefenderComponentStatusHealthy = $BitdefenderComponentStatus.FirewallEnabled -and $BitdefenderComponentStatus.AntivirusEnabled -and $BitdefenderComponentStatus.AntispywareEnabled

                }
                else {
                    $IsBitdefenderProcessRunning = $false
                    $IsBitdefenderServiceHealthy = $false
                    $IsBitdefenderUptodate = $false
                }

                

                # Tear down remove PowerShell session
                Write-Verbose -Message "Removing remote session to $Computer"
                Remove-PSSession $Session

                # Creating Object
                $BitdefenderStatusProperties = [ordered]@{
                    ComputerName                    = $Computer
                    IsBitdefenderInstalled          = $IsBitdefenderInstalled
                    IsBitdefenderProcessRunning     = $IsBitdefenderProcessRunning
                    IsBitdefenderServiceHealthy     = $IsBitdefenderServiceHealthy
                    IsBitdefenderUptodate           = $IsBitdefenderUptodate
                    IsBitdefenderAntivirusEnabled   = $BitdefenderComponentStatus.AntivirusEnabled
                    IsBitdefenderAntispywareEnabled = $BitdefenderComponentStatus.AntispywareEnabled
                    IsBitdefenderFirewallEnabled    = $BitdefenderComponentStatus.FirewallEnabled
                    IsBitdefenderHealthy            = $IsBitdefenderInstalled -and $IsBitdefenderProcessRunning -and $IsBitdefenderServiceHealthy -and $IsBitdefenderComponentStatusHealthy
                    SignatureVersion                = $BitdefenderUpdateFileData.Version
                    SignatureNumber                 = $BitdefenderUpdateFileData.'Signature Number'
                    SignatureDate                   = $BitdefenderSignatureDate
                    SignatureUpdateTime             = $BitdefenderUpdateFileData.'Update time'

                }
                $BitdefenderStatus = New-Object -TypeName PSCustomObject -Property $BitdefenderStatusProperties
                $BitdefenderStatus
            }
            catch {
                Write-Error -Message $_.Exception
                if ($Session.Name) {
                    Write-Verbose -Message "Removing remote session to $Computer"
                    Remove-PSSession -Session $Session
                }
            }
        }
    }
    
    end {
    }
}