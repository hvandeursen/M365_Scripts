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

Import-Module -Name AzureAD
Import-Module -Name MSonline
Import-Module -Name ExchangeOnlineManagement

# =========================================================================================================================
# Connections
# =========================================================================================================================

Connect-AzureAD
Connect-MsolService
Connect-ExchangeOnline

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
    
    Write-host `n
    Write-host "Group = " $group
    Write-host "Check user = "$CheckUser
    Write-host "-------------------------------"    Write-host `n    
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
    <#
    Write-host `n
    Write-host "Group = " $group
    Write-host "Check user = "$CheckUser
    Write-host "-------------------------------"    Write-host `n    #>
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

