# PowerShell Script to Update Package Version
# Usage: .\Update-Version.ps1 -NewVersion "1.0.1.0"

param(
    [Parameter(Mandatory=$true)]
    [string]$NewVersion
)

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Update Package Version" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$manifestPath = "..\Package.appxmanifest"

if (-not (Test-Path $manifestPath)) {
    Write-Error "Package.appxmanifest not found!"
    exit 1
}

Write-Host "Current manifest:" -ForegroundColor Yellow
$currentVersion = Select-String -Path $manifestPath -Pattern 'Version="([0-9.]+)"' | 
                  ForEach-Object { $_.Matches.Groups[1].Value }
Write-Host "  Version: $currentVersion" -ForegroundColor White

Write-Host ""
Write-Host "Updating to version: $NewVersion" -ForegroundColor Green

# Backup original
Copy-Item $manifestPath "$manifestPath.backup"
Write-Host "  Backup created: Package.appxmanifest.backup" -ForegroundColor Gray

# Update version
$content = Get-Content $manifestPath -Raw
$content = $content -replace 'Version="[0-9.]+"', "Version=`"$NewVersion`""
Set-Content $manifestPath -Value $content -NoNewline

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Version updated successfully!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. Rebuild the project" -ForegroundColor White
Write-Host "2. Test the app" -ForegroundColor White
Write-Host "3. Build MSIX package" -ForegroundColor White
Write-Host ""
Write-Host "To revert: Move-Item -Force Package.appxmanifest.backup Package.appxmanifest" -ForegroundColor Gray
