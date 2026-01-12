# WinUI 3 Deployment Demo

D? án demo v? **Deployment cho ?ng d?ng WinUI 3** - bao g?m versioning, auto-update, MSIX packaging, và Microsoft Store deployment.

## ?? Tính n?ng

### ? MSIX Packaging
- Modern Windows app packaging format
- Automatic installation và uninstallation
- Clean removal không ?? l?i registry/files
- Isolated app container

### ? Versioning System
- Automatic version management
- Assembly versioning
- Package versioning (Major.Minor.Build.Revision)
- Version display trong UI

### ? Auto-Update System
- Check for updates t? remote server
- Update notification dialog
- Release notes display
- Tích h?p Windows.Services.Store API
- Support AppInstaller protocol

### ? Microsoft Store Ready
- Store-compliant packaging
- Store submission ready
- Store listing metadata
- Store analytics support

### ? Sideloading Support
- Enterprise deployment
- AppInstaller web deployment
- Certificate-based signing
- Group Policy deployment

## ??? Công ngh? s? d?ng

| Công ngh? | Phiên b?n | M?c ?ích |
|-----------|-----------|----------|
| .NET | 8.0 | Runtime framework |
| WinUI 3 | Windows App SDK 1.8 | UI framework |
| MSIX | Latest | Packaging format |
| AppInstaller | 2021 schema | Auto-update protocol |
| Windows.Services.Store | Latest | Store integration |

## ?? C?u trúc d? án

```
DemoDeploy/
??? Models/
?   ??? VersionInfo.cs          # Model cho version data
??? Services/
?   ??? VersionHelper.cs        # Helper l?y version info
?   ??? UpdateChecker.cs        # Service check update
??? Deployment/
?   ??? DemoDeploy.appinstaller # AppInstaller config
?   ??? update.json             # Update manifest
?   ??? Build-MSIX.ps1          # Build script
?   ??? Create-Certificate.ps1  # Certificate script
??? Assets/                     # App icons/logos
??? Package.appxmanifest        # MSIX manifest
??? MainWindow.xaml             # Main UI
```

## ?? Cách s? d?ng

### 1?? Build Project

#### S? d?ng Visual Studio:
1. M? solution trong Visual Studio 2022
2. Ch?n Configuration: **Release**
3. Ch?n Platform: **x64**
4. Build > Publish > Create App Packages

#### S? d?ng PowerShell Script:
```powershell
cd Deployment
.\Build-MSIX.ps1 -Configuration Release -Platform x64
```

### 2?? T?o Certificate (cho testing)

```powershell
cd Deployment
.\Create-Certificate.ps1
```

Sau ?ó import certificate vào **Trusted Root Certification Authorities**:
```powershell
certmgr.msc
```

### 3?? Sign MSIX Package

```powershell
signtool sign /fd SHA256 /f DemoDeploy_TemporaryKey.pfx /p YOUR_PASSWORD DemoDeploy.msix
```

### 4?? Test Installation

Double-click file `.msix` ho?c:
```powershell
Add-AppxPackage -Path ".\DemoDeploy.msix"
```

## ?? Deployment Options

### Option 1: Microsoft Store
1. T?o tài kho?n Partner Center
2. Reserve app name
3. Upload MSIX package
4. Fill store listing (screenshots, description)
5. Submit for certification

**Chi phí**: $19 one-time registration fee

**L?i ích**:
- Automatic updates
- Global distribution
- Trust badge
- Analytics

### Option 2: Sideloading (Enterprise)
1. Build MSIX package
2. Sign v?i enterprise certificate
3. Deploy qua Group Policy/SCCM/Intune

**Yêu c?u**:
- Enterprise certificate
- Device management system

### Option 3: Web Deployment (AppInstaller)
1. Build MSIX package
2. T?o `.appinstaller` file
3. Host trên web server (HTTPS required)
4. Users install from URL

**Ví d? URL**:
```
ms-appinstaller:?source=https://yourdomain.com/demodeploy/DemoDeploy.appinstaller
```

## ?? Auto-Update Setup

### 1. T?o update manifest (`update.json`)
```json
{
  "version": "1.0.2.0",
  "releaseNotes": "New features...",
  "downloadUrl": "https://...",
  "releaseDate": "2025-01-10T00:00:00Z"
}
```

### 2. Host trên server
- GitHub Releases (mi?n phí)
- Azure Blob Storage
- Custom web server

### 3. Configure AppInstaller
```xml
<UpdateSettings>
    <OnLaunch HoursBetweenUpdateChecks="24" ShowPrompt="true" />
    <AutomaticBackgroundTask />
</UpdateSettings>
```

## ?? Versioning Strategy

### Semantic Versioning: `Major.Minor.Build.Revision`

- **Major**: Breaking changes
- **Minor**: New features (backward compatible)
- **Build**: Bug fixes
- **Revision**: Hotfixes

### Cách bump version:
1. Ch?nh s?a `Package.appxmanifest`:
   ```xml
   <Identity Version="1.0.2.0" />
   ```
2. Build l?i project
3. Upload update

## ?? Testing Checklist

- [ ] App cài ??t thành công
- [ ] Version hi?n th? ?úng
- [ ] Check update ho?t ??ng
- [ ] Update dialog hi?n th?
- [ ] App uninstall s?ch s?
- [ ] Certificate trust
- [ ] Icon/logo hi?n th? ?úng
- [ ] Start menu entry
- [ ] App lifecycle (suspend/resume)

## ?? Store Submission Checklist

- [ ] App name reserved
- [ ] Age rating completed
- [ ] Privacy policy URL
- [ ] Screenshots (1366x768 minimum)
- [ ] Description (Vietnamese + English)
- [ ] Keywords/Categories
- [ ] MSIX package uploaded
- [ ] Pricing tier selected
- [ ] Market availability
- [ ] Certification notes

## ?? Troubleshooting

### L?i: "Can't install package"
- Ki?m tra certificate ?ã import vào Trusted Root
- Verify publisher name trong manifest kh?p v?i certificate

### L?i: "Deployment failed"
- Check package dependencies (VCLibs, Windows App Runtime)
- Verify target Windows version

### Update không ho?t ??ng
- Ki?m tra URL trong `.appinstaller` file
- Verify HTTPS certificate valid
- Check version number increment

## ?? Tài li?u tham kh?o

- [MSIX Packaging Documentation](https://docs.microsoft.com/windows/msix/)
- [Windows App SDK](https://docs.microsoft.com/windows/apps/windows-app-sdk/)
- [Microsoft Store Submission](https://docs.microsoft.com/windows/apps/publish/)
- [AppInstaller File Reference](https://docs.microsoft.com/uwp/schemas/appinstallerschema/schema-root)

## ?? Seminar Presentation Tips

### Slide Structure (15 phút)
1. **Introduction** (2 phút)
   - Gi?i thi?u deployment challenges
   - T?i sao c?n modern deployment

2. **MSIX Overview** (3 phút)
   - So sánh MSIX vs MSI
   - Benefits c?a MSIX

3. **Demo Implementation** (5 phút)
   - Live demo: Install
   - Show versioning
   - Check update feature
   - Uninstall

4. **Deployment Options** (3 phút)
   - Store deployment
   - Sideloading
   - Web deployment

5. **Q&A** (2 phút)

### Demo Script
```
1. Show app installation (double-click MSIX)
2. Launch app, show version
3. Click "Check for Updates"
4. Show update dialog
5. Demonstrate uninstall (Settings > Apps)
6. Show clean removal
```

## ?? Credits

**Sinh viên th?c hi?n**: [Tên c?a b?n]  
**Môn h?c**: Windows Programming  
**Gi?ng viên h??ng d?n**: [Tên GV]  
**H?c k?**: 1/2025

## ?? License

MIT License - For educational purposes
