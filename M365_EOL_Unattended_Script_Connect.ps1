# POwershell commando's om een selfsigned certificate te maken wat gebruikt kan worden voor
# unattended scripting naar Exchange online

# Region Create Certificate
# Create certificates only once.


$newCert = @{
    DnsName = 'baudevoort-consultancy.nl'
    CertStoreLocation = 'Cert:\CurrentUser\My'
    NotAfter = (Get-Date).AddYears(1)
    KeySpec = 'KeyExchange'
}

$myCert = New-SelfSignedCertificate @newCert

# Export certificate to .pfx file
$exportCert = @{
    FilePath = 'ExoCert.pfx'
    Password = $(ConvertTo-SecureString -String "!nBR@ndev00rt" -AsPlainText -Force)
}
$myCert | Export-PfxCertificate @exportCert

# Export certificate to .cer file
$myCert | Export-Certificate -FilePath ExoCert.cer




#region USe Certificate
$connectEXO = @{
    CertificateFilePath = 'C:\temp\ExoCert.pfx'
    CertificatePassword = $(ConvertTo-SecureString -String '!nBR@ndev00rt' -AsPlainText -Force)
    AppID = '394eb93e-137f-4323-b4f8-2c564fceb1d1'
    Organization = 'baudevoortcompany.onmicrosoft.com'
}

Connect-ExchangeOnline @connectEXO

Connect-AzAccount @connectEXO


#Test

Get-EXOMailbox hans@onzenhans.nl | ft DisplayName