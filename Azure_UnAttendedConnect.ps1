# --------------------
# SECTION 1
# --------------------
# Interactive login
Import-Module AzureAD
Connect-AzureAD
$users = Get-AzureADUser 
$users | Ft -a


# --------------------
# SECTION 2
# --------------------
# Registration
# Login to Azure AD PowerShell With Admin Account
Connect-AzureAD 
    
# Create the self signed cert
$currentDate = Get-Date
$endDate = $currentDate.AddYears(1)
$notAfter = $endDate.AddYears(1)
$pwd = "pass@word1"
$domain = "OnzenHansUAC.onzenhans.nl"
$thumb = (New-SelfSignedCertificate -CertStoreLocation cert:\currentuser\my -DnsName $domain -KeyExportPolicy Exportable -Provider "Microsoft Enhanced RSA and AES Cryptographic Provider" -NotAfter $notAfter).Thumbprint


$pwd = ConvertTo-SecureString -String $pwd -Force -AsPlainText
Export-PfxCertificate -cert "cert:\currentuser\my\$thumb" -FilePath c:\temp\certfiles\OnzenHansUAC.pfx -Password $pwd
    
# Load the certificate
$cert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate("C:\temp\certfiles\OnzenHansUAC.pfx", $pwd)
$keyValue = [System.Convert]::ToBase64String($cert.GetRawCertData())
    
    
# Create the Azure Active Directory Application
$application = New-AzureADApplication -DisplayName "OnzenHans AD Unattended connect" -IdentifierUris $domain
New-AzureADApplicationKeyCredential -ObjectId $application.ObjectId -CustomKeyIdentifier "OnzenHansUAC" -StartDate $currentDate -EndDate $endDate -Type AsymmetricX509Cert -Usage Verify -Value $keyValue
    
# Create the Service Principal and connect it to the Application
$sp=New-AzureADServicePrincipal -AppId $application.AppId
    
# Give the Service Principal Reader access to the current tenant (Get-AzureADDirectoryRole)
$roleId = (Get-AzureADDirectoryRole |? {$_.DisplayName -eq "Directory Readers"}).ObjectId
Add-AzureADDirectoryRoleMember -ObjectId $roleId -RefObjectId $sp.ObjectId
    
# Get Tenant Detail
$tenant=Get-AzureADTenantDetail
# Now you can login to Azure PowerShell with your Service Principal and Certificate
Connect-AzureAD -TenantId $tenant.ObjectId -ApplicationId  $sp.AppId -CertificateThumbprint $thumb


# --------------------
# SECTION 3
# --------------------
# Unattend automation
$tenantId = "e83fbe90-7c5e-45d0-a497-26ec1b9f8b23"
$appId = "c431b92f-e073-43e9-9881-8b32c5cf0b6c"
$thumb = "E4626DAE0F299503347738A490261C429E8EE71C"
Connect-AzureAD -TenantId $tenantId -ApplicationId  $appId -CertificateThumbprint $thumb
$users = Get-AzureADUser 
$users | Format-Table -a