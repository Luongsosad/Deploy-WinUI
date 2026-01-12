# PowerShell Script to Build and Package MSIX
# Usage: .\Build-MSIX.ps1 -Configuration Release -Platform x64

param(
    [Parameter(Mandatory=$false)]
    [string]$Configuration = "Release",
    
    [Parameter(Mandatory=$false)]
    [string]$Platform = "x64",
    
    [Parameter(Mandatory=$false)]
    [string]$OutputPath = ".\bin\Packages"
)

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "DemoDeploy MSIX Build Script" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if running in Developer PowerShell for VS
Write-Host "Checking environment..." -ForegroundColor Yellow
$msbuildPath = &"${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe" -latest -requires Microsoft.Component.MSBuild -find MSBuild\**\Bin\MSBuild.exe

if (-not $msbuildPath) {
    Write-Error "MSBuild not found. Please run this script from Developer PowerShell for Visual Studio."
    exit 1
}

Write-Host "MSBuild found at: $msbuildPath" -ForegroundColor Green
Write-Host ""

# Clean previous builds
Write-Host "Cleaning previous builds..." -ForegroundColor Yellow
& $msbuildPath DemoDeploy.csproj /t:Clean /p:Configuration=$Configuration /p:Platform=$Platform
Write-Host "Clean completed." -ForegroundColor Green
Write-Host ""

# Restore packages
Write-Host "Restoring NuGet packages..." -ForegroundColor Yellow
& $msbuildPath DemoDeploy.csproj /t:Restore
Write-Host "Restore completed." -ForegroundColor Green
Write-Host ""

# Build and package
Write-Host "Building and packaging MSIX..." -ForegroundColor Yellow
& $msbuildPath DemoDeploy.csproj `
    /p:Configuration=$Configuration `
    /p:Platform=$Platform `
    /p:UapAppxPackageBuildMode=StoreUpload `
    /p:AppxBundle=Always `
    /p:AppxPackageDir="$OutputPath\" `
    /p:GenerateAppxPackageOnBuild=true

if ($LASTEXITCODE -ne 0) {
    Write-Error "Build failed!"
    exit 1
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Build completed successfully!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Output location: $OutputPath" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. Test the MSIX package" -ForegroundColor White
Write-Host "2. Sign the package with your certificate" -ForegroundColor White
Write-Host "3. Upload to Microsoft Store or host for sideloading" -ForegroundColor White
Write-Host ""
