# Saswati Keyboard - Complete Setup Guide

This guide provides comprehensive instructions for installing, configuring, and using the Saswati Bengali keyboard on Linux.

---

## Table of Contents

1. [Installation](#installation)
2. [Post-Installation Setup](#post-installation-setup)
3. [Desktop Environment Specific Setup](#desktop-environment-specific-setup)
4. [Using the Keyboard](#using-the-keyboard)
5. [Troubleshooting](#troubleshooting)
6. [Uninstallation](#uninstallation)
7. [Advanced Configuration](#advanced-configuration)

---

## Installation

### Prerequisites Check

Before installing, ensure your system has:
- Python 3 installed (`python3 --version`)
- Internet connection (for downloading dependencies)
- sudo/root access

### Method 1: One-Command Installation (Easiest)

Open a terminal and run:

```bash
curl -fsSL https://raw.githubusercontent.com/bonanto/saswati-keyboard/main/install.sh | sudo bash
```

Or using wget:

```bash
wget -qO- https://raw.githubusercontent.com/bonanto/saswati-keyboard/main/install.sh | sudo bash
```

The installer will:
1. ✅ Detect your Linux distribution
2. ✅ Detect your desktop environment
3. ✅ Detect X11 or Wayland session
4. ✅ Install all required dependencies
5. ✅ Configure AltGr (Right Alt) key
6. ✅ Register Saswati keyboard in IBus
7. ✅ Create a custom icon

### Method 2: Manual Installation

```bash
# Step 1: Clone the repository
git clone https://github.com/bonanto/saswati-keyboard.git
cd saswati-keyboard

# Step 2: Make scripts executable
chmod +x install.sh uninstall.sh

# Step 3: Run the installer
sudo ./install.sh
```

### Installation Process

The installer will display 7 phases:

```
PHASE 1: SYSTEM DETECTION
  - Detecting user, distribution, session type, desktop environment

PHASE 2: CLEANING OLD CONFIGURATIONS
  - Removing old environment variables

PHASE 3: INSTALLING DEPENDENCIES
  - Installing required packages

PHASE 4: INSTALLING SASWATI ENGINE
  - Installing keyboard engine and wrapper

PHASE 5: GENERATING ICON
  - Creating custom icon

PHASE 6: CONFIGURING ALTGR
  - Setting up Right Alt key

PHASE 7: REGISTERING KEYBOARD IN IBUS
  - Registering Saswati in IBus
```

### Installation Complete

After successful installation, you'll see:

```
✓ Engine installed: /usr/share/ibus-saswati
✓ Icon created: /usr/share/ibus-saswati/icons/saswati.png
✓ AltGr configured for wayland/x11
✓ Keyboard registered in IBus
```

---

## Post-Installation Setup

### Step 1: Restart Your Computer

**This is mandatory!** Restart ensures:
- AltGr configuration is loaded
- IBus registration is complete
- All environment settings are applied

```bash
sudo reboot
```

### Step 2: Enable IBus (If Not Already Enabled)

#### For KDE Plasma:

1. Open **System Settings**
2. Navigate to: **Input Devices** → **Virtual Keyboard**
3. Select: **IBus Wayland** (or just **IBus** for X11)
4. Click **Apply**

#### For GNOME:

1. Open **Settings**
2. Go to **Keyboard** → **Input Sources**
3. IBus should already be active
4. If not, it will be added when you add Saswati

#### For XFCE:

1. Open **Settings Manager**
2. Go to **Session and Startup** → **Application Autostart**
3. Add a new entry:
   - Name: `IBus Daemon`
   - Command: `ibus-daemon -drxR`
   - Check "Trigger on each login"

#### For Cinnamon/MATE:

1. Open **System Settings**
2. Go to **Input Method**
3. Select **IBus** as the input method framework
4. Click **Apply**

### Step 3: Add Saswati Keyboard

#### KDE Plasma

1. Open **System Settings**
2. Navigate to: **Input Devices** → **Keyboard** → **Layouts**
3. Click the **Add** button (usually a + icon)
4. In the search box, type: **Saswati** or **Bangla**
5. Select: **Bangla - Saswati Inscript (India)**
6. Click **OK**
7. You should now see Saswati in your layout list

**Keyboard Switching:**
- Default: `Alt + Shift`
- Or configure in: System Settings → Shortcuts → Switch to Next Keyboard Layout

#### GNOME

1. Open **Settings**
2. Go to: **Keyboard** → **Input Sources**
3. Click the **+** button
4. Select **Bengali** from the language list
5. Find and select: **Saswati Inscript (India)**
6. Click **Add**

**Keyboard Switching:**
- Default: `Super + Space`
- Change in: Settings → Keyboard → Input Source Switching

#### XFCE

1. Open **Settings Manager**
2. Go to: **Keyboard** → **Layout**
3. Uncheck **"Use system defaults"**
4. Click **Add** button
5. Search for: **Bengali** or **Saswati**
6. Select: **Bangla - Saswati Inscript (India)**
7. Click **OK**
8. Configure switching shortcut in the same dialog

#### Cinnamon

1. Open **System Settings**
2. Go to: **Keyboard** → **Layouts**
3. Click **Add** (+ button)
4. Search: **Saswati** or **Bangla**
5. Select: **Bangla - Saswati Inscript (India)**
6. Click **Add**

**Keyboard Switching:**
- Right-click keyboard indicator in panel
- Select switching options

#### MATE

1. Open **System** → **Preferences** → **Keyboard**
2. Go to **Layouts** tab
3. Click **Add**
4. Select: **Bengali**
5. Choose: **Saswati Inscript (India)**
6. Click **Add**

#### Using IBus Preferences (Universal Method)

Works for all desktop environments:

1. Open terminal and run:
   ```bash
   ibus-setup
   ```
2. Go to **Input Method** tab
3. Click **Add** button
4. Search for: **Bengali**
5. Select: **Saswati Inscript (India)**
6. Click **Add**

---

## Using the Keyboard

### Switching Between Layouts

**Common keyboard shortcuts:**
- **GNOME:** `Super + Space`
- **KDE Plasma:** `Alt + Shift` or configure your own
- **XFCE/Cinnamon/MATE:** Configure in keyboard settings
- **Using IBus indicator:** Click the keyboard icon in system tray

### Basic Typing

Once Saswati is active:

```
Type: k → ক
Type: a → া
Type: m → ম
Type: ka → কা
Type: kam → কাম
```

### Conjunct Characters

Saswati supports single-keypress conjuncts:

```
Type: q → ক্ষ (ksha)
Type: AltGr + g → জ্ঞ (gya)
Type: AltGr + d → ড্ড (dda)
Type: AltGr + c → ঞ্চ (ncha)
Type: AltGr + v → দ্ধ (ddha)
Type: AltGr + n → ষ্ণ (shna)
```

### Numbers

**Main keyboard:**
```
Type: 1 2 3 4 5 → ১ ২ ৩ ৪ ৫ (Bengali numerals)
```

**NumPad:**
```
NumPad: 1 2 3 4 5 → 1 2 3 4 5 (Western numerals)
```

### Special Characters

```
Type: ` (backtick) → ্ (hasanta/virama)
Type: Shift + ` → ‌ (ZWNJ - Zero Width Non-Joiner)
Type: . (period) → । (dari/vertical bar)
Type: AltGr + Shift + . → ॥ (double dari)
```

### CapsLock Behavior

**CapsLock has NO effect on Bengali typing:**

```
CapsLock OFF + k → ক
CapsLock ON + k → ক (same result!)

CapsLock OFF + Shift + K → খ
CapsLock ON + Shift + K → ক (Caps and Shift cancel out)
```

### Empty Layers

Some key combinations are intentionally undefined:

```
Type: AltGr + w → (nothing)
Type: AltGr + q → (nothing)
Type: AltGr + p → (nothing)
Type: AltGr + h → (nothing)
```

This prevents accidental characters when exploring the keyboard.

---

## Troubleshooting

### Issue 1: Keyboard Not Appearing in List

**Solution:**

1. Restart IBus:
   ```bash
   pkill ibus-daemon
   ibus-daemon -drxR --panel disable &  # For Wayland
   # OR
   ibus-daemon -drxR &  # For X11
   ```

2. Clear IBus cache:
   ```bash
   rm -rf ~/.cache/ibus
   ibus restart
   ```

3. Log out and log back in

### Issue 2: AltGr (Right Alt) Not Working

**For X11:**
```bash
setxkbmap -option lv3:ralt_switch
```

**For Wayland (KDE):**
1. System Settings → Input Devices → Keyboard → Advanced
2. Expand "Key to choose 3rd level"
3. Check "Right Alt"
4. Click Apply

**For Wayland (GNOME):**
```bash
gsettings set org.gnome.desktop.input-sources xkb-options "['lv3:ralt_switch']"
```

**Verify AltGr is configured:**
```bash
# Check current settings
setxkbmap -print -verbose 10 | grep lv3

# For Wayland, check:
localectl status
```

### Issue 3: Characters Not Typing Correctly

**Check active layout:**
1. Look at keyboard indicator in system tray
2. Ensure "Saswati" or "Bangla" is selected
3. Try switching layouts with Super+Space

**Verify installation:**
```bash
ls -l /usr/share/ibus-saswati/main.py
ls -l /usr/share/ibus/component/saswati.xml
```

Both files should exist.

### Issue 4: Getting Environment Variable Warnings

**Error message:**
```
Please unset QT_IM_MODULE and GTK_IM_MODULE...
```

**Solution:**

1. Edit your `.bashrc`:
   ```bash
   nano ~/.bashrc
   ```

2. Remove these lines if present:
   ```bash
   export GTK_IM_MODULE=ibus
   export QT_IM_MODULE=ibus
   export XMODIFIERS=@im=ibus
   ```

3. Save and reload:
   ```bash
   source ~/.bashrc
   ```

4. Restart your computer

### Issue 5: CapsLock Still Affecting Typing

**Solution:**

Update to the latest version:
```bash
cd saswati-keyboard
git pull
sudo ./install.sh
```

### Issue 6: Icon Not Showing

**Solution:**

1. Check if icon exists:
   ```bash
   ls -l /usr/share/ibus-saswati/icons/saswati.png
   ```

2. Regenerate icon:
   ```bash
   cd saswati-keyboard
   sudo ./install.sh
   ```

3. Clear IBus cache:
   ```bash
   rm -rf ~/.cache/ibus
   ibus restart
   ```

### Issue 7: Keyboard Works But System Shortcuts Don't

**Explanation:**
This is normal! When Saswati is active:
- Ctrl combinations work (Ctrl+C, Ctrl+V, etc.)
- Left Alt combinations work (Alt+Tab, Alt+F4, etc.)
- Super/Windows key works (Super+Space, etc.)
- Right Alt is used for AltGr (typing Bengali characters)

### Issue 8: NumPad Typing Bengali Numbers

**This should NOT happen with Saswati.**

If it does:
1. Check NumLock is ON
2. Verify you're using the correct keyboard:
   ```bash
   ibus engine
   ```
   Should show: `saswati`

---

## Uninstallation

### Method 1: Using Uninstaller Script

```bash
# If you have the repository
cd saswati-keyboard
sudo ./uninstall.sh

# Or download and run
curl -fsSL https://raw.githubusercontent.com/bonanto/saswati-keyboard/main/uninstall.sh | sudo bash
```

### Method 2: Manual Uninstallation

```bash
# Stop IBus
pkill ibus-daemon

# Remove files
sudo rm -rf /usr/share/ibus-saswati
sudo rm -f /usr/share/ibus/component/saswati.xml
sudo rm -f /etc/X11/xorg.conf.d/90-saswati-kbd.conf

# Clear cache
rm -rf ~/.cache/ibus

# Restart IBus
ibus-daemon -drxR &
```

### Post-Uninstallation

1. Remove Saswati from your keyboard layouts in System Settings
2. Log out and log back in (or restart)

---

## Advanced Configuration

### Changing Keyboard Switching Shortcut

#### KDE Plasma
1. System Settings → Shortcuts
2. Search: "Switch to Next Keyboard Layout"
3. Set your preferred shortcut

#### GNOME
1. Settings → Keyboard → Keyboard Shortcuts
2. View and Customize Shortcuts → Typing
3. "Switch to next input source"

#### Using IBus Preferences
```bash
ibus-setup
```
Go to: General → Keyboard Shortcuts → Next input method

### Customizing Key Mappings

To modify key mappings, edit the engine source:

1. Edit the engine file:
   ```bash
   sudo nano /usr/share/ibus-saswati/main.py
   ```

2. Find the `KEY_MAP` dictionary (starts around line 30)

3. Modify mappings following this format:
   ```python
   (IBus.KEY_x, 0): "output_character",  # Normal key
   (IBus.KEY_X, IBus.ModifierType.SHIFT_MASK): "shifted_character",  # Shift+key
   (IBus.KEY_x, IBus.ModifierType.MOD5_MASK): "altgr_character",  # AltGr+key
   ```

4. Save and restart IBus:
   ```bash
   pkill ibus-daemon
   ibus-daemon -drxR &
   ```

### Running IBus on Startup

**For systems without auto-start:**

1. Create autostart entry:
   ```bash
   mkdir -p ~/.config/autostart
   nano ~/.config/autostart/ibus.desktop
   ```

2. Add this content:
   ```ini
   [Desktop Entry]
   Type=Application
   Name=IBus Daemon
   Exec=ibus-daemon -drxR --panel disable
   Icon=ibus
   Comment=Start IBus input method framework
   X-GNOME-Autostart-enabled=true
   ```

3. Make it executable:
   ```bash
   chmod +x ~/.config/autostart/ibus.desktop
   ```

---

## Getting Help

### Check Installation Status

```bash
# Verify installation
ls -la /usr/share/ibus-saswati/
ls -la /usr/share/ibus/component/saswati.xml

# Check IBus version
ibus version

# List available engines
ibus list-engine

# Check current engine
ibus engine
```

### System Information

When reporting issues, include:

```bash
# OS information
cat /etc/os-release

# Desktop environment
echo $XDG_CURRENT_DESKTOP

# Session type
echo $XDG_SESSION_TYPE

# IBus version
ibus version

# Python version
python3 --version
```

### Reporting Issues

Report issues on GitHub: [github.com/bonanto/saswati-keyboard/issues](https://github.com/bonanto/saswati-keyboard/issues)

Include:
- Your Linux distribution and version
- Desktop environment
- Session type (X11 or Wayland)
- Error messages (if any)
- Output from system information commands above

---

## Additional Resources

- [Key Mappings Reference](KEY_MAPPINGS.md)
- [Main README](README.md)
- [License Information](LICENSE)
- [GitHub Repository](https://github.com/bonanto/saswati-keyboard)

---

**Need more help? Contact: bonanto18@protonmail.com**

**শুভেচ্ছা! Happy typing! 🇮🇳**
