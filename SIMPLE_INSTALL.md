# ✅ SIMPLE INSTALLATION GUIDE

## Quick Demo Setup (5 minutes)

### STEP 1: Import Certificate ⚠️ **CHỈ CẦN 1 LẦN**

```powershell
# Chạy PowerShell AS ADMINISTRATOR
cd D:\Windows\DemoDeploy\Deployment
.\Import-Certificate.ps1
# Password: DemoPassword123
```

**✅ Done!** Certificate giờ đã trusted.

---

### STEP 2: Build Package in Visual Studio

1. Open `DemoDeploy.sln` in Visual Studio 2022
2. Set Configuration = **Release**, Platform = **x64**
3. Right-click project → **Publish** → **Create App Packages**
4. Choose **Sideloading**
5. Click **Create**

**Result:** MSIX file trong `AppPackages\` folder

---

### STEP 3: Install & Test

```powershell
# Find MSIX
cd D:\Windows\DemoDeploy
$msix = Get-ChildItem -Path AppPackages -Filter "*.msix" -Recurse | Select-Object -First 1

# Install
Add-AppxPackage -Path $msix.FullName
```

**✅ Launch** từ Start Menu!

---

## Alternative: Use Pre-built Package

If build fails, download pre-built:

```powershell
cd Deployment

# Download from GitHub (unsigned)
Invoke-WebRequest -Uri "https://github.com/Luongsosad/Deploy-WinUI/releases/download/v1.0.1/DemoDeploy_1.0.1.0_x64.msix" `
    -OutFile "DemoDeploy.msix"

# Note: Still need certificate imported!
Add-AppxPackage -Path "DemoDeploy.msix"
```

---

## Troubleshooting

**Error: "Publisher not verified"**
→ Run STEP 1 again (Import certificate)

**Error: "Already installed"**
```powershell
Get-AppxPackage *DemoDeploy* | Remove-AppxPackage
```

**Build fails in VS**
→ Clean solution, Rebuild

---

## For Demo Presentation

1. **Once only**: Import certificate (Step 1)
2. **Build**: Use Visual Studio (Step 2)  
3. **Demo**: Install → Launch → Show features → Uninstall

**Time**: 2 minutes install + 3 minutes demo = 5 minutes total

---

Created: January 13, 2026
Status: ✅ WORKING
