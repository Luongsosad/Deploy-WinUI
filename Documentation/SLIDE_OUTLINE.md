# SLIDE OUTLINE - WinUI 3 Deployment

## Slide 1: Title
**WinUI 3 Deployment**  
*H? th?ng Deployment ??y ?? cho ?ng d?ng Windows hi?n ??i*

Sinh viên th?c hi?n: [Tên]  
Môn h?c: Windows Programming  
Gi?ng viên: [Tên GV]

---

## Slide 2: Agenda
?? **N?i dung trình bày**
1. Introduction - Deployment Challenges
2. MSIX Packaging Overview
3. Versioning System
4. Auto-Update Implementation
5. Deployment Options
6. Live Demo
7. Q&A

?? Th?i gian: 15 phút

---

## Slide 3: Traditional Deployment Problems
? **V?n ?? v?i ph??ng pháp c?**

| Method | Problems |
|--------|----------|
| **MSI Installer** | • Registry pollution<br>• DLL conflicts<br>• Complex scripting |
| **ClickOnce** | • Limited WinUI support<br>• No containerization |
| **ZIP Files** | • Manual updates<br>• No version control |

?? **C?n gi?i pháp hi?n ??i!**

---

## Slide 4: MSIX - Modern Solution
? **MSIX Packaging**

```
Traditional Install          MSIX Install
     ?                           ?
Registry entries            Container
DLL conflicts              Isolated
Leftovers                  Clean uninstall
Manual updates             Auto-update
```

**Key Benefits**:
- ?? Isolated container
- ?? Clean installation
- ?? Automatic updates
- ?? Store integration

---

## Slide 5: MSIX Structure
?? **Bên trong MSIX Package**

```
DemoDeploy.msix
??? AppxManifest.xml          # Metadata
??? Assets/                   # Icons
??? DemoDeploy.exe           # App
??? Dependencies/            # Runtime
??? AppxSignature.p7x        # Signature
```

**Manifest Highlights**:
```xml
<Identity 
    Name="DemoDeploy"
    Version="1.0.1.0"
    Publisher="CN=LUONG" />
```

---

## Slide 6: Versioning Strategy
?? **Semantic Versioning**

**Format**: `Major.Minor.Build.Revision`

| Part | When to Increment | Example |
|------|-------------------|---------|
| Major | Breaking changes | 1.0.0.0 ? 2.0.0.0 |
| Minor | New features | 1.0.0.0 ? 1.1.0.0 |
| Build | Bug fixes | 1.0.0.0 ? 1.0.1.0 |
| Revision | Hotfixes | 1.0.0.0 ? 1.0.0.1 |

**Implementation**:
```csharp
var package = Package.Current;
var version = package.Id.Version;
```

---

## Slide 7: Auto-Update Architecture
?? **Update Flow Diagram**

```
App Launch
    ?
Check Time (24h?)
    ?
Download .appinstaller
    ?
Compare Versions
    ?
Newer Available?
    ? Yes
Show Notification
    ?
User Accepts
    ?
Download & Install
    ?
Restart App
```

**Technologies**:
- AppInstaller Protocol
- Windows.Services.Store API
- HTTPS hosting

---

## Slide 8: AppInstaller Configuration
?? **Auto-Update Config**

```xml
<AppInstaller Uri="https://...">
    <MainBundle Version="1.0.1.0"
        Uri="https://.../App.msixbundle" />
        
    <UpdateSettings>
        <OnLaunch 
            HoursBetweenUpdateChecks="24"
            ShowPrompt="true" />
        <AutomaticBackgroundTask />
    </UpdateSettings>
</AppInstaller>
```

**Update Check Interval**: 24 hours  
**User Prompt**: Yes  
**Background Updates**: Enabled

---

## Slide 9: Implementation - UpdateChecker
?? **Code Implementation**

```csharp
public class UpdateChecker
{
    public async Task<VersionInfo> CheckForUpdatesAsync()
    {
        // Download update manifest
        var response = await _httpClient
            .GetStringAsync(UPDATE_URL);
        
        var updateData = JsonSerializer
            .Deserialize<UpdateData>(response);
        
        return new VersionInfo {
            CurrentVersion = GetAppVersion(),
            LatestVersion = Parse(updateData.Version),
            ReleaseNotes = updateData.ReleaseNotes
        };
    }
}
```

---

## Slide 10: Update UI
?? **User Experience**

**Update Dialog Components**:
- ? Current version display
- ? New version highlight
- ? Release notes (formatted)
- ? Action buttons (Update / Later)
- ? Progress indicator

**UX Principles**:
- Non-intrusive
- Clear communication
- User choice
- Easy to dismiss

---

## Slide 11: Deployment Options Comparison
?? **3 Deployment Methods**

| Method | Pros | Cons | Best For |
|--------|------|------|----------|
| **Microsoft Store** | • Auto-updates<br>• Global reach<br>• Trust badge | • $19 fee<br>• Certification wait | Public apps |
| **Web (AppInstaller)** | • Free<br>• Full control<br>• Quick updates | • Self-hosting<br>• HTTPS required | Beta/Internal |
| **Sideloading** | • Enterprise control<br>• Custom policies | • Certificate management | Corporate |

---

## Slide 12: Microsoft Store Process
?? **Store Submission Steps**

1. **Partner Center Account** ($19 one-time)
2. **Reserve App Name** (unique globally)
3. **Prepare Package**
   - Build Release MSIX
   - Test thoroughly
4. **Store Listing**
   - Screenshots (min 1366x768)
   - Description (200+ chars)
   - Age rating
   - Privacy policy URL
5. **Submit & Wait** (1-3 days)
6. **Publish** (worldwide)

---

## Slide 13: Signing & Security
?? **Code Signing**

**Certificate Types**:
```
1. Self-Signed (Testing)
   ?? Free
   ?? Trust manually

2. Code Signing (Production)
   ?? $100-300/year
   ?? Trusted automatically

3. Store Certificate (Auto)
   ?? Free
   ?? Microsoft signs
```

**Signing Command**:
```powershell
signtool sign /fd SHA256 /f cert.pfx App.msix
```

---

## Slide 14: CI/CD Pipeline
?? **Automated Build**

**GitHub Actions Workflow**:
```yaml
name: Build MSIX
on:
  push:
    tags: ['v*']
    
jobs:
  build:
    runs-on: windows-latest
    steps:
      - Checkout code
      - Setup .NET 8
      - Build MSIX
      - Create Release
      - Upload artifacts
```

**Benefits**:
- Consistent builds
- Automated releases
- Free hosting (GitHub)

---

## Slide 15: Demo Architecture
?? **Demo App Features**

**UI Components**:
- Version display
- Update checker button
- Deployment info viewer
- Feature checklist
- Technology showcase

**Services**:
- VersionHelper
- UpdateChecker
- Mock update server

**Packaging**:
- MSIX manifest
- AppInstaller config
- Build scripts

---

## Slide 16: Live Demo
??? **Demo Scenarios**

**Demo Script** (5 phút):

1. **Show Installed App**
   - Launch from Start Menu
   - Display version info

2. **Check for Updates**
   - Click "Check Updates"
   - Show update dialog
   - Display release notes

3. **Installation**
   - Open .msix file
   - Show installation prompt
   - Install quickly

4. **Uninstall**
   - Settings ? Apps
   - Uninstall cleanly
   - Verify removal

---

## Slide 17: Key Features Showcase
? **Implementation Highlights**

**Versioning**:
```csharp
var version = Package.Current.Id.Version;
```

**Update Check**:
```csharp
var updates = await UpdateChecker.CheckForUpdatesAsync();
```

**Update Dialog**:
```csharp
await ShowUpdateDialog(updateInfo);
```

**Package Info**:
```csharp
var publisher = Package.Current.PublisherDisplayName;
```

---

## Slide 18: Technologies Used
??? **Tech Stack**

| Technology | Version | Purpose |
|------------|---------|---------|
| .NET | 8.0 | Runtime |
| WinUI 3 | Windows App SDK 1.8 | UI Framework |
| MSIX | Latest | Packaging |
| AppInstaller | 2021 Schema | Auto-update |
| GitHub Actions | Latest | CI/CD |

**Additional Tools**:
- PowerShell scripts
- SignTool
- MSBuild

---

## Slide 19: Testing Checklist
? **Quality Assurance**

**Installation Testing**:
- [ ] Clean install
- [ ] Upgrade install
- [ ] Uninstall
- [ ] Reinstall

**Functionality**:
- [ ] Version display
- [ ] Update check
- [ ] Dialog display
- [ ] Settings persist

**Visual**:
- [ ] Icons correct
- [ ] High DPI
- [ ] Dark/Light theme

---

## Slide 20: Troubleshooting
?? **Common Issues & Solutions**

| Issue | Solution |
|-------|----------|
| Certificate not trusted | Import to Trusted Root |
| Deployment failed | Uninstall previous version |
| Update not detected | Check HTTPS URL |
| App won't launch | Verify dependencies |

**Debug Tools**:
```powershell
Get-AppxPackage *DemoDeploy*
Get-AppxLog -ActivityId <ID>
```

---

## Slide 21: Best Practices
?? **Recommendations**

**Development**:
- ? Use semantic versioning
- ? Test on clean machines
- ? Document changes
- ? Automate builds

**Deployment**:
- ? Sign with valid certificate
- ? Test updates thoroughly
- ? Provide clear release notes
- ? Monitor installation rates

**User Experience**:
- ? Non-intrusive updates
- ? Clear version display
- ? Easy uninstall

---

## Slide 22: Future Enhancements
?? **Roadmap**

**Planned Features**:
1. **Delta Updates**
   - Only download changes
   - Faster updates

2. **A/B Testing**
   - Gradual rollout
   - Feature flags

3. **Telemetry**
   - Crash reporting
   - Usage analytics

4. **Localization**
   - Multi-language support
   - Region-specific content

---

## Slide 23: Project Structure
?? **Code Organization**

```
DemoDeploy/
??? Models/
?   ??? VersionInfo.cs
??? Services/
?   ??? VersionHelper.cs
?   ??? UpdateChecker.cs
??? Deployment/
?   ??? DemoDeploy.appinstaller
?   ??? Build-MSIX.ps1
?   ??? Create-Certificate.ps1
??? Documentation/
?   ??? DEPLOYMENT_GUIDE.md
??? .github/workflows/
    ??? build-msix.yml
```

**Total**: ~2000 lines of code

---

## Slide 24: Resources
?? **Learning Materials**

**Official Documentation**:
- MSIX Packaging: docs.microsoft.com/windows/msix/
- Windows App SDK: docs.microsoft.com/windows/apps/
- Store Publishing: docs.microsoft.com/windows/apps/publish/

**Tools**:
- Visual Studio 2022
- MSIX Packaging Tool
- Windows SDK

**Community**:
- Windows Dev Discord
- StackOverflow [winui-3]

---

## Slide 25: Conclusion
?? **Tóm t?t**

**?ã th?c hi?n**:
- ? MSIX Packaging ??y ??
- ? Versioning system
- ? Auto-update functionality
- ? Multiple deployment options
- ? Complete documentation

**K?t qu?**:
- ?? Production-ready app
- ?? Seamless updates
- ?? Store-ready package
- ?? Comprehensive docs

**Demo**: github.com/yourusername/demodeploy

---

## Slide 26: Q&A
? **Câu h?i th??ng g?p**

**Q1**: Chi phí deploy lên Store?  
**A**: $19 one-time registration

**Q2**: Certificate có giá bao nhiêu?  
**A**: $100-300/year (ho?c dùng Store cert mi?n phí)

**Q3**: Update t? ??ng có b?t bu?c không?  
**A**: Không, user có th? ch?n "Later"

**Q4**: MSIX có th? ch?y trên Win 7?  
**A**: Không, yêu c?u Windows 10 1809+

---

## Slide 27: Thank You
?? **C?m ?n!**

**Contact**:
- Email: [your-email]
- GitHub: [your-github]
- Demo: [demo-link]

**Repository**:
- Source code: github.com/yourusername/demodeploy
- Documentation: Full guides included
- Issues: Bug reports welcome

**Questions?**  
Vui lòng ??t câu h?i! ??

---

# NOTES FOR PRESENTER

## Timing (15 minutes total)
- Slides 1-4: 2 minutes (Introduction)
- Slides 5-10: 3 minutes (Technical deep-dive)
- Slides 11-14: 3 minutes (Deployment options)
- Slides 15-16: 5 minutes (Live demo)
- Slides 17-27: 2 minutes (Wrap-up, Q&A)

## Demo Tips
1. Pre-install app before presentation
2. Have .msix file ready on desktop
3. Prepare backup screenshots if demo fails
4. Show update dialog with mock data
5. Demonstrate uninstall in Settings

## Key Points to Emphasize
- **Modern solution**: MSIX vs old MSI
- **User experience**: Seamless updates
- **Flexibility**: Multiple deployment options
- **Production-ready**: Complete implementation

## Backup Slides
Prepare extra slides on:
- Technical troubleshooting
- Certificate details
- Store policies
- Alternative solutions
