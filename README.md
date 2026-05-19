# 🎮 PhoneRemote

![GitHub release (latest by date)](https://img.shields.io/github/v/release/amt2283/PhoneRemote)
![Platform](https://img.shields.io/badge/platform-iOS%20%7C%20Windows-lightgrey)
![License](https://img.shields.io/badge/license-MIT-blue)

Control your Windows PC from your iPhone via a seamless local WiFi connection. No IP typing required, just scan the QR code and control your PC from bed.

## ✨ Features
* **Zero Config Connection**: Just open the PC app, scan the QR code with the iOS app, and you're connected.
* **Low Latency Touchpad**: Fluid mouse control using the native iOS touch APIs. Left click, right click, double click, scroll, and drag & drop.
* **Native iOS Keyboard**: Full support for Spanish characters (ñ, á, é, í, ó, ú, ¿, ¡) via the native iOS keyboard.
* **Media Controls**: Dedicated buttons for volume control, play/pause, next/previous tracks, and YouTube specific shortcuts.
* **System Shortcuts**: Launch apps, open clipboard, turn off monitors, or sleep your PC with one tap.

## 🚀 Quick Start

### 1. Run the PC Server
1. Go to the [Releases page](../../releases/latest).
2. Download `PhoneRemote.exe`.
3. Double click to run it on your Windows PC. (Allow it through the Windows Firewall if prompted).
4. The app will display a QR code.

### 2. Install the iOS App
1. Download `PhoneRemote.ipa` from the [Releases page](../../releases/latest).
2. Install the IPA on your iPhone using:
   - **LiveContainer** (unsigned IPA)
   - **[AltStore](https://altstore.io/)** (Recommended for personal use)
   - **[Sideloadly](https://sideloadly.io/)**
   - Developer Enterprise Program
3. Open PhoneRemote on your iPhone.
4. Point the camera at the QR code on your PC screen.
5. Enjoy!

---

## 🛠️ Building from Source

### Windows Server (Python)
You need Python 3.10+ installed.

```bash
cd desktop
pip install -r requirements.txt
python main.py
```

To build your own `.exe`:
```bash
pyinstaller phoneremote.spec
```

### iOS App (SwiftUI)
You need a Mac with Xcode 15+ and Homebrew.

```bash
cd ios
brew install xcodegen
xcodegen generate
open PhoneRemote.xcodeproj
```

---

## ⚙️ GitHub Actions CI/CD Setup

This repository is configured to automatically build the Windows `.exe` and an unsigned iOS `.ipa`.

The iOS workflow is intended for LiveContainer, so it does not install Apple certificates, create a keychain, or require provisioning profile secrets. If GitHub Actions shows an `Install Apple Certificate` step, rerun the latest workflow from `main` after this change has been pushed.

**How to trigger a Release:**
```bash
git tag v1.0.0
git push origin v1.0.0
```
GitHub Actions will build both applications and attach them to a new GitHub Release.

## 📄 License
MIT License
