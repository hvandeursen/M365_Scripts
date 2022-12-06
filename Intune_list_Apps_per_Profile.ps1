<#
# Use Install-moduleonly if the module was not installed before
#Install-Module -Name Microsoft.Graph.Intune
Import-module -Name Microsoft.Graph.Intune

Connect-MSGraph -ForceInteractive
Update-MSGraphEnvironment -SchemaVersion beta

Connect-AzureAD

#>
Clear-host

$Tenant = get-AzTenant

$Apps = Get-IntuneMobileApp -Filter "isAssigned eq true" -Select id, displayName, lastModifiedDateTime, categories, assignments -Expand assignments, categories


ForEach ($app in $Apps){
        #Write-host $App.Displayname
        $AppAssignments = $App.assignments
        Foreach ($AppAssignment in $AppAssignments){
            <#
            Write-Host 'Assignment ID:    '$AppAssignment.id
            Write-Host 'Assignment Intnet:'$AppAssignment.intent
            Write-Host 'Assignment target:'$AppAssignment.target
            Write-Host 'Target is:        '$AppAssignment.target.'@odata.type'
            Write-Host `n
            #>

            If ($AppAssignment.target.'@odata.type' -eq '#microsoft.graph.allLicensedUsersAssignmentTarget') {
                #Write-host $App.Displayname ' is gekoppeld aan All Users' -ForegroundColor Green
                }

            If ($AppAssignment.target.'@odata.type' -eq '#microsoft.graph.allDevicesAssignmentTarget') {
                #Write-host $App.Displayname ' is gekoppeld aan All Devices' -ForegroundColor Magenta
                }
            
            If ($AppAssignment.target.'@odata.type' -eq '#microsoft.graph.groupAssignmentTarget') {
                $group = Get-AzureADGroup -ObjectId $AppAssignment.target.GroupID

                #Write-Host $App.Displayname 'is gekoppeld aan Group: ' $group.DisplayName -ForegroundColor Cyan

                If ($group.DisplayName -eq 'Android personal devices with work profile') {
                     $NewGroup = 'Devices Android BYOD'
                     Write-Host $app.displayName 'wordt toegvoegd aan ' $NewGroup -ForegroundColor Yellow
                     #Write-host `n
                     }

                If ($group.DisplayName -eq 'Android Corporate owned with Work Profile devices') {
                    $NewGroup = 'Devices Android COWP'
                    Write-Host $app.displayName 'wordt toegvoegd aan ' $NewGroup -ForegroundColor Yellow 
                    #Write-host `n
                    }
                
            }
            #Read-Host 'Enter to continue'

           } 


            }
       
