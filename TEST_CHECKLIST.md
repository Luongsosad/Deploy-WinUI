# ?? TEST CHECKLIST - DemoDeploy

## ? B??C 1: Certificate Setup (HOÀN T?T ?)

- [x] Run `Deployment\Create-Certificate.ps1`
- [x] Certificate created: `DemoDeploy_TemporaryKey.pfx`
- [x] Thumbprint: `ABCE7494660323086FA04E0B256258782BA42708`
- [ ] **TODO**: Import certificate vào Trusted Root
  - Open `certmgr.msc`
  - Import `Deployment\DemoDeploy_TemporaryKey.pfx`
  - Store location: `Trusted Root Certification Authorities`

---

## ? B??C 2: Build & Run Tests

### 2.1 Debug Build Test
```powershell
dotnet build -c Debug /p:Platform=x64
```
- [x] Build successful
- [x] Output: `bin\x64\Debug\net8.0-windows10.0.19041.0\win-x64\DemoDeploy.dll`

### 2.2 Run Application
```powershell
Start-Process "bin\x64\Debug\net8.0-windows10.0.19041.0\win-x64\DemoDeploy.exe"
```
**Test Cases:**
- [ ] App launches successfully
- [ ] Window title: "DemoDeploy - Deployment Demo"
- [ ] Mica backdrop visible
- [ ] Version displays: "Version: 1.0.1.0"

### 2.3 UI Tests
**Deployment Features Section:**
- [ ] All checkboxes checked (6 features)
- [ ] Features listed:
  - MSIX Packaging
  - Versioning System
  - Auto-Update Checker
  - Store Deployment Ready
  - AppInstaller Support
  - Sideloading Support

**Version Information Section:**
- [ ] Current Version: 1.0.1.0
- [ ] Package ID displays
- [ ] Publisher: LUONG

**Actions Section:**
- [ ] "Check for Updates" button exists
- [ ] "View Deployment Info" button exists
- [ ] Documentation link clickable

**Technologies Used Section:**
- [ ] Shows 6 technologies:
  - MSIX Packaging Format
  - Windows App SDK 1.8
  - AppInstaller Protocol
  - Windows.Services.Store API
  - .NET 8.0
  - WinUI 3 Framework

### 2.4 Functionality Tests

**Test: Check for Updates**
1. Click "Check for Updates" button
2. Progress bar shows (briefly)
3. Dialog appears with:
   - [ ] Title: "?? Update Available!"
   - [ ] Current Version: 1.0.1.0
   - [ ] Latest Version: 1.0.2.0 (mock data)
   - [ ] Release notes displayed
   - [ ] Two buttons: "Download Update" and "Later"
4. Click "Download Update"
   - [ ] Opens browser to GitHub releases

**Test: View Deployment Info**
1. Click "View Deployment Info" button
2. Dialog shows:
   - [ ] Version info
   - [ ] Package ID
   - [ ] Publisher
   - [ ] Feature list
   - [ ] Technology stack
   - [ ] Build date

**Test: Keyboard Shortcut**
- [ ] Press `Ctrl+U` ? Should trigger "Check for Updates"

---

## ? B??C 3: Build Release Package

### 3.1 Build MSIX Package
```powershell
cd Deployment
.\Build-MSIX.ps1 -Configuration Release -Platform x64
```

**Expected Output:**
- [ ] Build succeeds
- [ ] MSIX package created in `bin\Packages\`
- [ ] Files created:
  - `DemoDeploy_x.x.x.x_x64.msix`
  - `DemoDeploy_x.x.x.x_x64.msixbundle`
  - `DemoDeploy_x.x.x.x_x64.msixupload`

### 3.2 Sign MSIX Package
```powershell
$cert = "Deployment\DemoDeploy_TemporaryKey.pfx"
$password = "YOUR_PASSWORD"
signtool sign /fd SHA256 /f $cert /p $password "bin\Packages\DemoDeploy_1.0.1.0_x64.msix"
```

**Verify Signature:**
```powershell
signtool verify /pa "bin\Packages\DemoDeploy_1.0.1.0_x64.msix"
```
- [ ] Signature verification successful

---

## ? B??C 4: Installation Tests

### 4.1 Install MSIX Package

**Method 1: Double-click**
- [ ] Double-click `.msix` file
- [ ] Installation dialog appears
- [ ] Shows: "DemoDeploy - Deployment Demo"
- [ ] Publisher: LUONG
- [ ] Click "Install"
- [ ] Installation completes (5-10 seconds)

**Method 2: PowerShell**
```powershell
Add-AppxPackage -Path "bin\Packages\DemoDeploy_1.0.1.0_x64.msix"
```
- [ ] Installation successful (no errors)

### 4.2 Verify Installation
```powershell
Get-AppxPackage *DemoDeploy*
```
**Check:**
- [ ] Package listed
- [ ] Version: 1.0.1.0
- [ ] Publisher: CN=LUONG
- [ ] InstallLocation exists

### 4.3 Launch Installed App
**From Start Menu:**
- [ ] Search "DemoDeploy"
- [ ] App icon appears
- [ ] Click to launch
- [ ] App opens successfully

**From PowerShell:**
```powershell
explorer.exe shell:AppsFolder\{PackageFamilyName}!App
```
- [ ] App launches

### 4.4 Test Installed App
- [ ] All features work same as debug build
- [ ] Version displays correctly
- [ ] Update checker works
- [ ] No crashes or errors

---

## ? B??C 5: Uninstall Tests

### 5.1 Uninstall via Settings
1. Open Settings ? Apps ? Installed apps
2. Search "DemoDeploy"
3. Click "..." ? Uninstall
4. Confirm uninstall
**Verify:**
- [ ] App removed from Start Menu
- [ ] App folder removed from `Program Files\WindowsApps`
- [ ] No leftover registry entries

### 5.2 Uninstall via PowerShell
```powershell
Get-AppxPackage *DemoDeploy* | Remove-AppxPackage
```
- [ ] Removal successful

### 5.3 Verify Clean Uninstall
```powershell
Get-AppxPackage *DemoDeploy*
# Should return nothing
```
- [ ] No packages found
- [ ] Clean removal confirmed

---

## ? B??C 6: Reinstall Test

### 6.1 Reinstall After Uninstall
```powershell
Add-AppxPackage -Path "bin\Packages\DemoDeploy_1.0.1.0_x64.msix"
```
- [ ] Reinstallation successful
- [ ] App works correctly
- [ ] Settings preserved (if any)

---

## ? B??C 7: Update Test (Simulation)

### 7.1 Create New Version
1. Update `Package.appxmanifest` ? Version: `1.0.2.0`
2. Rebuild package
3. Sign new package

### 7.2 Upgrade Install
```powershell
Add-AppxPackage -Path "bin\Packages\DemoDeploy_1.0.2.0_x64.msix"
```
**Verify:**
- [ ] Upgrade successful
- [ ] New version: 1.0.2.0
- [ ] Old files replaced
- [ ] Settings preserved

---

## ? B??C 8: Certificate Trust Tests

### 8.1 Without Certificate Import
1. Remove certificate from Trusted Root
2. Try to install MSIX
**Expected:**
- [ ] Installation fails with certificate error
- [ ] Error message: "This app package's publisher certificate could not be verified"

### 8.2 With Certificate Import
1. Import certificate to Trusted Root
2. Try to install MSIX
**Expected:**
- [ ] Installation succeeds
- [ ] No certificate warnings

---

## ? B??C 9: Multi-Architecture Build Test

### 9.1 Build for x86
```powershell
.\Build-MSIX.ps1 -Configuration Release -Platform x86
```
- [ ] Build successful
- [ ] x86 MSIX created

### 9.2 Build for ARM64
```powershell
.\Build-MSIX.ps1 -Configuration Release -Platform ARM64
```
- [ ] Build successful
- [ ] ARM64 MSIX created

### 9.3 Bundle Test
- [ ] MSIX Bundle includes all architectures
- [ ] Bundle installs correct architecture automatically

---

## ? B??C 10: AppInstaller Test (Optional)

### 10.1 Host AppInstaller File
1. Upload `.appinstaller` to web server (HTTPS)
2. Upload MSIX package to web server
3. Update URLs in `.appinstaller` file

### 10.2 Install from Web
```
ms-appinstaller:?source=https://yourdomain.com/DemoDeploy.appinstaller
```
**Verify:**
- [ ] Web installation works
- [ ] Update check works (24h interval)
- [ ] Auto-update downloads new version

---

## ?? TEST SUMMARY

### Critical Tests (Must Pass)
- [ ] Certificate creation
- [ ] Debug build & run
- [ ] Release build
- [ ] Package signing
- [ ] Installation
- [ ] Uninstallation

### Important Tests (Should Pass)
- [ ] All UI elements visible
- [ ] Update checker dialog
- [ ] Deployment info dialog
- [ ] Keyboard shortcuts
- [ ] Reinstall after uninstall
- [ ] Upgrade installation

### Optional Tests (Nice to Have)
- [ ] Multi-architecture builds
- [ ] AppInstaller web deployment
- [ ] Certificate trust verification
- [ ] Store submission (if time permits)

---

## ?? COMMON ISSUES & SOLUTIONS

### Issue 1: Certificate not trusted
**Symptom**: Installation fails with certificate error  
**Solution**: Import `.pfx` to `Cert:\CurrentUser\Root`

### Issue 2: App won't launch
**Symptom**: App crashes immediately  
**Solution**: Check Windows Event Viewer for errors, verify dependencies

### Issue 3: Update check fails
**Symptom**: Update dialog doesn't show  
**Solution**: Check network connection, verify `update.json` URL

### Issue 4: Build fails
**Symptom**: MSBuild errors  
**Solution**: Clean solution, restore NuGet packages, rebuild

---

## ?? TEST RESULTS LOG

### Test Date: ___________
### Tester: ___________

| Test ID | Test Name | Status | Notes |
|---------|-----------|--------|-------|
| 1.1 | Certificate Creation | ? PASS | Thumbprint: ABCE... |
| 2.1 | Debug Build | ? PASS | |
| 2.2 | App Launch | ? PENDING | |
| 2.3 | UI Tests | ? PENDING | |
| 2.4 | Functionality | ? PENDING | |
| 3.1 | Build MSIX | ? PENDING | |
| 3.2 | Sign Package | ? PENDING | |
| 4.1 | Install MSIX | ? PENDING | |
| 4.2 | Verify Install | ? PENDING | |
| 5.1 | Uninstall | ? PENDING | |
| 6.1 | Reinstall | ? PENDING | |

---

## ?? NEXT STEPS

After all tests pass:
1. [ ] Create demo screenshots
2. [ ] Record demo video (15 minutes)
3. [ ] Prepare PowerPoint slides
4. [ ] Upload to YouTube
5. [ ] Submit to Moodle

---

**Status**: ?? IN PROGRESS  
**Critical Tests**: 2/6 completed  
**Total Progress**: 20%
