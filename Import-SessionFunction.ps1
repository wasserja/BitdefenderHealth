<#
.SYNOPSIS
Import advanced function code to remote PowerShell session.

.DESCRIPTION
Import advanced function code to remote PowerShell session.
Import-SessionFunction allows you to export the code from a local function and import
the function into memory of an existing PowerShell session. Once the function is loaded
in the remote session you can call that function with other cmdlets and/or functions.

This supports open source PowerShell advanced functions only.

.PARAMETER FunctionName
Enter the name of a function.

.PARAMETER Session
Enter a Powershell session object

.EXAMPLE
Import-SessionFunction -FunctionName Convert-UnixTimeToDateTime -Session $Session

.NOTES
Created by: Jason Wasser @wasserja
Modified: 7/26/2017 10:34:58 AM 
#>
function Import-SessionFunction {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$FunctionName,
        [Parameter(Mandatory = $true)]
        [System.Management.Automation.Runspaces.PSSession]$Session
    )
    
    Write-Verbose -Message "Getting module for function $FunctionName"
    $Module = Get-Module (Get-Command -Name $FunctionName).Module
    Write-Verbose -Message "$FunctionName is part of module $($Module.Name)"
    Write-Verbose -Message "Importing function $FunctionName to remote session on $($Session.ComputerName)"
    $FunctionCode = (Get-Command "$($Module.ModuleBase)\$FunctionName.ps1").ScriptContents
    Invoke-Command -Session $Session -ScriptBlock {param ($FunctionCode) Invoke-Expression $FunctionCode} -ArgumentList $FunctionCode, $Session
    Write-Verbose -Message "Function $FunctionName has been imported to remote session on $($Session.ComputerName)"
}