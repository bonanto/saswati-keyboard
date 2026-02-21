# Saswati (শাশ্বতী) - Bengali Inscript Keyboard for Linux

[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)
[![Platform](https://img.shields.io/badge/Platform-Linux-green.svg)]()
[![Language](https://img.shields.io/badge/Language-Bengali-orange.svg)]()

**Saswati** is a comprehensive Bengali (Bangla) keyboard layout for Linux with full support for conjunct characters, designed for seamless typing in the Bengali script on any Linux distribution.

## 🌟 Features

### ✨ Complete Bengali Support
- **Full conjunct character support** - Type complex Bengali conjuncts like ক্ষ, জ্ঞ, ড্ড with single keypresses
- **All Bengali characters** - Complete coverage of Bengali Unicode characters
- **Bengali numerals** - Native Bengali digits (০-৯) with standard NumPad (0-9)
- **Special characters** - Full support for Bengali punctuation and special symbols

### 🎯 Smart Keyboard Behavior
- **Four-layer key mapping** - Normal, Shift, AltGr (Right Alt), and AltGr+Shift layers
- **CapsLock immunity** - CapsLock has NO effect on typing (works same whether on or off)
- **Empty layer blocking** - Undefined key combinations produce no output (prevents accidental characters)
- **Intelligent modifier handling** - System shortcuts (Ctrl, Alt) work normally

### 🖥️ Universal Linux Compatibility
- **All major distributions** - Ubuntu, Debian, Fedora, RHEL, CentOS, Arch, Manjaro, openSUSE, and more
- **All desktop environments** - GNOME, KDE Plasma, XFCE, Cinnamon, MATE, Budgie, LXQt
- **X11 and Wayland** - Automatic detection and configuration for both session types
- **Auto-dependency installation** - Automatically installs required packages

### 🔧 Professional Installation
- **Automatic detection** - Detects your OS, desktop environment, and session type
- **Smart configuration** - Configures AltGr (Right Alt) properly for X11/Wayland
- **No warnings** - Clean installation without environment variable conflicts
- **Custom icon** - Beautiful "শাশ্বতী" icon in IBus menu
- **One-command installation** - Simple curl/wget installation from GitHub

### 🎨 User Experience
- **Display name** - Shows as "Bangla - Saswati Inscript (India)" in keyboard selector
- **Seamless switching** - Use Super+Space or your preferred hotkey to switch layouts
- **No conflicts** - Cleans up old configurations automatically
- **Persistent AltGr** - Right Alt key works reliably across reboots

---

## 📋 Requirements

### System Requirements
- **Operating System**: Any modern Linux distribution (2020+)
- **Python**: Python 3.6 or higher
- **IBus**: Version 1.5.0 or higher
- **Memory**: Minimal (< 10 MB)

### Distribution-Specific Packages
Automatically installed by the installer:

**Debian/Ubuntu-based:**
- `python3-gi`
- `gir1.2-ibus-1.0`
- `ibus`
- `librsvg2-bin`
- `imagemagick`

**Fedora/RHEL-based:**
- `python3-gobject`
- `ibus`
- `librsvg2-tools`
- `ImageMagick`

**Arch-based:**
- `python-gobject`
- `ibus`
- `librsvg`
- `imagemagick`

---

## 🚀 Quick Installation

### One-Command Installation (Recommended)

```bash
# Download and run installer
curl -fsSL https://raw.githubusercontent.com/bonanto/saswati-keyboard/main/install.sh | sudo bash
```

Or using `wget`:

```bash
wget -qO- https://raw.githubusercontent.com/bonanto/saswati-keyboard/main/install.sh | sudo bash
```

### Manual Installation

```bash
# Clone the repository
git clone https://github.com/bonanto/saswati-keyboard.git
cd saswati-keyboard

# Make scripts executable
chmod +x install.sh uninstall.sh

# Run installer
sudo ./install.sh
```

### Post-Installation Setup

1. **Restart your computer** (important!)
2. **Enable IBus** in System Settings (see [Setup Guide](SETUP_GUIDE.md))
3. **Add Saswati keyboard** to your input sources
4. **Switch layouts** using Super+Space

For detailed setup instructions, see [SETUP_GUIDE.md](SETUP_GUIDE.md)

---

## 📖 Documentation

- **[Setup Guide](SETUP_GUIDE.md)** - Complete installation and configuration guide
- **[Key Mappings](KEY_MAPPINGS.md)** - Full keyboard layout reference
- **[License](LICENSE)** - GPL v3.0 license information

---

## 🎯 Quick Start

After installation and restart:

```
Type: q     → ক্ষ (conjunct)
Type: k     → ক
Type: Shift+K → খ
Type: AltGr+g → জ্ঞ (conjunct)
Type: 1-9   → ১-৯ (Bengali numerals)
```

**CapsLock behavior:**
```
CapsLock ON + k     → ক (works normally!)
CapsLock ON + Shift+K → ক (cancel out)
```

---

## 🔧 Supported Systems

### ✅ Tested Distributions
- Ubuntu 20.04, 22.04, 24.04
- Debian 11, 12
- Fedora 38, 39, 40
- RHEL 8, 9
- CentOS Stream 8, 9
- Arch Linux (current)
- Manjaro (current)
- Linux Mint 21, 22
- Pop!_OS 22.04
- openSUSE Leap, Tumbleweed

### ✅ Tested Desktop Environments
- GNOME 40+ (X11 and Wayland)
- KDE Plasma 5.24+ (X11 and Wayland)
- XFCE 4.16+
- Cinnamon 5.0+
- MATE 1.26+
- Budgie 10.6+
- LXQt 1.0+

---

## 🗑️ Uninstallation

```bash
# If you cloned the repository
cd saswati-keyboard
sudo ./uninstall.sh

# Or download and run
curl -fsSL https://raw.githubusercontent.com/bonanto/saswati-keyboard/main/uninstall.sh | sudo bash
```

Then remove the keyboard from your System Settings and restart.

---

## 🐛 Troubleshooting

### Keyboard not appearing in list
```bash
# Restart IBus
pkill ibus-daemon
ibus-daemon -drxR --panel disable &  # For Wayland
# or
ibus-daemon -drxR &  # For X11
```

### AltGr not working
```bash
# For X11:
setxkbmap -option lv3:ralt_switch

# For Wayland (KDE):
# System Settings → Keyboard → Advanced → "Key to choose 3rd level" → Right Alt
```

### CapsLock still affecting typing
Update to the latest version and reinstall.

For more troubleshooting, see [SETUP_GUIDE.md](SETUP_GUIDE.md#troubleshooting)

---

## 🤝 Contributing

Contributions are welcome! Please feel free to submit issues or pull requests.

### How to Contribute
1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 📜 License

This project is licensed under the **GNU General Public License v3.0** - see the [LICENSE](LICENSE) file for details.

### What this means:
- ✅ **Free to use** - Use for any purpose
- ✅ **Free to modify** - Adapt to your needs
- ✅ **Free to distribute** - Share with others
- ⚠️ **Must credit** - Give credit to the original author
- ⚠️ **Share improvements** - Distribute modifications under GPL v3
- ⚠️ **Include license** - Include license and copyright notice

---

## 👨‍💻 Author

**Bonanto**
- Email: bonanto18@protonmail.com
- GitHub: [@bonanto](https://github.com/bonanto)

---

## 🙏 Acknowledgments

- IBus framework by the IBus team
- Bengali language community
- All contributors and testers

---

## 📊 Project Status

**Version:** 1.0.0  
**Status:** Stable  
**Last Updated:** December 2024

---

## ⭐ Show Your Support

If you find this project helpful, please give it a ⭐ on GitHub!

---

## 📸 Screenshots

![Saswati Keyboard in IBus Menu](screenshots/ibus-menu.png)
*Saswati keyboard in IBus input source selector*

![Typing Example](screenshots/typing-example.png)
*Typing Bengali with Saswati keyboard*

---

**শুভেচ্ছা! Happy typing in Bengali! 🇮🇳**
