# 📦 Hướng Dẫn Triển Khai MSIX - DemoDeploy

> Tài liệu hướng dẫn chi tiết về triển khai ứng dụng WinUI 3 với MSIX Package và Auto-Update System

---

## 📋 Mục Lục

1. [Giới Thiệu](#i-giới-thiệu)
2. [MSIX Packaging](#ii-msix-packaging)
3. [Auto-Update System](#iii-auto-update-system)
4. [Deployment Options](#iv-deployment-options)
5. [Certificate & Code Signing](#v-certificate--code-signing)
6. [CI/CD Pipeline](#vi-cicd-pipeline)
7. [Testing & QA](#vii-testing--qa)
8. [Microsoft Store Submission](#viii-microsoft-store-submission)
9. [Troubleshooting](#ix-troubleshooting)
10. [Best Practices](#x-best-practices)

---

## I. GIỚI THIỆU

### 🎯 Tổng Quan Deployment

MSIX là định dạng package hiện đại của Microsoft, được thiết kế để thay thế các công nghệ deployment cũ như MSI, ClickOnce, và App-V. MSIX cung cấp một giải pháp deployment toàn diện với:

- **Cài đặt đáng tin cậy**: Clean install/uninstall không để lại tệp rác
- **Auto-update tích hợp**: Cập nhật tự động qua AppInstaller protocol
- **Sandbox environment**: Ứng dụng chạy trong container cô lập
- **Microsoft Store ready**: Dễ dàng xuất bản lên Store

### ❌ Thách Thức Với Công Nghệ Cũ

#### MSI (Windows Installer)
```
❌ Nhược điểm:
- Phức tạp để tạo và maintain
- Không có auto-update built-in
- Có thể để lại registry/file rác
- Khó rollback khi lỗi
```

#### ClickOnce
```
❌ Nhược điểm:
- Không hỗ trợ WinUI 3/Windows App SDK
- Giới hạn về quyền truy cập hệ thống
- Không được Microsoft khuyến nghị cho ứng dụng mới
- Trải nghiệm người dùng kém
```

### ✅ Lợi Ích Của MSIX

| Tính Năng | MSI | ClickOnce | MSIX |
|-----------|-----|-----------|------|
| Clean Install/Uninstall | ⚠️ | ✅ | ✅ |
| Auto-Update | ❌ | ✅ | ✅ |
| Microsoft Store | ❌ | ❌ | ✅ |
| Sandbox Security | ❌ | ⚠️ | ✅ |
| Modern UI Support | ✅ | ❌ | ✅ |
| Easy CI/CD | ❌ | ⚠️ | ✅ |

---

## II. MSIX PACKAGING

### 📦 Cấu Trúc Package

Một MSIX package bao gồm các thành phần chính:

```
DemoDeploy.msix
├── AppxManifest.xml          # Package manifest
├── DemoDeploy.exe            # Executable chính
├── *.dll                     # Dependencies
├── Assets/                   # Hình ảnh, icons
├── resources.pri             # Resource index
└── AppxSignature.p7x         # Digital signature
```

### 📄 AppxManifest.xml Breakdown

#### 1. Package Identity
```xml
<Identity 
  Name="DemoDeploy"
  Publisher="CN=YourCompany"
  Version="1.0.0.0"
  ProcessorArchitecture="x64" />
```

**Giải thích:**
- `Name`: Tên package duy nhất (không thay đổi sau khi release)
- `Publisher`: Distinguished Name của certificate
- `Version`: Phiên bản theo định dạng Major.Minor.Build.Revision
- `ProcessorArchitecture`: x64, x86, ARM64, hoặc neutral

#### 2. Properties Section
```xml
<Properties>
  <DisplayName>DemoDeploy</DisplayName>
  <PublisherDisplayName>Your Company</PublisherDisplayName>
  <Logo>Assets\StoreLogo.png</Logo>
  <Description>Application triển khai tự động</Description>
</Properties>
```

#### 3. Dependencies
```xml
<Dependencies>
  <TargetDeviceFamily 
    Name="Windows.Universal" 
    MinVersion="10.0.17763.0" 
    MaxVersionTested="10.0.22621.0" />
</Dependencies>
```

#### 4. Capabilities (Quyền)
```xml
<Capabilities>
  <rescap:Capability Name="runFullTrust" />
  <Capability Name="internetClient" />
  <Capability Name="internetClientServer" />
</Capabilities>
```

### 🔢 Versioning Format

MSIX sử dụng định dạng version 4 phần:

```
Major.Minor.Build.Revision
  1  .  0  .  0  .    0

Major:    Breaking changes (API thay đổi)
Minor:    New features (backward compatible)
Build:    Bug fixes, patches
Revision: Hotfixes (thường là 0)
```

**Quy tắc quan trọng:**
```csharp
// ❌ KHÔNG được giảm version
1.0.0.0 → 0.9.0.0  // Lỗi deployment!

// ✅ CHỈ được tăng version
1.0.0.0 → 1.0.1.0  // OK
1.0.1.0 → 1.1.0.0  // OK
1.1.0.0 → 2.0.0.0  // OK
```

---

## III. AUTO-UPDATE SYSTEM

### 🔄 AppInstaller Protocol

AppInstaller là XML manifest mô tả cách Windows tự động cập nhật ứng dụng.

#### Cấu Trúc AppInstaller XML

```xml
<?xml version="1.0" encoding="utf-8"?>
<AppInstaller 
  xmlns="http://schemas.microsoft.com/appx/appinstaller/2021"
  Version="1.0.0.0" 
  Uri="https://yourdomain.com/DemoDeploy.appinstaller">
  
  <!-- Main Package -->
  <MainPackage 
    Name="DemoDeploy"
    Publisher="CN=YourCompany"
    Version="1.0.0.0"
    Uri="https://yourdomain.com/DemoDeploy_1.0.0.0_x64.msix"
    ProcessorArchitecture="x64" />
  
  <!-- Update Settings -->
  <UpdateSettings>
    <OnLaunch 
      HoursBetweenUpdateChecks="12"
      ShowPrompt="false"
      UpdateBlocksActivation="false" />
    <AutomaticBackgroundTask />
    <ForceUpdateFromAnyVersion>true</ForceUpdateFromAnyVersion>
  </UpdateSettings>

</AppInstaller>
```

### 📊 Update Flow Steps

```
1. User khởi động app
   ↓
2. App gọi StoreContext.GetAppAndOptionalStorePackageUpdatesAsync()
   ↓
3. Windows kiểm tra AppInstaller URL
   ↓
4. So sánh Version local vs remote
   ↓
5. Nếu có update mới
   ├─→ Download MSIX package
   ├─→ Verify signature
   ├─→ Install update
   └─→ Restart app (nếu cần)
   ↓
6. App hiển thị thông báo
```

### 💻 Windows.Services.Store API Integration

#### Implementation trong UpdateChecker.cs

```csharp
using Windows.Services.Store;
using Microsoft.UI.Dispatching;

public class UpdateChecker
{
    private readonly StoreContext _storeContext;
    private readonly DispatcherQueue _dispatcherQueue;

    public async Task<bool> CheckForUpdatesAsync()
    {
        try
        {
            // Get Store context
            _storeContext = StoreContext.GetDefault();

            // Check for updates
            IReadOnlyList<StorePackageUpdate> updates = 
                await _storeContext.GetAppAndOptionalStorePackageUpdatesAsync();

            if (updates.Count > 0)
            {
                // Download and install
                StorePackageUpdateResult result = 
                    await _storeContext.RequestDownloadAndInstallStorePackageUpdatesAsync(updates);

                return result.OverallState == StorePackageUpdateState.Completed;
            }

            return false;
        }
        catch (Exception ex)
        {
            Debug.WriteLine($"Update check failed: {ex.Message}");
            return false;
        }
    }
}
```

### 📋 JSON Manifest Structure

File `update.json` được sử dụng để kiểm tra version:

```json
{
  "version": "1.0.0.0",
  "releaseDate": "2026-01-12T10:00:00Z",
  "downloadUrl": "https://yourdomain.com/DemoDeploy_1.0.0.0_x64.msix",
  "changelog": [
    "✨ New feature: Auto-update system",
    "🐛 Bug fix: Memory leak in background service",
    "⚡ Performance: Improved startup time by 30%"
  ],
  "minimumVersion": "0.9.0.0",
  "releaseNotes": "https://yourdomain.com/releases/v1.0.0",
  "isMandatory": false
}
```

**Sử dụng trong code:**

```csharp
public class VersionInfo
{
    public string Version { get; set; }
    public DateTime ReleaseDate { get; set; }
    public string DownloadUrl { get; set; }
    public List<string> Changelog { get; set; }
    public string MinimumVersion { get; set; }
    public bool IsMandatory { get; set; }
}

// Check version từ JSON
var json = await httpClient.GetStringAsync("https://yourdomain.com/update.json");
var versionInfo = JsonSerializer.Deserialize<VersionInfo>(json);
```

---

## IV. DEPLOYMENT OPTIONS

### 🏪 Microsoft Store

#### Quy Trình Xuất Bản

1. **Đăng ký Partner Center**
   - Truy cập: https://partner.microsoft.com/dashboard
   - Tạo tài khoản Developer ($19 một lần cho cá nhân)
   - Xác minh danh tính

2. **Tạo App Submission**
   ```
   Partner Center → Apps and games → New product → MSIX or PWA app
   ```

3. **Điền thông tin**
   - App name reservation
   - Store listing (mô tả, screenshots)
   - Pricing and availability
   - Properties (category, age rating)
   - Upload MSIX package

#### Lợi Ích

| Tính Năng | Mô Tả |
|-----------|-------|
| 💰 Monetization | Bán app hoặc in-app purchases |
| 🔐 Trusted | Microsoft ký certificate tự động |
| 📊 Analytics | Dashboard thống kê downloads, ratings |
| 🌍 Global Reach | Phân phối 100+ quốc gia |
| 🔄 Auto-Update | Built-in, không cần code |

#### Chi Phí

- **Cá nhân**: $19 USD (một lần, trọn đời)
- **Công ty**: $99 USD/năm
- **Revenue share**: Microsoft giữ 15% (hoặc 12% nếu có Microsoft Store Services)

### 🏢 Enterprise Sideloading

Triển khai nội bộ trong doanh nghiệp mà không cần Store.

#### Yêu Cầu

1. Windows 10/11 Pro, Enterprise, hoặc Education
2. Sideloading được enable (mặc định từ Windows 10 1803+)
3. Certificate được trust

#### Enable Sideloading (nếu cần)

```powershell
# Kiểm tra trạng thái
Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" -Name AllowAllTrustedApps

# Enable sideloading
New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" `
  -Name AllowAllTrustedApps -Value 1 -PropertyType DWord -Force
```

#### Deployment qua Group Policy

1. **Tạo GPO mới**
   ```
   Group Policy Management → Create new GPO → "Deploy DemoDeploy"
   ```

2. **Configure Package Deployment**
   ```
   Computer Configuration 
   → Policies 
   → Administrative Templates 
   → Windows Components 
   → App Package Deployment
   → "Allow all trusted apps to install" = Enabled
   ```

3. **Deploy Package**
   - Copy MSIX và certificate đến shared folder
   - Tạo startup script:

   ```powershell
   # deploy.ps1
   $certPath = "\\server\share\DemoDeploy.cer"
   $msixPath = "\\server\share\DemoDeploy.msix"

   # Import certificate
   Import-Certificate -FilePath $certPath -CertStoreLocation Cert:\LocalMachine\TrustedPeople

   # Install MSIX
   Add-AppxPackage -Path $msixPath
   ```

#### SCCM/Intune Deployment

**Microsoft Endpoint Manager (Intune):**

```
Intune Admin Center 
→ Apps 
→ Windows 
→ Add 
→ Line-of-business app
→ Upload MSIX
→ Configure requirements (OS version, architecture)
→ Assign to groups
```

### 🌐 Web Deployment

Triển khai qua AppInstaller URL protocol.

#### Cài Đặt Web Server

**IIS Configuration:**

```xml
<!-- web.config -->
<configuration>
  <system.webServer>
    <staticContent>
      <mimeMap fileExtension=".appinstaller" mimeType="application/appinstaller" />
      <mimeMap fileExtension=".msix" mimeType="application/msix" />
      <mimeMap fileExtension=".appx" mimeType="application/appx" />
    </staticContent>
    <httpProtocol>
      <customHeaders>
        <add name="Access-Control-Allow-Origin" value="*" />
      </customHeaders>
    </httpProtocol>
  </system.webServer>
</configuration>
```

#### HTML Installation Link

```html
<!DOCTYPE html>
<html>
<head>
  <title>Install DemoDeploy</title>
</head>
<body>
  <h1>📦 DemoDeploy Installation</h1>
  <p>Click button below to install or update:</p>
  
  <a href="ms-appinstaller:?source=https://yourdomain.com/DemoDeploy.appinstaller">
    <button>🚀 Install DemoDeploy</button>
  </a>
  
  <h2>System Requirements</h2>
  <ul>
    <li>Windows 10 version 1809 or later</li>
    <li>X64 or ARM64 processor</li>
    <li>100 MB free disk space</li>
  </ul>
</body>
</html>
```

---

## V. CERTIFICATE & CODE SIGNING

### 🔐 Loại Certificate

| Loại | Mục Đích | Độ Tin Cậy | Giá |
|------|----------|------------|-----|
| Self-Signed | Development, Testing | Thấp (phải import thủ công) | Miễn phí |
| Code Signing | Production, Enterprise | Cao | $100-500/năm |
| EV Code Signing | Store, Highest trust | Rất cao | $300-800/năm |

### 🛠️ Tạo Self-Signed Certificate

#### PowerShell Script (Create-Certificate.ps1)

```powershell
# Create-Certificate.ps1
param(
    [string]$CertificateName = "CN=DemoDeploy Test Certificate",
    [string]$Password = "YourSecurePassword123",
    [int]$ValidityYears = 2
)

# Tạo certificate
$cert = New-SelfSignedCertificate `
    -Type Custom `
    -Subject $CertificateName `
    -KeyUsage DigitalSignature `
    -FriendlyName "DemoDeploy Signing Certificate" `
    -CertStoreLocation "Cert:\CurrentUser\My" `
    -TextExtension @("2.5.29.37={text}1.3.6.1.5.5.7.3.3", "2.5.29.19={text}") `
    -NotAfter (Get-Date).AddYears($ValidityYears)

# Export certificate (public key)
$certPath = ".\DemoDeploy.cer"
Export-Certificate -Cert $cert -FilePath $certPath

# Export PFX (private key)
$pfxPath = ".\DemoDeploy.pfx"
$securePassword = ConvertTo-SecureString -String $Password -Force -AsPlainText
Export-PfxCertificate -Cert $cert -FilePath $pfxPath -Password $securePassword

Write-Host "✅ Certificate created successfully!" -ForegroundColor Green
Write-Host "📄 Certificate file: $certPath" -ForegroundColor Cyan
Write-Host "🔑 PFX file: $pfxPath" -ForegroundColor Cyan
Write-Host "Thumbprint: $($cert.Thumbprint)" -ForegroundColor Yellow
```

**Chạy script:**

```powershell
.\Deployment\Create-Certificate.ps1 -CertificateName "CN=YourCompany" -Password "SecurePass123"
```

### 📥 Import Certificate vào Trusted Root

#### Manual Import

```powershell
# Import to Trusted People
Import-Certificate -FilePath ".\DemoDeploy.cer" `
  -CertStoreLocation Cert:\LocalMachine\TrustedPeople

# Import to Trusted Root (nếu cần - cẩn thận!)
Import-Certificate -FilePath ".\DemoDeploy.cer" `
  -CertStoreLocation Cert:\LocalMachine\Root
```

#### GUI Method

1. Double-click file `.cer`
2. Click **Install Certificate**
3. Chọn **Local Machine**
4. Chọn **Place all certificates in the following store**
5. Browse → **Trusted People** hoặc **Trusted Root Certification Authorities**
6. Finish

### ✍️ SignTool Usage

SignTool là công cụ dòng lệnh để ký MSIX package.

#### Cài Đặt SignTool

```powershell
# SignTool đi kèm với Windows SDK
# Download tại: https://developer.microsoft.com/windows/downloads/windows-sdk/

# Thường nằm tại:
# C:\Program Files (x86)\Windows Kits\10\bin\10.0.22621.0\x64\signtool.exe
```

#### Ký MSIX Package

```powershell
# Sử dụng PFX file
signtool.exe sign /fd SHA256 /a /f "DemoDeploy.pfx" /p "YourPassword" "DemoDeploy.msix"

# Sử dụng certificate từ store
signtool.exe sign /fd SHA256 /sha1 "CertThumbprint" "DemoDeploy.msix"

# Với timestamp server (khuyên dùng)
signtool.exe sign /fd SHA256 /a /f "DemoDeploy.pfx" /p "YourPassword" `
  /tr "http://timestamp.digicert.com" /td SHA256 "DemoDeploy.msix"
```

#### Verify Signature

```powershell
# Kiểm tra signature
signtool.exe verify /pa "DemoDeploy.msix"

# Xem chi tiết certificate
signtool.exe verify /pa /v "DemoDeploy.msix"
```

---

## VI. CI/CD PIPELINE

### 🔄 GitHub Actions Workflow

Tạo file `.github/workflows/build-release.yml`:

```yaml
name: Build and Release MSIX

on:
  push:
    tags:
      - 'v*.*.*'
  workflow_dispatch:

env:
  PROJECT_PATH: DemoDeploy.csproj
  CONFIGURATION: Release

jobs:
  build:
    runs-on: windows-latest
    
    strategy:
      matrix:
        platform: [x64, ARM64]

    steps:
    - name: 📥 Checkout Code
      uses: actions/checkout@v4

    - name: 🔧 Setup .NET
      uses: actions/setup-dotnet@v4
      with:
        dotnet-version: '8.0.x'

    - name: 📦 Restore NuGet Packages
      run: dotnet restore ${{ env.PROJECT_PATH }}

    - name: 🔨 Build MSIX Package
      run: |
        dotnet publish ${{ env.PROJECT_PATH }} `
          -c ${{ env.CONFIGURATION }} `
          -r win-${{ matrix.platform }} `
          -p:Platform=${{ matrix.platform }} `
          -p:GenerateAppxPackageOnBuild=true `
          -p:AppxPackageSigningEnabled=false

    - name: 🔍 Find MSIX Package
      id: find-msix
      run: |
        $msixPath = Get-ChildItem -Recurse -Filter "*.msix" | Select-Object -First 1
        echo "msix-path=$($msixPath.FullName)" >> $env:GITHUB_OUTPUT

    - name: 📤 Upload Build Artifact
      uses: actions/upload-artifact@v4
      with:
        name: DemoDeploy-${{ matrix.platform }}
        path: ${{ steps.find-msix.outputs.msix-path }}

  release:
    needs: build
    runs-on: windows-latest
    if: startsWith(github.ref, 'refs/tags/')

    steps:
    - name: 📥 Download Artifacts
      uses: actions/download-artifact@v4

    - name: 🎉 Create GitHub Release
      uses: softprops/action-gh-release@v1
      with:
        files: |
          DemoDeploy-x64/*.msix
          DemoDeploy-ARM64/*.msix
        draft: false
        prerelease: false
      env:
        GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

### 🏷️ Automated Builds on Tags

#### Tạo Tag và Trigger Build

```bash
# Local: Create and push tag
git tag -a v1.0.0 -m "Release version 1.0.0"
git push origin v1.0.0

# GitHub Actions sẽ tự động:
# 1. Build MSIX cho x64 và ARM64
# 2. Upload artifacts
# 3. Create GitHub Release
```

#### Semantic Versioning với Tags

```bash
# Major release (breaking changes)
git tag v2.0.0

# Minor release (new features)
git tag v1.1.0

# Patch release (bug fixes)
git tag v1.0.1

# Pre-release
git tag v1.0.0-beta.1
```

### 📦 Release Artifact Upload

Cấu hình auto-update với GitHub Releases:

```powershell
# Update-AppInstaller.ps1
param(
    [string]$Version = "1.0.0.0",
    [string]$GitHubRepo = "YourUsername/DemoDeploy"
)

$appInstallerContent = @"
<?xml version="1.0" encoding="utf-8"?>
<AppInstaller xmlns="http://schemas.microsoft.com/appx/appinstaller/2021"
              Version="$Version"
              Uri="https://github.com/$GitHubRepo/releases/latest/download/DemoDeploy.appinstaller">
  <MainPackage 
    Name="DemoDeploy"
    Version="$Version"
    Uri="https://github.com/$GitHubRepo/releases/download/v$Version/DemoDeploy_x64.msix"
    ProcessorArchitecture="x64" />
  <UpdateSettings>
    <OnLaunch HoursBetweenUpdateChecks="12" />
  </UpdateSettings>
</AppInstaller>
"@

$appInstallerContent | Out-File -FilePath "DemoDeploy.appinstaller" -Encoding utf8
```

---

## VII. TESTING & QA

### 🧪 Installation Testing

#### Test Cases

| Test ID | Scenario | Expected Result |
|---------|----------|-----------------|
| INS-001 | Fresh install on clean system | App installs successfully |
| INS-002 | Install over existing version | Upgrade without data loss |
| INS-003 | Install với certificate không trust | Error message, installation blocked |
| INS-004 | Install với version cũ hơn | Error hoặc block (không được downgrade) |
| INS-005 | Cancel installation mid-way | Clean rollback, no partial install |

#### Testing Script

```powershell
# Test-Installation.ps1

function Test-FreshInstall {
    Write-Host "🧪 Testing fresh installation..." -ForegroundColor Cyan
    
    # Uninstall nếu đã tồn tại
    Get-AppxPackage -Name "*DemoDeploy*" | Remove-AppxPackage
    
    # Install
    Add-AppxPackage -Path ".\DemoDeploy.msix"
    
    # Verify
    $app = Get-AppxPackage -Name "*DemoDeploy*"
    if ($app) {
        Write-Host "✅ Installation successful" -ForegroundColor Green
        return $true
    } else {
        Write-Host "❌ Installation failed" -ForegroundColor Red
        return $false
    }
}

function Test-Upgrade {
    Write-Host "🧪 Testing upgrade..." -ForegroundColor Cyan
    
    # Install old version first
    Add-AppxPackage -Path ".\DemoDeploy_1.0.0.0.msix"
    
    # Upgrade to new version
    Add-AppxPackage -Path ".\DemoDeploy_1.1.0.0.msix"
    
    # Verify version
    $app = Get-AppxPackage -Name "*DemoDeploy*"
    if ($app.Version -eq "1.1.0.0") {
        Write-Host "✅ Upgrade successful" -ForegroundColor Green
        return $true
    } else {
        Write-Host "❌ Upgrade failed" -ForegroundColor Red
        return $false
    }
}

# Run all tests
Test-FreshInstall
Test-Upgrade
```

### 🔄 Update Testing

#### Manual Update Test

```csharp
// Test trong ứng dụng
public async Task TestUpdateFlow()
{
    var updateChecker = new UpdateChecker();
    
    // 1. Check for updates
    var hasUpdate = await updateChecker.CheckForUpdatesAsync();
    Assert.IsTrue(hasUpdate, "Should detect update");
    
    // 2. Download and install
    var success = await updateChecker.DownloadAndInstallAsync();
    Assert.IsTrue(success, "Update should install successfully");
    
    // 3. Verify new version
    var newVersion = VersionHelper.GetCurrentVersion();
    Assert.IsTrue(newVersion > oldVersion, "Version should increase");
}
```

### 🗑️ Uninstall Testing

```powershell
# Test-Uninstall.ps1

function Test-CleanUninstall {
    # Install app
    Add-AppxPackage -Path ".\DemoDeploy.msix"
    
    # Ghi nhớ các thư mục data
    $appDataPath = "$env:LOCALAPPDATA\Packages\DemoDeploy*"
    
    # Uninstall
    Get-AppxPackage -Name "*DemoDeploy*" | Remove-AppxPackage
    
    # Verify
    $app = Get-AppxPackage -Name "*DemoDeploy*"
    $dataExists = Test-Path $appDataPath
    
    if (-not $app -and -not $dataExists) {
        Write-Host "✅ Clean uninstall successful" -ForegroundColor Green
    } else {
        Write-Host "❌ Uninstall left residual files" -ForegroundColor Red
    }
}
```

### ⚡ Performance Testing

```csharp
// Benchmark startup time
public class PerformanceTests
{
    [Test]
    public void TestStartupTime()
    {
        var stopwatch = Stopwatch.StartNew();
        
        // Launch app
        var process = Process.Start("DemoDeploy.exe");
        
        // Wait for main window
        process.WaitForInputIdle();
        
        stopwatch.Stop();
        
        // Startup should be under 2 seconds
        Assert.IsTrue(stopwatch.ElapsedMilliseconds < 2000, 
            $"Startup took {stopwatch.ElapsedMilliseconds}ms");
    }
}
```

---

## VIII. MICROSOFT STORE SUBMISSION

### 📝 Partner Center Registration

#### Bước 1: Tạo Tài Khoản

1. Truy cập https://partner.microsoft.com/dashboard
2. Sign in với Microsoft account
3. Chọn **Windows & Xbox** → **Overview**
4. Click **Enroll** để đăng ký Developer account

#### Bước 2: Thanh Toán

| Account Type | Phí | Validity |
|--------------|-----|----------|
| Individual | $19 USD | Lifetime |
| Company | $99 USD | Annual |

### 📋 Store Listing Requirements

#### 1. App Name & Description

```markdown
✅ Tốt:
- DemoDeploy - Auto-Update Deployment Tool
- Mô tả rõ ràng, dưới 200 ký tự
- Keywords: deployment, MSIX, auto-update

❌ Tránh:
- Tên chung chung: "My App"
- Spam keywords
- Violate trademark
```

#### 2. Screenshots (Bắt buộc)

```
Yêu cầu:
- Tối thiểu 1 screenshot
- Khuyên dùng 3-4 screenshots
- Định dạng: PNG, JPG
- Resolution: 1366x768 hoặc cao hơn
- Aspect ratio: 16:9 recommended
```

#### 3. Store Logos

```
Cần chuẩn bị:
├── Store Logo (300x300)
├── App Icon (150x150)
├── Wide Logo (300x150)
├── Square Logo (71x71)
└── Splash Screen (1240x600)
```

### 🔍 Certification Process

#### Các Bước Certification

```mermaid
1. Submit Package
   ↓
2. Security Testing (2-24h)
   - Virus scan
   - Malware detection
   ↓
3. Technical Compliance (1-3 days)
   - Package validation
   - Manifest check
   - API usage review
   ↓
4. Content Compliance (1-3 days)
   - Age rating verification
   - Content policy check
   ↓
5. Published (or Rejected with feedback)
```

#### Common Rejection Reasons

| Lý Do | Giải Pháp |
|-------|-----------|
| Missing age rating | Điền đầy đủ questionnaire |
| Privacy policy missing | Thêm URL privacy policy |
| Incorrect capabilities | Chỉ khai báo capability cần thiết |
| Crash on launch | Test kỹ trước khi submit |
| Poor app description | Viết mô tả chi tiết, rõ ràng |

### 📊 Post-Submission Monitoring

#### Analytics Dashboard

```
Metrics được theo dõi:
- Acquisitions (downloads)
- Usage (active users)
- Ratings & Reviews
- Crashes & Errors
- Update adoption rate
```

#### Cập Nhật App

```powershell
# 1. Tăng version trong AppxManifest.xml
<Identity Version="1.1.0.0" ... />

# 2. Build MSIX mới
dotnet publish -c Release

# 3. Submit update qua Partner Center
# → Create submission → Upload new package → Submit for certification
```

---

## IX. TROUBLESHOOTING

### ❌ Common Errors với HRESULT Codes

#### 0x80073CF0 - Package installation failed

```
Nguyên nhân:
- Certificate không được trust
- Package đã bị corrupt
- Thiếu dependencies

Giải pháp:
1. Import certificate vào Trusted People
2. Download lại package
3. Cài Windows App Runtime dependencies
```

```powershell
# Fix script
Import-Certificate -FilePath "DemoDeploy.cer" `
  -CertStoreLocation Cert:\LocalMachine\TrustedPeople

Add-AppxPackage -Path "DemoDeploy.msix"
```

#### 0x80073CFB - Dependency validation failed

```
Nguyên nhân:
- Thiếu Windows App SDK Runtime

Giải pháp:
Download và cài đặt:
https://aka.ms/windowsappsdk/1.4/latest/windowsappruntimeinstall-x64.exe
```

#### 0x80073D02 - Package version lower than installed

```
Nguyên nhân:
- Đang cố cài version cũ hơn

Giải pháp:
1. Uninstall version hiện tại
Get-AppxPackage -Name "*DemoDeploy*" | Remove-AppxPackage

2. Hoặc tăng version number trong package mới
```

### 🔐 Certificate Issues

#### "This app didn't start from a trusted source"

```powershell
# Import certificate với elevated privileges
Start-Process powershell -Verb RunAs -ArgumentList `
  "Import-Certificate -FilePath 'C:\path\DemoDeploy.cer' -CertStoreLocation Cert:\LocalMachine\Root"
```

#### Certificate expired

```powershell
# Check expiry date
$cert = Get-ChildItem -Path Cert:\CurrentUser\My | Where-Object {$_.Subject -like "*DemoDeploy*"}
$cert.NotAfter

# Generate new certificate
.\Deployment\Create-Certificate.ps1 -ValidityYears 3

# Re-sign MSIX
signtool.exe sign /fd SHA256 /f "NewCert.pfx" /p "Password" "DemoDeploy.msix"
```

### 📦 Deployment Failures

#### "App installation failed. Try again."

**Troubleshooting steps:**

```powershell
# 1. Check Windows Event Log
Get-WinEvent -LogName "Microsoft-Windows-AppXDeployment/Operational" -MaxEvents 20

# 2. Clean app cache
Remove-Item "$env:LOCALAPPDATA\Packages\Microsoft.WindowsStore*\LocalCache" -Recurse -Force

# 3. Reset Windows Store
wsreset.exe

# 4. Re-register AppX services
Get-AppXPackage -AllUsers | Foreach {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
```

### 🔄 Update Problems

#### Updates not detected

```csharp
// Debug update checker
public async Task DiagnoseUpdateIssue()
{
    try
    {
        // 1. Check internet connectivity
        var ping = new Ping();
        var result = await ping.SendPingAsync("google.com");
        Debug.WriteLine($"Internet: {result.Status}");
        
        // 2. Check AppInstaller URL accessibility
        using var client = new HttpClient();
        var response = await client.GetAsync("https://yourdomain.com/DemoDeploy.appinstaller");
        Debug.WriteLine($"AppInstaller URL: {response.StatusCode}");
        
        // 3. Verify Store context
        var storeContext = StoreContext.GetDefault();
        var updates = await storeContext.GetAppAndOptionalStorePackageUpdatesAsync();
        Debug.WriteLine($"Updates found: {updates.Count}");
    }
    catch (Exception ex)
    {
        Debug.WriteLine($"Error: {ex.Message}");
    }
}
```

#### Stuck on "Downloading..."

```powershell
# Clear Windows Update cache
Stop-Service wuauserv
Remove-Item C:\Windows\SoftwareDistribution\Download\* -Recurse -Force
Start-Service wuauserv

# Reset Store cache
wsreset.exe
```

---

## X. BEST PRACTICES

### 🏭 Production Recommendations

#### 1. Versioning Strategy

```
✅ Nên:
- Sử dụng semantic versioning (Major.Minor.Patch.Revision)
- Tự động tăng version trong CI/CD
- Tag Git commits với version number
- Maintain changelog cho mỗi release

❌ Tránh:
- Hard-code version trong code
- Skip version numbers
- Giảm version number
```

#### 2. Code Signing

```
✅ Production:
- Sử dụng EV Code Signing Certificate
- Enable timestamping
- Protect private key (HSM, Azure Key Vault)

❌ Development:
- Dùng self-signed cert chỉ cho testing
- Không commit PFX vào Git
- Không share private key
```

#### 3. Update Strategy

```xml
<!-- Conservative (doanh nghiệp) -->
<UpdateSettings>
  <OnLaunch HoursBetweenUpdateChecks="168" ShowPrompt="true" />
  <!-- Check mỗi tuần, có prompt -->
</UpdateSettings>

<!-- Aggressive (consumer apps) -->
<UpdateSettings>
  <OnLaunch HoursBetweenUpdateChecks="12" ShowPrompt="false" />
  <AutomaticBackgroundTask />
  <!-- Check 2 lần/ngày, tự động update -->
</UpdateSettings>
```

### 🔒 Security Considerations

#### 1. Capability Minimization

```xml
<!-- ❌ Tránh yêu cầu quá nhiều quyền -->
<Capabilities>
  <rescap:Capability Name="runFullTrust" />
  <Capability Name="internetClient" />
  <rescap:Capability Name="broadFileSystemAccess" />  <!-- Không cần thiết -->
  <rescap:Capability Name="documentsLibrary" />       <!-- Không cần thiết -->
</Capabilities>

<!-- ✅ Chỉ yêu cầu những gì cần -->
<Capabilities>
  <rescap:Capability Name="runFullTrust" />
  <Capability Name="internetClient" />
</Capabilities>
```

#### 2. HTTPS for Updates

```
✅ Bắt buộc dùng HTTPS:
- AppInstaller URL
- MSIX download URL
- Update JSON endpoint

❌ KHÔNG dùng HTTP:
- Có thể bị man-in-the-middle attack
- Windows có thể block
```

#### 3. Validate Update Source

```csharp
public async Task<bool> ValidateUpdateSourceAsync(string url)
{
    try
    {
        // Check HTTPS
        if (!url.StartsWith("https://", StringComparison.OrdinalIgnoreCase))
        {
            return false;
        }
        
        // Verify SSL certificate
        using var handler = new HttpClientHandler();
        handler.ServerCertificateCustomValidationCallback = 
            (message, cert, chain, errors) =>
            {
                return errors == System.Net.Security.SslPolicyErrors.None;
            };
        
        using var client = new HttpClient(handler);
        var response = await client.GetAsync(url);
        
        return response.IsSuccessStatusCode;
    }
    catch
    {
        return false;
    }
}
```

### ⚡ Performance Optimization

#### 1. Package Size Optimization

```xml
<!-- Loại bỏ debug symbols trong Release -->
<PropertyGroup Condition="'$(Configuration)'=='Release'">
  <DebugType>none</DebugType>
  <DebugSymbols>false</DebugSymbols>
</PropertyGroup>

<!-- Enable trimming -->
<PropertyGroup>
  <PublishTrimmed>true</PublishTrimmed>
  <TrimMode>partial</TrimMode>
</PropertyGroup>
```

#### 2. Startup Performance

```csharp
// Lazy load dependencies
public class App : Application
{
    protected override async void OnLaunched(LaunchActivatedEventArgs args)
    {
        // Load critical components first
        var window = new MainWindow();
        window.Activate();
        
        // Defer non-critical initialization
        await Task.Run(() => InitializeBackgroundServices());
    }
    
    private void InitializeBackgroundServices()
    {
        // Load heavy components in background
        _ = Task.Run(() => UpdateChecker.InitializeAsync());
        _ = Task.Run(() => TelemetryService.InitializeAsync());
    }
}
```

#### 3. Background Update Check

```csharp
// Sử dụng BackgroundTask thay vì timer
public sealed class UpdateBackgroundTask : IBackgroundTask
{
    public async void Run(IBackgroundTaskInstance taskInstance)
    {
        var deferral = taskInstance.GetDeferral();
        
        try
        {
            var updateChecker = new UpdateChecker();
            await updateChecker.CheckForUpdatesAsync();
        }
        finally
        {
            deferral.Complete();
        }
    }
}
```

### 👥 User Experience Tips

#### 1. Update Notifications

```csharp
// Friendly update notification
public void ShowUpdateNotification(string version, List<string> changelog)
{
    var notification = new Notification()
    {
        Title = "🎉 Update Available",
        Message = $"Version {version} is ready to install",
        Details = string.Join("\n", changelog),
        Actions = new[]
        {
            new NotificationAction("Install Now", InstallUpdateAsync),
            new NotificationAction("Later", DismissNotification)
        }
    };
    
    NotificationManager.Show(notification);
}
```

#### 2. Progress Feedback

```xaml
<!-- Update progress UI -->
<StackPanel Visibility="{x:Bind ViewModel.IsUpdating}">
  <ProgressBar IsIndeterminate="True" />
  <TextBlock Text="{x:Bind ViewModel.UpdateStatus}" />
  <TextBlock Text="{x:Bind ViewModel.DownloadProgress}" />
</StackPanel>
```

#### 3. Rollback Strategy

```csharp
// Keep previous version info for rollback
public class RollbackManager
{
    public async Task<bool> RollbackToVersion(string version)
    {
        try
        {
            var rollbackUrl = $"https://yourdomain.com/versions/DemoDeploy_{version}.msix";
            
            // Download and install previous version
            var downloader = new BackgroundDownloader();
            var download = downloader.CreateDownload(
                new Uri(rollbackUrl), 
                await GetTempFileAsync());
            
            await download.StartAsync();
            
            // Install
            await PackageManager.AddPackageAsync(
                new Uri(download.ResultFile.Path), 
                null, 
                DeploymentOptions.ForceTargetApplicationShutdown);
            
            return true;
        }
        catch (Exception ex)
        {
            Debug.WriteLine($"Rollback failed: {ex.Message}");
            return false;
        }
    }
}
```

---

## 📚 Tài Liệu Tham Khảo

### Microsoft Official Docs
- [MSIX Documentation](https://docs.microsoft.com/en-us/windows/msix/)
- [Windows App SDK](https://docs.microsoft.com/en-us/windows/apps/windows-app-sdk/)
- [Partner Center Guide](https://docs.microsoft.com/en-us/windows/uwp/publish/)

### Tools & Resources
- [MSIX Packaging Tool](https://www.microsoft.com/store/productId/9N5LW3JBCXKF)
- [Windows SDK](https://developer.microsoft.com/windows/downloads/windows-sdk/)
- [Visual Studio](https://visualstudio.microsoft.com/)

### Community
- [MSIX Tech Community](https://techcommunity.microsoft.com/t5/msix/ct-p/MSIX)
- [Windows Dev Discord](https://aka.ms/winuidiscord)
- [Stack Overflow - MSIX Tag](https://stackoverflow.com/questions/tagged/msix)

---

**📝 Document Version**: 1.0.0  
**📅 Last Updated**: 2026-01-12  
**✍️ Author**: DemoDeploy Team  
**📧 Support**: support@demodeploy.com

---

_Copyright © 2026 DemoDeploy. All rights reserved._
