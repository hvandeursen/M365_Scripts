
# Unattend automation
$tenantId = "e83fbe90-7c5e-45d0-a497-26ec1b9f8b23"
$appId = "b872e50d-6aac-4cda-a3c9-7ba6340e28ef"
$thumb = "C0888D8D2BF39846161B61F66B6AAB19FB6AD95C"
Connect-AzureAD -TenantId $tenantId -ApplicationId  $appId -CertificateThumbprint $thumb
Get-AzureADDomain | Format-List 