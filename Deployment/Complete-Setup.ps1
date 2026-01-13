# Complete Build and Install Script
# Builds MSIX package and installs with proper certificate

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "   DemoDeploy - Complete Setup" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$ErrorActionPreference = "Stop"

# Step 1: Check/Install certificate
Write-Host "[1/4] Checking certificate..." -ForegroundColor Yellow
$cert = Get-ChildItem Cert:\CurrentUser\My | Where-Object { $_.Subject -eq "CN=LUONG" } | Select-Object -First 1

if (-not $cert) {
    Write-Host "Certificate not found. Creating..." -ForegroundColor Yellow
    & ".\Create-Certificate.ps1"
    $cert = Get-ChildItem Cert:\CurrentUser\My | Where-Object { $_.Subject -eq "CN=LUONG" } | Select-Object -First 1
}

Write-Host "✅ Certificate ready: $($cert.Thumbprint)" -ForegroundColor Green
Write-Host ""

# Step 2: Build package using Visual Studio
Write-Host "[2/4] Building package with Visual Studio..." -ForegroundColor Yellow
$vsWhere = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe"
$msbuild = &$vsWhere -latest -requires Microsoft.Component.MSBuild -find MSBuild\**\Bin\MSBuild.exe | Select-Object -First 1

if (-not $msbuild) {
    Write-Error "MSBuild not found. Please install Visual Studio 2022."
    exit 1
}

Write-Host "Using MSBuild: $msbuild" -ForegroundColor Gray

& $msbuild "..\DemoDeploy.csproj" `
    /t:Build `
    /p:Configuration=Release `
    /p:Platform=x64 `
    /p:AppxBundle=Never `
    /p:UapAppxPackageBuildMode=SideloadOnly `
    /p:GenerateAppxPackageOnBuild=true `
    /p:AppxPackageSigningEnabled=false `
    /verbosity:minimal

if ($LASTEXITCODE -ne 0) {
    Write-Error "Build failed!"
    exit 1
}

Write-Host "✅ Build successful!" -ForegroundColor Green
Write-Host ""

# Step 3: Find and copy MSIX
Write-Host "[3/4] Locating MSIX package..." -ForegroundColor Yellow
$msix = Get-ChildItem -Path "..\AppPackages" -Filter "*.msix" -Recurse -ErrorAction SilentlyContinue | 
    Where-Object { $_.Name -notlike "*_dependencies_*" } |
    Select-Object -First 1

if (-not $msix) {
    Write-Error "MSIX package not found after build!"
    exit 1
}

$destMsix = "DemoDeploy_1.0.1.0_x64.msix"
Copy-Item $msix.FullName -Destination $destMsix -Force
Write-Host "✅ Package: $destMsix" -ForegroundColor Green
Write-Host ""

# Step 4: Sign package
Write-Host "[4/4] Signing package..." -ForegroundColor Yellow
$signtool = &$vsWhere -latest -find **/signtool.exe | Select-Object -First 1

if (-not $signtool) {
    Write-Warning "SignTool not found. Package will be unsigned."
} else {
    & $signtool sign /fd SHA256 /sha1 $cert.Thumbprint /t http://timestamp.digicert.com $destMsix
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Package signed successfully!" -ForegroundColor Green
    } else {
        Write-Warning "Signing failed, but continuing..."
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "✅ Setup Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "To install:" -ForegroundColor Yellow
Write-Host "1. Make sure certificate is in Trusted Root (run Import-Certificate.ps1 as Admin)" -ForegroundColor White
Write-Host "2. Run: Add-AppxPackage -Path '$destMsix'" -ForegroundColor Green
Write-Host ""
