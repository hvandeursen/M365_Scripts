Clear-Host


$connectEXO = @{
    CertificateFilePath = 'C:\temp\ExoCert.pfx'
    CertificatePassword = $(ConvertTo-SecureString -String '!nBR@ndev00rt' -AsPlainText -Force)
    AppID = '394eb93e-137f-4323-b4f8-2c564fceb1d1'
    Organization = 'baudevoortcompany.onmicrosoft.com'
}
Connect-ExchangeOnline @connectEXO

Connect-AzAccount @connectEXO

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
       