# WinUI 3 Deployment Demo

Dự án demo về **Deployment cho ứng dụng WinUI 3** - bao gồm versioning, auto-update, MSIX packaging, và Microsoft Store deployment.

## 📦 Tính năng

### ✅ MSIX Packaging
- Modern Windows app packaging format
- Automatic installation và uninstallation
- Clean removal không để lại registry/files
- Isolated app container

### ✅ Versioning System
- Automatic version management
- Assembly versioning
- Package versioning (Major.Minor.Build.Revision)
- Version display trong UI

### ✅ Auto-Update System
- Check for updates từ remote server
- Update notification dialog
- Release notes display
- Tích hợp Windows.Services.Store API
- Support AppInstaller protocol

### ✅ Microsoft Store Ready
- Store-compliant packaging
- Store submission ready
- Store listing metadata
- Store analytics support

### ✅ Sideloading Support
- Enterprise deployment
- AppInstaller web deployment
- Certificate-based signing
- Group Policy deployment

## 🛠️ Công nghệ sử dụng

| Công nghệ | Phiên bản | Mục đích |
|-----------|-----------|----------|
| .NET | 8.0 | Runtime framework |
| WinUI 3 | Windows App SDK 1.8 | UI framework |
| MSIX | Latest | Packaging format |
| AppInstaller | 2021 schema | Auto-update protocol |
| Windows.Services.Store | Latest | Store integration |

## 📁 Cấu trúc dự án

```
DemoDeploy/
├── Models/
│   └── VersionInfo.cs          # Model cho version data
├── Services/
│   ├── VersionHelper.cs        # Helper lấy version info
│   └── UpdateChecker.cs        # Service check update
├── Deployment/
│   ├── DemoDeploy.appinstaller # AppInstaller config
│   ├── update.json             # Update manifest
│   ├── Build-MSIX.ps1          # Build script
│   └── Create-Certificate.ps1  # Certificate script
├── Assets/                     # App icons/logos
├── Package.appxmanifest        # MSIX manifest
└── MainWindow.xaml             # Main UI
```

## 🚀 Cách sử dụng

### 1️⃣ Build Project

#### Sử dụng Visual Studio:
1. Mở solution trong Visual Studio 2022
2. Chọn Configuration: **Release**
3. Chọn Platform: **x64**
4. Build > Publish > Create App Packages

#### Sử dụng PowerShell Script:
```powershell
cd Deployment
.\Build-MSIX.ps1 -Configuration Release -Platform x64
```

### 2️⃣ Tạo Certificate (cho testing)

```powershell
cd Deployment
.\Create-Certificate.ps1
```

Sau đó import certificate vào **Trusted Root Certification Authorities**:
```powershell
certmgr.msc
```

### 3️⃣ Sign MSIX Package

```powershell
signtool sign /fd SHA256 /f DemoDeploy_TemporaryKey.pfx /p YOUR_PASSWORD DemoDeploy.msix
```

### 4️⃣ Test Installation

Double-click file `.msix` hoặc:
```powershell
Add-AppxPackage -Path ".\DemoDeploy.msix"
```

## 🌐 Deployment Options

### Option 1: Microsoft Store
1. Tạo tài khoản Partner Center
2. Reserve app name
3. Upload MSIX package
4. Fill store listing (screenshots, description)
5. Submit for certification

**Chi phí**: $19 one-time registration fee

**Lợi ích**:
- Automatic updates
- Global distribution
- Trust badge
- Analytics

### Option 2: Sideloading (Enterprise)
1. Build MSIX package
2. Sign với enterprise certificate
3. Deploy qua Group Policy/SCCM/Intune

**Yêu cầu**:
- Enterprise certificate
- Device management system

### Option 3: Web Deployment (AppInstaller)
1. Build MSIX package
2. Tạo `.appinstaller` file
3. Host trên web server (HTTPS required)
4. Users install from URL

**Ví dụ URL**:
```
ms-appinstaller:?source=https://yourdomain.com/demodeploy/DemoDeploy.appinstaller
```

## 🔄 Auto-Update Setup

### 1. Tạo update manifest (`update.json`)
```json
{
  "version": "1.0.2.0",
  "releaseNotes": "New features...",
  "downloadUrl": "https://...",
  "releaseDate": "2025-01-10T00:00:00Z"
}
```

### 2. Host trên server
- GitHub Releases (miễn phí)
- Azure Blob Storage
- Custom web server

### 3. Configure AppInstaller
```xml
<UpdateSettings>
    <OnLaunch HoursBetweenUpdateChecks="24" ShowPrompt="true" />
    <AutomaticBackgroundTask />
</UpdateSettings>
```

## 🔢 Versioning Strategy

### Semantic Versioning: `Major.Minor.Build.Revision`

- **Major**: Breaking changes
- **Minor**: New features (backward compatible)
- **Build**: Bug fixes
- **Revision**: Hotfixes

### Cách bump version:
1. Chỉnh sửa `Package.appxmanifest`:
   ```xml
   <Identity Version="1.0.2.0" />
   ```
2. Build lại project
3. Upload update

## ✅ Testing Checklist

- [ ] App cài đặt thành công
- [ ] Version hiển thị đúng
- [ ] Check update hoạt động
- [ ] Update dialog hiển thị
- [ ] App uninstall sạch sẽ
- [ ] Certificate trust
- [ ] Icon/logo hiển thị đúng
- [ ] Start menu entry
- [ ] App lifecycle (suspend/resume)

## 🏪 Store Submission Checklist

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

## 🔧 Troubleshooting

### Lỗi: "Can't install package"
- Kiểm tra certificate đã import vào Trusted Root
- Verify publisher name trong manifest khớp với certificate

### Lỗi: "Deployment failed"
- Check package dependencies (VCLibs, Windows App Runtime)
- Verify target Windows version

### Update không hoạt động
- Kiểm tra URL trong `.appinstaller` file
- Verify HTTPS certificate valid
- Check version number increment

## 📚 Tài liệu tham khảo

- [MSIX Packaging Documentation](https://docs.microsoft.com/windows/msix/)
- [Windows App SDK](https://docs.microsoft.com/windows/apps/windows-app-sdk/)
- [Microsoft Store Submission](https://docs.microsoft.com/windows/apps/publish/)
- [AppInstaller File Reference](https://docs.microsoft.com/uwp/schemas/appinstallerschema/schema-root)

## 🎤 Seminar Presentation Tips

### Slide Structure (15 phút)
1. **Introduction** (2 phút)
   - Giới thiệu deployment challenges
   - Tại sao cần modern deployment

2. **MSIX Overview** (3 phút)
   - So sánh MSIX vs MSI
   - Benefits của MSIX

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

## 👥 Credits

**Sinh viên thực hiện**: [Tên của bạn]  
**Môn học**: Windows Programming  
**Giảng viên hướng dẫn**: [Tên GV]  
**Học kỳ**: 1/2025

## 📄 License

MIT License - For educational purposes
