# =========================================================================================================================
# Script               : Exo_find_calendar_permissions_for_user.ps1
# Version              : 1.0
# Creation date        : 22-02-2023
# Author               : Hans van Deursen
# Purpose              : Dit script haalt de agend rechten van een bepaalde user op andere users op.
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
# Import-Module ExchangeOnlineManagement



# =========================================================================================================================
# Connections
# =========================================================================================================================

# Connect-ExchangeOnline

# =========================================================================================================================
# Init
# =========================================================================================================================

# your initial variables here.
$ErrorActionPreference = "SilentlyContinue"

[System.Collections.ArrayList]$Array = @(
    @{ Identity=(''); AccessRights=(''); SharingPermissionsFlags=('')}
    )

$Mailboxes = Get-EXOMailbox
$CheckUser = "JvRozendaal@verhoevenbv.com"


# =========================================================================================================================
# Configuration
# =========================================================================================================================


#Create Table object
#Define Columns


# =========================================================================================================================
# FUNCTIONS
# =========================================================================================================================

# Your functions here.

#function

# =========================================================================================================================
# SCRIPT
# =========================================================================================================================

# Your script here.

Clear-host


ForEach ($Mailbox in $Mailboxes )
    {
     #Write-Host $Mailbox.UserPrincipalName
     $Agenda = $Mailbox.UserPrincipalName + ":\Agenda"
     #Write-host $Agenda

     Try {
          $Toegang = Get-EXOMailboxFolderPermission -Identity $Agenda -User $CheckUser -ErrorAction Stop
          $Array.Add( @{ IDentity=($Toegang.Identity); AccessRights=($Toegang.AccessRights); SharingPermissionsFlags =($Toegang.SharingPermissionsFlags)})
          
          }
      Catch {
            #Write-host "..."
            }

     $Agenda = $Mailbox.UserPrincipalName + ":\Calendar"

     Try {
          $Toegang = Get-EXOMailboxFolderPermission -Identity $Agenda -User $CheckUser -ErrorAction Stop
          $Array.Add( @{ IDentity=($Toegang.Identity); AccessRights=($Toegang.AccessRights); SharingPermissionsFlags =($Toegang.SharingPermissionsFlags)} )
          
          }
      Catch {
            Write-host "."
            }

     }




# =========================================================================================================================
# OUTPUT
# =========================================================================================================================

Clear-Host

Write-Host '-------------------------------------------------------------'
Write-Host 'Userfolder     :  Accessrights     :   SharingPermissionFlags'
Write-Host `n

For ($a=0;$a -le($Array.Count);$a++){
     Write-Host $Array[$a].Identity " : " $Array[$a].AccessRights "  :  " $Array[$a].SharingPermissionsFlags
}





# =========================================================================================================================
# END
# =========================================================================================================================