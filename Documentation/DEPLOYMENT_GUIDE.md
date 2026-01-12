# H??NG D?N DEPLOYMENT CHO WINUI 3

## ?? BÁO CÁO SEMINAR

### I. GI?I THI?U

#### 1.1 T?ng quan v? Deployment
Deployment là quá trình ??a ?ng d?ng t? môi tr??ng phát tri?n ??n tay ng??i dùng cu?i. V?i WinUI 3, Microsoft cung c?p nhi?u ph??ng th?c deployment hi?n ??i thông qua MSIX packaging.

#### 1.2 Thách th?c v?i Traditional Deployment
- **MSI Installers**: Ph?c t?p, ?? l?i registry entries
- **ClickOnce**: Limited features, không support WinUI 3
- **Manual Installation**: Không có auto-update, khó qu?n lý

#### 1.3 Gi?i pháp: MSIX Packaging
MSIX là ??nh d?ng packaging hi?n ??i c?a Windows, k?t h?p ?u ?i?m c?a:
- **Containerization**: App ch?y trong isolated environment
- **Clean Installation/Uninstallation**: Không ?? l?i traces
- **Auto-updates**: H? tr? seamless updates
- **Store Integration**: Deploy qua Microsoft Store

---

### II. MSIX PACKAGING

#### 2.1 C?u trúc MSIX Package

```
DemoDeploy.msix
??? AppxManifest.xml          # Package metadata
??? [Content_Types].xml       # MIME types
??? Assets/                   # Icons, logos
?   ??? Square150x150Logo.png
?   ??? Square44x44Logo.png
?   ??? StoreLogo.png
??? DemoDeploy.exe           # Executable
??? Dependencies/            # Runtime dependencies
?   ??? VCLibs
?   ??? WindowsAppRuntime
??? AppxSignature.p7x        # Digital signature
```

#### 2.2 Package.appxmanifest

File quan tr?ng nh?t, ??nh ngh?a:

```xml
<Identity 
    Name="Package-ID"
    Publisher="CN=Publisher-Name"
    Version="Major.Minor.Build.Revision" />
```

**Các thành ph?n chính**:
- **Identity**: Package ID, Publisher, Version
- **Properties**: Display name, Logo
- **Dependencies**: Min Windows version, Dependencies
- **Applications**: Entry point, Visual elements
- **Capabilities**: Permissions required

#### 2.3 Versioning Strategy

**Format**: `Major.Minor.Build.Revision`

- **Major** (1.x.x.x): Breaking changes
- **Minor** (x.1.x.x): New features
- **Build** (x.x.1.x): Bug fixes
- **Revision** (x.x.x.1): Hotfixes

**Best Practices**:
- Luôn increment version khi release
- Document changes trong release notes
- Maintain backward compatibility khi possible

---

### III. AUTO-UPDATE SYSTEM

#### 3.1 AppInstaller Protocol

File `.appinstaller` ??nh ngh?a cách app update:

```xml
<AppInstaller 
    Uri="https://domain.com/app.appinstaller"
    Version="1.0.1.0">
    
    <MainBundle 
        Uri="https://domain.com/App.msixbundle" />
        
    <UpdateSettings>
        <OnLaunch 
            HoursBetweenUpdateChecks="24"
            ShowPrompt="true" />
        <AutomaticBackgroundTask />
    </UpdateSettings>
</AppInstaller>
```

**Update Flow**:
1. App launch ? Check time since last check
2. If > 24h ? Download `.appinstaller` file
3. Compare version ? If newer available
4. Show prompt ? User accept
5. Download update ? Install ? Restart app

#### 3.2 Implementation trong C#

**VersionHelper.cs**:
```csharp
public static Version GetAppVersion()
{
    var package = Package.Current;
    var version = package.Id.Version;
    return new Version(
        version.Major, 
        version.Minor, 
        version.Build, 
        version.Revision
    );
}
```

**UpdateChecker.cs**:
```csharp
public async Task<VersionInfo> CheckForUpdatesAsync()
{
    var response = await _httpClient.GetStringAsync(UPDATE_URL);
    var updateData = JsonSerializer.Deserialize<UpdateData>(response);
    
    return new VersionInfo {
        CurrentVersion = VersionHelper.GetAppVersion(),
        LatestVersion = Version.Parse(updateData.Version),
        ReleaseNotes = updateData.ReleaseNotes
    };
}
```

#### 3.3 Update Notification UI

```csharp
private async Task ShowUpdateDialog(VersionInfo info)
{
    var dialog = new ContentDialog {
        Title = "Update Available!",
        Content = $"Version {info.LatestVersion}\n\n{info.ReleaseNotes}",
        PrimaryButtonText = "Download",
        CloseButtonText = "Later"
    };
    
    var result = await dialog.ShowAsync();
    if (result == ContentDialogResult.Primary) {
        // Launch browser to download
        await Launcher.LaunchUriAsync(new Uri(info.DownloadUrl));
    }
}
```

---

### IV. DEPLOYMENT OPTIONS

#### 4.1 Microsoft Store Deployment

**?u ?i?m**:
- ? Automatic updates
- ? Global distribution
- ? Trust badge
- ? Revenue sharing (paid apps)
- ? Analytics dashboard

**Nh??c ?i?m**:
- ? $19 registration fee
- ? Certification process (1-3 days)
- ? Store policies restrictions

**Quy trình**:
1. **T?o tài kho?n**: Partner Center registration
2. **Reserve name**: App name ph?i unique
3. **Prepare package**: Build MSIX, test thoroughly
4. **Store listing**:
   - Screenshots (minimum 1366x768)
   - Description (Vietnamese + English)
   - Age rating
   - Privacy policy URL
5. **Submit**: Upload MSIX, wait for certification
6. **Publish**: Once approved, available worldwide

**Store Listing Requirements**:
- Minimum 1 screenshot
- App icon (300x300)
- Description (200+ characters)
- Age rating questionnaire
- Privacy policy (if app collects data)

#### 4.2 Sideloading (Enterprise)

**Use Case**: Internal corporate apps

**Setup**:
1. **Certificate**: Enterprise CA certificate
2. **Group Policy**: Enable sideloading
3. **Distribution**: SCCM, Intune, or file share

**PowerShell Installation**:
```powershell
Add-AppxPackage -Path "\\server\share\App.msix"
```

**Advantages**:
- Full control over distribution
- No Store policies
- Custom update schedule

#### 4.3 Web Deployment (AppInstaller)

**Best for**: Public apps without Store listing

**Setup**:
1. **Host MSIX**: Azure Blob, GitHub Releases, CDN
2. **Create .appinstaller**: Point to HTTPS URL
3. **Share link**: Users install via browser

**Installation URL**:
```
ms-appinstaller:?source=https://domain.com/app.appinstaller
```

**Requirements**:
- HTTPS hosting (security)
- Valid SSL certificate
- Proper MIME types configured

**Web Server Configuration**:
```xml
<staticContent>
    <mimeMap fileExtension=".msix" mimeType="application/msix" />
    <mimeMap fileExtension=".appinstaller" mimeType="application/appinstaller" />
</staticContent>
```

---

### V. SIGNING & CERTIFICATES

#### 5.1 Certificate Types

**1. Self-Signed Certificate** (Testing only)
```powershell
New-SelfSignedCertificate -Type Custom -Subject "CN=YourName" `
    -KeyUsage DigitalSignature -CertStoreLocation "Cert:\CurrentUser\My"
```

**2. Code Signing Certificate** (Production)
- DigiCert, GlobalSign, Sectigo
- Cost: ~$100-300/year
- Valid for 1-3 years

**3. Microsoft Store Certificate** (Automatic)
- Free when publishing to Store
- Microsoft signs on your behalf

#### 5.2 Signing Process

**Using SignTool**:
```powershell
signtool sign /fd SHA256 /f Certificate.pfx /p PASSWORD App.msix
```

**Using Visual Studio**:
1. Project Properties ? Package ? Signing
2. Choose certificate ? Browse
3. Build ? Automatically signed

#### 5.3 Trust Chain

```
Trusted Root CA
    ?? Intermediate CA
        ?? Code Signing Certificate
            ?? Your App (signed)
```

**Installation Trust**:
- Store apps: Automatic trust
- Sideloaded: Certificate must be in Trusted Root

---

### VI. BUILD & CI/CD

#### 6.1 Manual Build (Visual Studio)

**Steps**:
1. Solution Explorer ? Right-click project
2. Publish ? Create App Packages
3. Choose distribution method:
   - Microsoft Store
   - Sideloading
4. Select target architectures (x64, x86, ARM64)
5. Configure signing
6. Build ? Output in `AppPackages\` folder

#### 6.2 Command-Line Build

**PowerShell Script** (`Build-MSIX.ps1`):
```powershell
$msbuildPath = "C:\Program Files\Microsoft Visual Studio\...\MSBuild.exe"

& $msbuildPath DemoDeploy.csproj `
    /p:Configuration=Release `
    /p:Platform=x64 `
    /p:UapAppxPackageBuildMode=StoreUpload `
    /p:AppxBundle=Always `
    /p:GenerateAppxPackageOnBuild=true
```

#### 6.3 GitHub Actions CI/CD

**Workflow** (`.github/workflows/build-msix.yml`):

```yaml
name: Build MSIX

on:
  push:
    tags: ['v*']

jobs:
  build:
    runs-on: windows-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-dotnet@v3
      - uses: microsoft/setup-msbuild@v1.1
      
      - name: Build MSIX
        run: msbuild /p:Configuration=Release /p:AppxBundle=Always
        
      - name: Create Release
        uses: softprops/action-gh-release@v1
        with:
          files: '**/*.msix'
```

**Benefits**:
- Automatic builds on version tags
- GitHub Releases hosting (free)
- Consistent build environment

---

### VII. TESTING CHECKLIST

#### 7.1 Pre-Deployment Tests

**Installation**:
- [ ] Clean install on fresh Windows
- [ ] Install over previous version (upgrade)
- [ ] Uninstall completely
- [ ] Reinstall after uninstall

**Functionality**:
- [ ] App launches successfully
- [ ] All features work
- [ ] Version displays correctly
- [ ] Settings persist

**Visual**:
- [ ] Icons display in Start Menu
- [ ] Taskbar icon correct
- [ ] High DPI scaling
- [ ] Dark/Light theme

#### 7.2 Update Testing

- [ ] Check for updates works
- [ ] Update notification shows
- [ ] Update downloads successfully
- [ ] App restarts with new version
- [ ] Data/settings preserved

#### 7.3 Certificate Testing

- [ ] Certificate trusted
- [ ] No SmartScreen warnings
- [ ] Publisher name displays correctly

---

### VIII. TROUBLESHOOTING

#### 8.1 Common Issues

**Problem**: "Can't install because certificate not trusted"
**Solution**: 
```powershell
Import-Certificate -FilePath cert.cer -CertStoreLocation Cert:\LocalMachine\TrustedPeople
```

**Problem**: "Deployment failed with HRESULT: 0x80073CF3"
**Solution**: Package already installed, uninstall first
```powershell
Get-AppxPackage *DemoDeploy* | Remove-AppxPackage
```

**Problem**: Update not detecting
**Solution**:
- Verify .appinstaller URL is HTTPS
- Check version number incremented
- Clear Windows Store cache

#### 8.2 Debugging Tips

**View installation logs**:
```powershell
Get-AppxLog -ActivityId <ID> | Out-File log.txt
```

**Check package status**:
```powershell
Get-AppxPackage -Name DemoDeploy
```

---

### IX. K?T LU?N

#### 9.1 T?ng k?t

Deployment cho WinUI 3 app s? d?ng MSIX mang l?i:
- **Modern packaging**: Containerized, clean
- **Flexible distribution**: Store, Web, Enterprise
- **Auto-updates**: Seamless user experience
- **Security**: Code signing, certificate trust

#### 9.2 Best Practices

1. **Versioning**: Semantic versioning, increment consistently
2. **Testing**: Test installation on clean machines
3. **Updates**: Regular updates with clear release notes
4. **Documentation**: User guides, troubleshooting
5. **Monitoring**: Track installation success rate

#### 9.3 Future Improvements

- **Delta updates**: Only download changed files
- **A/B testing**: Gradual rollout to users
- **Crash reporting**: Telemetry integration
- **In-app purchases**: Monetization
- **Multi-language**: Localization support

---

### X. TÀI LI?U THAM KH?O

1. **Microsoft Docs**:
   - MSIX Packaging: https://docs.microsoft.com/windows/msix/
   - Windows App SDK: https://docs.microsoft.com/windows/apps/windows-app-sdk/
   - Store Submission: https://docs.microsoft.com/windows/apps/publish/

2. **Tools**:
   - MSIX Packaging Tool: Download from Store
   - App Installer: Built into Windows 10+
   - Visual Studio 2022: Latest version

3. **Community**:
   - Windows Dev Discord
   - StackOverflow: [winui-3] tag
   - GitHub Discussions

---

**Ng??i th?c hi?n**: [Tên c?a b?n]  
**Ngày hoàn thành**: [Ngày hôm nay]  
**Môn h?c**: Windows Programming  
**Gi?ng viên**: [Tên GV]
