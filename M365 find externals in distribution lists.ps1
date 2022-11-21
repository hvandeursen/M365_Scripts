Clear-Host

$m = "ExchangeOnlineManagement"

# If module is imported say that and do nothing
    if (Get-Module | Where-Object {$_.Name -eq $m}) {
        write-host "Module $m is already imported."
    }
    else {
        Import-Module ExchangeOnlineManagement
    }

#Connect-ExchangeOnline


function GetMembers {
    param ($group)
    switch($group.RecipientTypeDetails) {
        "GroupMailbox" {
            $members = Get-UnifiedGroupLinks -Identity $group.Identity -LinkType Member
        }
        "MailUniversalDistributionGroup"{
            $members = Get-DistributionGroupMember -Identity $group.Identity
        }
        default {
           "No match: $($group.RecipientTypeDetails)"
           break
        }
    }
    
    foreach ($member in $members) {
        switch ($member.recipientType) {
            {($_ -eq "MailUser") -or ($_ -eq "MailContact")} {
                $mail = $member.PrimarySmtpAddress
                if ($mail -match "accare.nl") {
                    break;
                }
                "Group $($group.DisplayName) - $($member.DisplayName) <$mail>"
            }
            "User" {
                # Users don't have a mailbox
            }
            "UserMailbox" {
                # A mailbox will always be Internal
            }
            default {
                GetMembers ($member)
            }
        }
    }
}
"Start distribution groups"
$groups = Get-DistributionGroup
foreach ($group in $groups) {
    GetMembers $group
}
"Start Office365 groups"
$groups = Get-UnifiedGroup
foreach ($group in $groups) {
    # "Start recursive membershipscan"
    GetMembers $group
}