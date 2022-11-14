Function Get-TimeSpan ($Aged) {
    Switch -Regex ($Aged) {
        H { (Get-Date).AddHours( - ($Aged -replace '\D', '')) ; Break }     
        D { (Get-Date).AddDays( - ($Aged -replace '\D', '')) ; Break }      
        W { (Get-Date).AddDays( - (7 * ($Aged -replace '\D', ''))) ; Break } 
        M { (Get-Date).AddMonths( - ($Aged -replace '\D', '')) ; Break }  
        Y { (Get-Date).AddYears( - ($Aged -replace '\D', '')) ; Break }    
        default { Get-Date }
    }
}
Function Get-ADUserDisabledDate {
    [CmdletBinding()]
    Param($Identity)
    
    Process {
        Get-ADUser -Identity $Identity -Properties 'whenChanged' | Select-Object -ExpandProperty 'whenChanged'
    }
}
Function Move-DisabledADUsers {
    [CmdletBinding()]
    Param ($SearchBase, $TargetPath, $Aged)

    Begin {
        Write-Verbose -Message "Move-DisabledADUsers: begin by quering $SearchBase for disabled accounts"

        $ADUsers = Get-ADUser -SearchBase $SearchBase -Filter { Enabled -eq $false } -SearchScope 'OneLevel'
        $whenAged = (Get-TimeSpan -Aged $Aged)

        $usersMoved = New-Object System.Collections.ArrayList
        $groupLicencing = "ogd-group-based-licensing-u01"
    }

    
    Process {
        Write-Verbose -Message "Move-DisabledADUsers: processing each account"

        ForEach ($Identity in $ADUsers) {
            $whenChanged = (Get-ADUserDisabledDate -Identity $Identity.DistinguishedName)
            $SamAccountName = $Identity.SamAccountName
            $Message = "Move-DisabledADUsers: Processing " + $SamAccountName + " probably disabled on " + $whenChanged

            # Set breakpoint and change value  to force move
            $doit = $false 
            If ($whenChanged -le $whenAged -or $doit) {
                $Message = $Message + ". This is older than " + $whenAged + ". Moving ..."
                Write-Verbose -Message $Message
                Try {
                    Move-ADObject -Identity $Identity.DistinguishedName -TargetPath $TargetPath
                    Write-Output "Successfully moved $($Identity.SamAccountName) to $($TargetPath)"
                
                    $usersMoved.Add($Identity)
                    Try {
                        Remove-ADGroupMember -Identity $groupLicencing -Members $Identity.SamAccountName -Confirm:$false
                    }
                    Catch {
                        Write-Output "Could not remove $($Identity.SamAccountName) from $groupLicencing!"
                        Write-Output $_.Exception.Message
                    }
                }
                Catch {
                    Write-Output "Could not move $($Identity.SamAccountName) to $($TargetPath)"
                    Write-Output $_.Exception.Message
                }
            }
            Else {
                # doesn't have to be be disabled (yet) because deletion was too recent
                $Message = $Message + ". This is too recent, skipping."
                Write-Verbose -Message $Message
            }
        } # end ForEach

        if ($usersMoved.Count -gt 0) {
            # Users have been moved. Assign Business basic license
            Invoke-Command -ComputerName acc-sync01 -ScriptBlock { Start-ADSyncSyncCycle }
            Write-Verbose "Forceer synchronisatie tussen AureAD en on-prem AD en wacht vijf minuten totdat die klaar is."
            Start-Sleep -Seconds 600

            ForEach ($Identity in $usersMoved) {
                $userupn = $Identity.userPrincipalName
                $planName = "O365_BUSINESS_ESSENTIALS"
                $License = New-Object -TypeName Microsoft.Open.AzureAD.Model.AssignedLicense
                $License.SkuId = (Get-AzureADSubscribedSku | Where-Object -Property SkuPartNumber -Value $planName -EQ).SkuID
                $LicensesToAssign = New-Object -TypeName Microsoft.Open.AzureAD.Model.AssignedLicenses
                $LicensesToAssign.AddLicenses = $License

                try {
                    Set-AzureADUserLicense -ObjectId $userUPN -AssignedLicenses $LicensesToAssign
                    Write-Output "Business Basic license assigned for $($Identity.SamAccountName)"
                }
                Catch {
                    Write-Output "Could not assign license to $($Identity.SamAccountName)"
                    Write-Output $_.Exception.Message
                }
            }
        } # end ForEach
    }

    End {
        Write-Verbose -Message "Move-DisabledADUsers: end"
    }
}

"TODO: Use stored credentials and schedule script in TaskScheduler od DevOps portal"
Import-Module AzureAD

try {
    Connect-AzureAD
}
catch {
    exit 1
}

$SearchBase = 'OU=Users,OU=Accare,DC=accare,DC=nl'
$TargetPath = 'OU=Disabled,OU=Users,OU=Accare,DC=accare,DC=nl'
Move-DisabledADUsers -SearchBase $SearchBase -TargetPath $TargetPath -Aged "7d"