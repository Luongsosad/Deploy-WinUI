# Import Certificate to Trusted Root
# Chạy PowerShell as Administrator

param(
    [Parameter(Mandatory=$false)]
    [string]$CertPath = ".\DemoDeploy_TemporaryKey.pfx",
    
    [Parameter(Mandatory=$false)]
    [string]$Password = "DemoPassword123"
)

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "   Import Certificate to Trusted Root" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if running as Administrator
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Host "⚠️  This script must run as Administrator!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Right-click PowerShell → Run as Administrator" -ForegroundColor Yellow
    Write-Host "Then run: .\Import-Certificate.ps1" -ForegroundColor White
    exit 1
}

if (-not (Test-Path $CertPath)) {
    Write-Error "Certificate file not found: $CertPath"
    exit 1
}

Write-Host "Importing certificate to Trusted Root..." -ForegroundColor Yellow

try {
    # Import certificate
    $securePwd = ConvertTo-SecureString -String $Password -Force -AsPlainText
    $cert = Import-PfxCertificate -FilePath $CertPath -CertStoreLocation Cert:\LocalMachine\Root -Password $securePwd
    
    Write-Host "✅ Certificate imported successfully!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Certificate Details:" -ForegroundColor Cyan
    Write-Host "  Subject: $($cert.Subject)" -ForegroundColor White
    Write-Host "  Thumbprint: $($cert.Thumbprint)" -ForegroundColor White
    Write-Host "  Valid Until: $($cert.NotAfter)" -ForegroundColor White
    Write-Host ""
    Write-Host "✅ You can now install MSIX packages signed with this certificate!" -ForegroundColor Green
    
} catch {
    Write-Error "Failed to import certificate: $_"
    Write-Host ""
    Write-Host "Manual import:" -ForegroundColor Yellow
    Write-Host "1. Open certmgr.msc" -ForegroundColor White
    Write-Host "2. Right-click 'Trusted Root Certification Authorities' → Certificates" -ForegroundColor White
    Write-Host "3. All Tasks → Import" -ForegroundColor White
    Write-Host "4. Select: $CertPath" -ForegroundColor White
    Write-Host "5. Password: $Password" -ForegroundColor White
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
