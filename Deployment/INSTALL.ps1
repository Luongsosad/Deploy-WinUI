# Complete Installation Guide

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "   DemoDeploy - Installation Steps" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "BƯỚC 1: Import Certificate (Administrator)" -ForegroundColor Yellow
Write-Host "-------------------------------------------" -ForegroundColor Gray
Write-Host "1. Mở PowerShell as Administrator" -ForegroundColor White
Write-Host "2. Chạy:" -ForegroundColor White
Write-Host "   cd Deployment" -ForegroundColor Green
Write-Host "   .\Import-Certificate.ps1" -ForegroundColor Green
Write-Host ""
Write-Host "⚠️  Phải import certificate trước, nếu không sẽ lỗi 'Publisher not verified'" -ForegroundColor Red
Write-Host ""

Write-Host "BƯỚC 2: Uninstall old version (nếu có)" -ForegroundColor Yellow
Write-Host "-------------------------------------------" -ForegroundColor Gray
Write-Host "Get-AppxPackage *DemoDeploy* | Remove-AppxPackage" -ForegroundColor Green
Write-Host ""

Write-Host "BƯỚC 3: Install MSIX Package" -ForegroundColor Yellow
Write-Host "-------------------------------------------" -ForegroundColor Gray
Write-Host "cd Deployment" -ForegroundColor Green
Write-Host "Add-AppxPackage -Path 'DemoDeploy_1.0.1.0_x64.msix'" -ForegroundColor Green
Write-Host ""

Write-Host "BƯỚC 4: Launch App" -ForegroundColor Yellow
Write-Host "-------------------------------------------" -ForegroundColor Gray
Write-Host "- Tìm 'DemoDeploy' trong Start Menu" -ForegroundColor White
Write-Host "- Hoặc chạy: start shell:AppsFolder\$(Get-AppxPackage *DemoDeploy* | Select-Object -ExpandProperty PackageFamilyName)!App" -ForegroundColor White
Write-Host ""

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "📝 Troubleshooting" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Lỗi: 'Publisher certificate could not be verified'" -ForegroundColor Red
Write-Host "→ Chạy lại BƯỚC 1 (Import certificate)" -ForegroundColor Yellow
Write-Host ""
Write-Host "Lỗi: 'Package already installed'" -ForegroundColor Red
Write-Host "→ Chạy BƯỚC 2 để uninstall trước" -ForegroundColor Yellow
Write-Host ""
Write-Host "Lỗi: 'ms-appinstaller protocol disabled'" -ForegroundColor Red
Write-Host "→ Dùng phương pháp install local (BƯỚC 3)" -ForegroundColor Yellow
Write-Host ""

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "✅ Ready for Demo!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
