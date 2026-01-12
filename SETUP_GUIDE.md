# Setup Guide - Deployment Demo

## 🚀 Các bước setup đầy đủ để demo

### 1️⃣ Build MSIX Package

```powershell
# Tạo certificate nếu chưa có
cd Deployment
.\Create-Certificate.ps1

# Build release package
.\Build-MSIX.ps1 -Configuration Release -Platform x64
```

Kết quả: File `.msix` hoặc `.msixbundle` trong thư mục output

### 2️⃣ Setup GitHub Pages

#### Bước 1: Tạo branch gh-pages
```powershell
# Tạo orphan branch
git checkout --orphan gh-pages
git rm -rf .

# Copy deployment files
Copy-Item Deployment\DemoDeploy.appinstaller .
Copy-Item Deployment\update.json .
# Copy MSIX package khi đã build xong

# Commit
git add .
git commit -m "Setup GitHub Pages for deployment"
git push -u origin gh-pages
```

#### Bước 2: Enable GitHub Pages
1. Vào GitHub repo: https://github.com/Luongsosad/Deploy-WinUI
2. Settings → Pages
3. Source: gh-pages branch
4. Save

Sau vài phút, site sẽ available tại: `https://luongsosad.github.io/Deploy-WinUI/`

### 3️⃣ Tạo GitHub Release

#### Option A: Thủ công
1. Vào repo → Releases → Create new release
2. Tag version: `v1.0.1`
3. Release title: `Version 1.0.1 - Initial Release`
4. Upload MSIX package
5. Publish release

#### Option B: Tự động với GitHub Actions
Workflow đã có sẵn! Chỉ cần push tag:

```powershell
git tag v1.0.1
git push origin v1.0.1
```

GitHub Actions sẽ tự động:
- Build MSIX
- Create release
- Upload artifacts

### 4️⃣ Test Auto-Update

1. Cài đặt version 1.0.1 từ MSIX
2. Launch app
3. Click "Check for Updates"
4. App sẽ fetch từ GitHub và show update dialog

### 5️⃣ Test Web Installation

Sau khi setup GitHub Pages, user có thể install bằng URL:

```
ms-appinstaller:?source=https://luongsosad.github.io/Deploy-WinUI/DemoDeploy.appinstaller
```

## ✅ Quick Start Demo Setup

Để demo nhanh cho seminar:

```powershell
# 1. Build package
cd D:\Windows\DemoDeploy\Deployment
.\Create-Certificate.ps1
.\Build-MSIX.ps1 -Configuration Release -Platform x64

# 2. Push code với tag để trigger workflow
cd ..
git add .
git commit -m "feat: Complete deployment setup"
git tag v1.0.1
git push origin main
git push origin v1.0.1

# 3. Chờ GitHub Actions build xong (3-5 phút)
# 4. Setup GitHub Pages với files từ Deployment/
```

## 📝 Checklist trước khi demo

- [ ] MSIX package đã build và sign
- [ ] GitHub Pages đã enable
- [ ] Release đã tạo trên GitHub
- [ ] Test install từ MSIX file
- [ ] Test auto-update functionality
- [ ] Test web installation URL
- [ ] Verify certificate trusted

## 🎬 Demo Flow

1. **Show GitHub Pages** - URL hosting deployment files
2. **Install từ web** - ms-appinstaller:?source=...
3. **Launch app** - Show version, features
4. **Check update** - Click button, show dialog
5. **Show GitHub Release** - Latest version available
6. **Uninstall** - Clean removal

## 🔧 Troubleshooting

### Certificate không trusted
```powershell
# Import lại certificate
certmgr.msc
# Import vào Trusted Root Certification Authorities
```

### GitHub Pages 404
- Chờ 5-10 phút sau khi enable
- Verify branch gh-pages có files
- Check Settings → Pages → Site status

### Workflow không chạy
- Verify file `.github/workflows/build-msix.yml` tồn tại
- Check Actions tab → Enable workflows
- Push tag mới: `git tag v1.0.1-test`
