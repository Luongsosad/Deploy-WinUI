# PowerShell Script to Create Self-Signed Certificate for Testing
# Usage: .\Create-Certificate.ps1

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Create Self-Signed Certificate for MSIX" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$certSubject = "CN=LUONG"
$certName = "DemoDeploy_TestCert"
$certPassword = Read-Host "Enter certificate password" -AsSecureString

Write-Host "Creating self-signed certificate..." -ForegroundColor Yellow

# Create certificate
$cert = New-SelfSignedCertificate `
    -Type Custom `
    -Subject $certSubject `
    -KeyUsage DigitalSignature `
    -FriendlyName $certName `
    -CertStoreLocation "Cert:\CurrentUser\My" `
    -TextExtension @("2.5.29.37={text}1.3.6.1.5.5.7.3.3", "2.5.29.19={text}")

Write-Host "Certificate created successfully!" -ForegroundColor Green
Write-Host "Thumbprint: $($cert.Thumbprint)" -ForegroundColor Cyan
Write-Host ""

# Export certificate
$exportPath = ".\DemoDeploy_TemporaryKey.pfx"
Write-Host "Exporting certificate to: $exportPath" -ForegroundColor Yellow

Export-PfxCertificate `
    -Cert $cert `
    -FilePath $exportPath `
    -Password $certPassword

Write-Host "Certificate exported successfully!" -ForegroundColor Green
Write-Host ""

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. Import the certificate to Trusted Root" -ForegroundColor White
Write-Host "   - Open Certificate Manager (certmgr.msc)" -ForegroundColor White
Write-Host "   - Import the .pfx to Trusted Root Certification Authorities" -ForegroundColor White
Write-Host "2. Update Package.appxmanifest with the certificate subject" -ForegroundColor White
Write-Host "3. Build and sign your MSIX package" -ForegroundColor White
Write-Host ""
Write-Host "Certificate subject: $certSubject" -ForegroundColor Cyan
Write-Host "Certificate file: $exportPath" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
