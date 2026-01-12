# Quick Build Script - Simplified MSIX Build
# Usage: .\Quick-Build.ps1

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "   Quick MSIX Build for Demo" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Step 1: Build the project
Write-Host "[1/3] Building project..." -ForegroundColor Yellow
dotnet build ..\DemoDeploy.csproj -c Release /p:Platform=x64 /p:UapAppxPackageBuildMode=SideloadOnly /p:GenerateAppxPackageOnBuild=true

if ($LASTEXITCODE -ne 0) {
    Write-Error "Build failed!"
    exit 1
}

Write-Host "✅ Build successful!" -ForegroundColor Green
Write-Host ""

# Step 2: Find the output package
Write-Host "[2/3] Locating package..." -ForegroundColor Yellow
$packagePath = Get-ChildItem -Path "..\AppPackages" -Filter "*.msix" -Recurse | Select-Object -First 1

if ($packagePath) {
    Write-Host "✅ Package found: $($packagePath.FullName)" -ForegroundColor Green
    Write-Host ""
    
    # Step 3: Copy to Deployment folder
    Write-Host "[3/3] Copying to Deployment folder..." -ForegroundColor Yellow
    $destPath = ".\DemoDeploy_1.0.1.0_x64.msix"
    Copy-Item $packagePath.FullName -Destination $destPath -Force
    Write-Host "✅ Package copied to: $destPath" -ForegroundColor Green
    Write-Host ""
    
    # Show package info
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "Package Information:" -ForegroundColor Cyan
    Write-Host "  Location: $destPath" -ForegroundColor White
    Write-Host "  Size: $([math]::Round($packagePath.Length / 1MB, 2)) MB" -ForegroundColor White
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    
    Write-Host "Next steps:" -ForegroundColor Yellow
    Write-Host "1. Sign package: signtool sign /fd SHA256 /f DemoDeploy_TemporaryKey.pfx $destPath" -ForegroundColor White
    Write-Host "2. Test install: Add-AppxPackage -Path $destPath" -ForegroundColor White
    Write-Host "3. Upload to GitHub Pages for web deployment" -ForegroundColor White
    
} else {
    Write-Error "Package not found! Check build output."
    exit 1
}

Write-Host ""
Write-Host "✅ Build completed successfully!" -ForegroundColor Green
