# =========================================================================================================================
# Script               : remove_disabled_users_from_all_groups.ps1
# Version              : 1.0
# Creation date        : 08/11/2022
# Author               : Hans van Deursen
# Purpose              : This script collects all disabled AD users and removes them from cloud based groups 
#                        Office365 groups, and distribution lists.
# =========================================================================================================================

# =========================================================================================================================
# Revisionhistory
# Date :
# Revision :
#
# =========================================================================================================================

# =========================================================================================================================
# Check (Initial Checks)
# =========================================================================================================================

# =========================================================================================================================
# Modules (Import additional modules)
# =========================================================================================================================

# =========================================================================================================================
# Connections
# =========================================================================================================================

$connectEXO = @{
    CertificateFilePath = 'C:\temp\ExoCert.pfx'
    CertificatePassword = $(ConvertTo-SecureString -String 'v00rAccar3' -AsPlainText -Force)
    AppID = '394eb93e-137f-4323-b4f8-2c564fceb1d1'
    Organization = 'accare.nl'
    }
Connect-ExchangeOnline @connectEXO


$tenantId = "e83fbe90-7c5e-45d0-a497-26ec1b9f8b23"
$appId = "c431b92f-e073-43e9-9881-8b32c5cf0b6c"
$thumb = "E4626DAE0F299503347738A490261C429E8EE71C"
Connect-AzureAD -TenantId $tenantId -ApplicationId  $appId -CertificateThumbprint $thumb

# =========================================================================================================================
# Init
# =========================================================================================================================

# your initial variables here.
$ErrorActionPreference = "SilentlyContinue"
$SearchBase = 'OU=Disabled,OU=Users,OU=Accare,DC=accare,DC=nl'


# =========================================================================================================================
# Configuration
# =========================================================================================================================


#Create Table object
#Define Columns


# =========================================================================================================================
# FUNCTIONS
# =========================================================================================================================

Function GetDistributionGroupMembers {
    
    param ($group,$CheckUser)
    
    $members = Get-DistributionGroupMember -Identity $group.Identity
       
    foreach ($member in $members) 
        {
         Write-host "Member DisplayName: "$Member.DisplayName
         Write-Host "member live ID    : "$member.WindowsLiveID
         Write-host "CheckUser         : "$CheckUser
         Write-Host `n
         
         If ($Member.WindowsLiveID -eq $CheckUser)
            {Write-host "User " $Member.DisplayName "wordt verwijderd uit groep " $group.DisplayName -ForegroundColor Yellow
             Write-Host `n 
             Remove-DistributionGroupMember -Identity $group.Identity -Member $member.DisplayName -Confirm:$false
             } #end of If
            } #end of foreach
     } #end of function
            
Function GetOffice365GroupMembers {
    
    param ($group,$CheckUser)
    
    $members = Get-UnifiedGroupLinks -Identity $group.Identity -LinkType Member
    
    foreach ($member in $members) 
        {Write-Host $group.DisplayName
         Write-host "Member DisplayName: "$Member.DisplayName
         Write-Host "member live ID :" $member.WindowsLiveID
         Write-host "CheckUser:          "$CheckUser
         Write-Host `n

         If ($Member.WindowsLiveID -eq $CheckUser)
            {Write-host "User " $Member.WindowsLiveID "wordt verwijderd uit groep " $group.DisplayName -ForegroundColor Yellow
             Write-Host `n  
             Remove-UnifiedGroupLinks -Identity $group.Identity -LinkType Members -Links $member.WindowsLiveID -Confirm:$false  
            } #end of IF
    } #end of ForEach
 } #end of Function

# =========================================================================================================================
# SCRIPT
# =========================================================================================================================

Clear-host

#$ADUsers = Get-ADUser -SearchBase $SearchBase -Filter -SearchScope 'OneLevel'

$ADUsers = @("bart@baudevoort.nl";"britt@baudevoort.nl")

ForEach ($ADUser in $ADUsers)
    {
     
     #"Start distribution groups"

     $groups = Get-DistributionGroup
     foreach ($group in $groups){
              GetDistributionGroupMembers $group $ADUser
              } #end of ForEach
              
     
     #"Start Office365 groups"

     $groups = Get-UnifiedGroup
     foreach ($group in $groups){
             GetOffice365GroupMembers $group $ADUser
             } #end of forEach
      
    } #end of ForEach
    


# =========================================================================================================================
# OUTPUT
# =========================================================================================================================



# =========================================================================================================================
# END
# =========================================================================================================================Clear-host

