# POwershell commando's om een selfsigned certificate te maken wat gebruikt kan worden voor
# unattended scripting naar Exchange online


$connectEXO = @{
    CertificateFilePath = 'C:\Users\hans.vandeursen\OneDrive\Baudevoort Consultancy\Certs\ExoCert.pfx'  
    CertificatePassword = $(ConvertTo-SecureString -String 'W@chtW00rd!3' -AsPlainText -Force)
    AppID = '394eb93e-137f-4323-b4f8-2c564fceb1d1'
    Organization = 'baudevoortcompany.onmicrosoft.com'
}

Connect-ExchangeOnline @connectEXO

Get-PSSession

Get-EXOMailbox hans@onzenhans.nl | ft DisplayName