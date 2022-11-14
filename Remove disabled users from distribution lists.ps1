Clear-Host
<#
$m = "ExchangeOnlineManagement"

# If module is imported say that and do nothing
    if (Get-Module | Where-Object {$_.Name -eq $m}) {
        write-host "Module $m is already imported."
    }
    else {
        Import-Module ExchangeOnlineManagement
    }


Connect-ExchangeOnline

$m = "AzureAD"

# If module is imported say that and do nothing
    if (Get-Module | Where-Object {$_.Name -eq $m}) {
        write-host "Module $m is already imported."
    }
    else {
        Import-Module AzureAD
    }

Connect-AzureAD

#>

$DistributionGroups = get-DistributionGroup
Remove-Item -Path "C:\temp\*.*" 

ForEach ($DistributionGroup in $DistributionGroups) 
    {
     Write-Host "---------------------------------------------------------------"
     Write-Host $DistributionGroup
     Write-Host "---------------------------------------------------------------"
         
     $GroepDisplayName = $DistributionGroup.DisplayName
     $datetime = Get-Date -Format "yyyy.MM.dd_HH-mm-ss"
     $file_name = $GroepDisplayName + "_" + $datetime + ".csv"
     $file_path = "c:\temp\" + $file_name;         
     $MemberArray = @();
     
     $Name = "Naam"
     $Type = "Type"
     $mailAddress = "Email"
     $Enabled = "Enabled"
     $MemberArray += ,@("")

     $MemberArray += ,@($Name, $Type, $mailAddress, $Enabled);

     $GroupMembers = Get-DistributionGroupMember -Identity $DistributionGroup.ID | Select-Object Name, Displayname, ObjectClass, ObjectCategory, RecipientType, RecipientTypeDetails, PrimarySMTPAddress, ExternalDirectoryObjectId
            
     ForEach ($GroupMember in $GroupMembers)
           {
            If ($Groupmember.ObjectCategory -like "*Person") 
               {
                Write-Host $Groupmember.Name " is een user."
                $Name = $GroupMember.Name + ";"
                $Type = "User;"
                $mailAddress = $GroupMember.PrimarySmtpAddress + ";"
                
                $ADUser = Get-AzureADUser -ObjectId $GroupMember.ExternalDirectoryObjectId | Select-Object Mail, AccountEnabled
                
                $Enabled = $ADUser.AccountEnabled
                
                $MemberArray += ,@($Name, $Type, $mailAddress, $Enabled);
                
                }
            If ($Groupmember.ObjectCategory -like "*Group") 
               {
                Write-Host $Groupmember.DisplayName " is een Group."
                $Name = $GroupMember.DisplayName
                $Type = "Group"
                $mailAddress = $GroupMember.PrimarySmtpAddress
                $MemberArray += ,@($Name, $Type, $mailAddress);
                }
            }
            
            #Write-Host $MemberArray
            #Read-Host

            Foreach($item in $MemberArray) 
            { 
             $csv_string = "";
             $csv_string = $csv_string + $item + ";";
             Add-Content $file_path $csv_string;
             }
             
             $MemberArray.Clear()
          }
       