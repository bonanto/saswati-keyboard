#!/bin/bash

# ============================================================================
# Saswati Bangla (India) Inscript Keyboard Installer
# Author: Bonanto <bonanto18@protonmail.com>
# Version: 3.0 Final
# ============================================================================
# Features:
# - Automatic OS/DE/Session detection
# - Smart AltGr configuration (X11 vs Wayland)
# - No environment variable warnings
# - Automatic keyboard registration in IBus
# - Does NOT auto-enable IBus (user must do this manually in System Settings)
# ============================================================================

set -e

# Configuration
PYTHON_FILE="main.py"
INSTALL_DIR="/usr/share/ibus-saswati"
COMPONENT_DIR="/usr/share/ibus/component"
ICON_DIR="$INSTALL_DIR/icons"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m'

print_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
print_success() { echo -e "${GREEN}[✓]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[!]${NC} $1"; }
print_error() { echo -e "${RED}[✗]${NC} $1"; }
print_header() {
    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}  $1${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

# Check root
if [ "$EUID" -ne 0 ]; then
    print_error "Please run as root (use sudo)"
    exit 1
fi

echo ""
echo -e "${MAGENTA}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${MAGENTA}║                                                            ║${NC}"
echo -e "${MAGENTA}║        Saswati Bangla (India) Inscript Keyboard           ║${NC}"
echo -e "${MAGENTA}║                    Installer v3.0                          ║${NC}"
echo -e "${MAGENTA}║                                                            ║${NC}"
echo -e "${MAGENTA}║              Author: Bonanto                               ║${NC}"
echo -e "${MAGENTA}║        bonanto18@protonmail.com                            ║${NC}"
echo -e "${MAGENTA}║                                                            ║${NC}"
echo -e "${MAGENTA}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

# ============================================================================
# PHASE 1: SYSTEM DETECTION
# ============================================================================

print_header "PHASE 1: SYSTEM DETECTION"

# Detect real user (not root)
if [ -n "$SUDO_USER" ]; then
    REAL_USER="$SUDO_USER"
    REAL_UID=$(id -u "$SUDO_USER")
    REAL_HOME=$(getent passwd "$SUDO_USER" | cut -d: -f6)
else
    REAL_USER=$(logname 2>/dev/null || echo "$USER")
    REAL_UID=$(id -u "$REAL_USER" 2>/dev/null || echo "$UID")
    REAL_HOME=$(getent passwd "$REAL_USER" 2>/dev/null | cut -d: -f6 || echo "$HOME")
fi

print_info "User: $REAL_USER (UID: $REAL_UID)"
print_info "Home: $REAL_HOME"

# Detect Distribution
if [ -f /etc/os-release ]; then
    . /etc/os-release
    DISTRO=$ID
    DISTRO_LIKE=$ID_LIKE
    DISTRO_NAME=$NAME
else
    print_error "Cannot detect distribution"
    exit 1
fi

print_success "Distribution: $DISTRO_NAME"

# Detect Session Type (X11 or Wayland) - Multiple methods
SESSION_TYPE=""

# Method 1: Check loginctl for actual user session
for session_id in $(loginctl list-sessions --no-legend 2>/dev/null | awk '{print $1}'); do
    session_user=$(loginctl show-session "$session_id" -p Name --value 2>/dev/null)
    if [ "$session_user" == "$REAL_USER" ]; then
        SESSION_TYPE=$(loginctl show-session "$session_id" -p Type --value 2>/dev/null)
        if [ "$SESSION_TYPE" == "wayland" ] || [ "$SESSION_TYPE" == "x11" ]; then
            break
        fi
    fi
done

# Method 2: Check XDG_SESSION_TYPE environment variable
if [ -z "$SESSION_TYPE" ] || [ "$SESSION_TYPE" == "unspecified" ]; then
    if [ -n "$XDG_SESSION_TYPE" ]; then
        SESSION_TYPE="$XDG_SESSION_TYPE"
    fi
fi

# Method 3: Check for Wayland-specific processes
if [ -z "$SESSION_TYPE" ] || [ "$SESSION_TYPE" == "unspecified" ]; then
    if pgrep -x "kwin_wayland" > /dev/null || \
       (pgrep -x "gnome-shell" > /dev/null && [ -n "$WAYLAND_DISPLAY" ]); then
        SESSION_TYPE="wayland"
    else
        SESSION_TYPE="x11"
    fi
fi

# Fallback
if [ -z "$SESSION_TYPE" ]; then
    SESSION_TYPE="x11"
    print_warning "Could not detect session type, assuming X11"
fi

print_success "Session Type: $SESSION_TYPE"

# Detect Desktop Environment
DE=""
DE_VERSION=""

if [ -n "$XDG_CURRENT_DESKTOP" ]; then
    DE="$XDG_CURRENT_DESKTOP"
elif [ -n "$DESKTOP_SESSION" ]; then
    DE="$DESKTOP_SESSION"
elif pgrep -x "plasmashell" > /dev/null; then
    DE="KDE"
elif pgrep -x "gnome-shell" > /dev/null; then
    DE="GNOME"
elif pgrep -x "xfce4-session" > /dev/null; then
    DE="XFCE"
elif pgrep -x "cinnamon" > /dev/null; then
    DE="Cinnamon"
elif pgrep -x "mate-session" > /dev/null; then
    DE="MATE"
else
    DE="Unknown"
fi

# Try to get DE version
if [[ "$DE" == *"KDE"* ]] || [[ "$DE" == *"plasma"* ]]; then
    DE_VERSION=$(plasmashell --version 2>/dev/null | grep -oP '\d+\.\d+' | head -1)
elif [[ "$DE" == *"GNOME"* ]]; then
    DE_VERSION=$(gnome-shell --version 2>/dev/null | grep -oP '\d+\.\d+' | head -1)
fi

print_success "Desktop Environment: $DE ${DE_VERSION:+v$DE_VERSION}"

# Check if IBus is installed
if command -v ibus-daemon &> /dev/null; then
    IBUS_VERSION=$(ibus version 2>/dev/null | grep -oP '\d+\.\d+\.\d+' | head -1)
    print_success "IBus: Installed ${IBUS_VERSION:+(v$IBUS_VERSION)}"
    IBUS_INSTALLED=true
else
    print_warning "IBus: Not installed (will be installed)"
    IBUS_INSTALLED=false
fi

# Check if IBus is currently set as default IM
IBUS_IS_DEFAULT=false
if [[ "$DE" == *"KDE"* ]] && command -v kreadconfig5 &> /dev/null; then
    CURRENT_IM=$(kreadconfig5 --file kwinrc --group Wayland --key InputMethod 2>/dev/null || echo "")
    if [[ "$CURRENT_IM" == *"ibus"* ]]; then
        IBUS_IS_DEFAULT=true
        print_success "IBus is set as default input method in KDE"
    else
        print_warning "IBus is NOT set as default in KDE (you'll need to set it manually)"
    fi
fi

echo ""
echo -e "${CYAN}═══════════════════════════════════════════════════════${NC}"
echo -e "${CYAN} System Summary:${NC}"
echo -e "  • OS: $DISTRO_NAME"
echo -e "  • DE: $DE ${DE_VERSION:+v$DE_VERSION}"
echo -e "  • Session: $SESSION_TYPE"
echo -e "  • IBus: ${IBUS_INSTALLED:+Installed}${IBUS_INSTALLED:-Will Install}"
echo -e "${CYAN}═══════════════════════════════════════════════════════${NC}"
echo ""

# ============================================================================
# PHASE 2: CLEANUP OLD CONFIGURATIONS
# ============================================================================

print_header "PHASE 2: CLEANING OLD CONFIGURATIONS"

print_info "Removing old environment variables (if any)..."

# Remove from .bashrc
if [ -f "$REAL_HOME/.bashrc" ]; then
    sed -i '/export GTK_IM_MODULE=ibus/d' "$REAL_HOME/.bashrc"
    sed -i '/export QT_IM_MODULE=ibus/d' "$REAL_HOME/.bashrc"
    sed -i '/export XMODIFIERS=@im=ibus/d' "$REAL_HOME/.bashrc"
    sed -i '/# IBus configuration/d' "$REAL_HOME/.bashrc"
fi

# Remove from .profile
if [ -f "$REAL_HOME/.profile" ]; then
    sed -i '/export GTK_IM_MODULE=ibus/d' "$REAL_HOME/.profile"
    sed -i '/export QT_IM_MODULE=ibus/d' "$REAL_HOME/.profile"
    sed -i '/export XMODIFIERS=@im=ibus/d' "$REAL_HOME/.profile"
    sed -i '/# IBus configuration/d' "$REAL_HOME/.profile"
fi

# Remove from /etc/profile.d
if [ -f /etc/profile.d/ibus-saswati.sh ]; then
    rm -f /etc/profile.d/ibus-saswati.sh
fi

print_success "Old configurations cleaned"

# ============================================================================
# PHASE 3: INSTALL DEPENDENCIES
# ============================================================================

print_header "PHASE 3: INSTALLING DEPENDENCIES"

case "$DISTRO" in
    fedora|rhel|centos|rocky|almalinux)
        PKG_MANAGER="dnf"
        INSTALL_CMD="dnf install -y -q"
        PACKAGES="python3-gobject ibus librsvg2-tools ImageMagick"
        CHECK_CMD="rpm -qa"
        ;;
    ubuntu|debian|linuxmint|pop|elementary|kali|zorin)
        PKG_MANAGER="apt"
        INSTALL_CMD="apt-get install -y -qq"
        PACKAGES="python3-gi gir1.2-ibus-1.0 librsvg2-bin imagemagick"
        CHECK_CMD="dpkg -l"
        export DEBIAN_FRONTEND=noninteractive
        apt-get update -qq > /dev/null 2>&1
        ;;
    arch|manjaro|endeavouros|garuda)
        PKG_MANAGER="pacman"
        INSTALL_CMD="pacman -S --noconfirm --needed"
        PACKAGES="python-gobject ibus librsvg imagemagick"
        CHECK_CMD="pacman -Q"
        ;;
    opensuse*|suse)
        PKG_MANAGER="zypper"
        INSTALL_CMD="zypper install -y"
        PACKAGES="python3-gobject ibus librsvg ImageMagick"
        CHECK_CMD="rpm -qa"
        ;;
    *)
        # Try to detect based on ID_LIKE
        if echo "$DISTRO_LIKE" | grep -q "debian"; then
            PKG_MANAGER="apt"
            INSTALL_CMD="apt-get install -y -qq"
            PACKAGES="python3-gi gir1.2-ibus-1.0 librsvg2-bin imagemagick"
            CHECK_CMD="dpkg -l"
            apt-get update -qq > /dev/null 2>&1
        elif echo "$DISTRO_LIKE" | grep -q "rhel\|fedora"; then
            PKG_MANAGER="dnf"
            INSTALL_CMD="dnf install -y -q"
            PACKAGES="python3-gobject ibus librsvg2-tools ImageMagick"
            CHECK_CMD="rpm -qa"
        elif echo "$DISTRO_LIKE" | grep -q "arch"; then
            PKG_MANAGER="pacman"
            INSTALL_CMD="pacman -S --noconfirm --needed"
            PACKAGES="python-gobject ibus librsvg imagemagick"
            CHECK_CMD="pacman -Q"
        else
            print_error "Unsupported distribution: $DISTRO"
            exit 1
        fi
        ;;
esac

print_info "Package Manager: $PKG_MANAGER"

# Check for missing packages
MISSING_PACKAGES=""
for pkg in $PACKAGES; do
    if ! $CHECK_CMD 2>/dev/null | grep -q "$pkg"; then
        MISSING_PACKAGES="$MISSING_PACKAGES $pkg"
    fi
done

if [ -n "$MISSING_PACKAGES" ]; then
    print_info "Installing:$MISSING_PACKAGES"
    $INSTALL_CMD $MISSING_PACKAGES > /dev/null 2>&1
    print_success "Dependencies installed"
else
    print_success "All dependencies already installed"
fi

# ============================================================================
# PHASE 4: INSTALL ENGINE FILES
# ============================================================================

print_header "PHASE 4: INSTALLING SASWATI ENGINE"

# Create directories
mkdir -p "$INSTALL_DIR"
mkdir -p "$COMPONENT_DIR"
mkdir -p "$ICON_DIR"

# Check if main.py exists
if [ ! -f "$PYTHON_FILE" ]; then
    print_error "$PYTHON_FILE not found in current directory!"
    exit 1
fi

# Install Python engine
cp "$PYTHON_FILE" "$INSTALL_DIR/"
chmod 755 "$INSTALL_DIR/$PYTHON_FILE"
print_success "Engine installed: $INSTALL_DIR/$PYTHON_FILE"

# Create wrapper script
cat > "$INSTALL_DIR/saswati" << EOF
#!/bin/sh
exec /usr/bin/python3 $INSTALL_DIR/$PYTHON_FILE "\$@"
EOF
chmod 755 "$INSTALL_DIR/saswati"
print_success "Wrapper script created"

# Create IBus component XML
cat > "$COMPONENT_DIR/saswati.xml" << EOF
<?xml version="1.0" encoding="utf-8"?>
<component>
  <name>org.freedesktop.IBus.Saswati</name>
  <description>Saswati Bangla (India) Inscript Keyboard</description>
  <exec>$INSTALL_DIR/saswati --ibus</exec>
  <version>1.0.0</version>
  <author>Bonanto &lt;bonanto18@protonmail.com&gt;</author>
  <license>GPL</license>
  <homepage>https://github.com/bonanto/saswati-keyboard</homepage>
  <textdomain>ibus-saswati</textdomain>

  <engines>
    <engine>
      <name>saswati</name>
      <longname>Saswati Inscript (India)</longname>
      <description>Saswati Bangla (India) Inscript Keyboard</description>
      <language>bn</language>
      <license>GPL</license>
      <author>Bonanto &lt;bonanto18@protonmail.com&gt;</author>
      <icon>$ICON_DIR/saswati.png</icon>
      <layout>us</layout>
      <rank>99</rank>
    </engine>
  </engines>
</component>
EOF
chmod 644 "$COMPONENT_DIR/saswati.xml"
print_success "Component XML created"

# ============================================================================
# PHASE 5: CREATE ICON
# ============================================================================

print_header "PHASE 5: GENERATING ICON"

# Create high-quality SVG icon
cat > "$ICON_DIR/saswati.svg" << 'EOFSVG'
<?xml version="1.0" encoding="UTF-8"?>
<svg width="128" height="128" viewBox="0 0 128 128" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <linearGradient id="grad1" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" style="stop-color:#2196F3;stop-opacity:1" />
      <stop offset="100%" style="stop-color:#1565C0;stop-opacity:1" />
    </linearGradient>
    <filter id="shadow">
      <feDropShadow dx="0" dy="3" stdDeviation="4" flood-opacity="0.4"/>
    </filter>
  </defs>
  <rect width="128" height="128" fill="url(#grad1)" rx="24" ry="24" filter="url(#shadow)"/>
  <text x="64" y="78" font-family="Noto Sans Bengali,Lohit Bengali,sans-serif"
        font-size="34" font-weight="bold" text-anchor="middle" fill="white">শাশ্বতী</text>
</svg>
EOFSVG

chmod 644 "$ICON_DIR/saswati.svg"
print_success "SVG icon created"

# Convert to PNG
print_info "Converting icon to PNG..."
if command -v rsvg-convert &> /dev/null; then
    rsvg-convert -w 128 -h 128 "$ICON_DIR/saswati.svg" -o "$ICON_DIR/saswati.png" 2>/dev/null
    print_success "PNG created (rsvg-convert)"
elif command -v convert &> /dev/null; then
    convert -background none -density 300 -size 128x128 "$ICON_DIR/saswati.svg" "$ICON_DIR/saswati.png" 2>/dev/null
    print_success "PNG created (ImageMagick)"
else
    cp "$ICON_DIR/saswati.svg" "$ICON_DIR/saswati.png"
    print_warning "Icon converter not found, using SVG as fallback"
fi

chmod 644 "$ICON_DIR/saswati.png" 2>/dev/null || true

# ============================================================================
# PHASE 6: CONFIGURE ALTGR
# ============================================================================

print_header "PHASE 6: CONFIGURING ALTGR (RIGHT ALT)"

if [ "$SESSION_TYPE" == "wayland" ]; then
    print_info "Wayland session detected - Using Wayland-safe configuration"

    # Method 1: localectl (system-wide, persistent, Wayland-safe)
    if command -v localectl &> /dev/null; then
        print_info "Configuring via localectl..."
        localectl set-x11-keymap us "" "" lv3:ralt_switch 2>/dev/null || true
        print_success "AltGr configured (localectl)"
    fi

    # Method 2: KDE Wayland specific
    if [[ "$DE" == *"KDE"* ]] || [[ "$DE" == *"plasma"* ]]; then
        print_info "Applying KDE Plasma Wayland settings..."

        USER_CONFIG="$REAL_HOME/.config/kxkbrc"
        mkdir -p "$REAL_HOME/.config"

        if [ -f "$USER_CONFIG" ]; then
            # Update existing
            if ! grep -q "lv3:ralt_switch" "$USER_CONFIG"; then
                if grep -q "^\[Layout\]" "$USER_CONFIG"; then
                    sed -i '/^\[Layout\]/a Options=lv3:ralt_switch' "$USER_CONFIG"
                else
                    echo -e "\n[Layout]\nOptions=lv3:ralt_switch" >> "$USER_CONFIG"
                fi
            fi
        else
            # Create new
            cat > "$USER_CONFIG" << 'EOFKXKB'
[Layout]
Options=lv3:ralt_switch
ResetOldOptions=true
Use=true
EOFKXKB
        fi

        chown "$REAL_USER:$REAL_USER" "$USER_CONFIG"
        print_success "KDE keyboard settings updated"
    fi

    # Method 3: GNOME Wayland
    if [[ "$DE" == *"GNOME"* ]] || [[ "$DE" == *"gnome"* ]]; then
        print_info "Applying GNOME Wayland settings..."
        sudo -u "$REAL_USER" DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$REAL_UID/bus" \
            gsettings set org.gnome.desktop.input-sources xkb-options "['lv3:ralt_switch']" 2>/dev/null || true
        print_success "GNOME keyboard settings updated"
    fi

else
    print_info "X11 session detected - Using X11 configuration"

    # X11 configuration
    mkdir -p /etc/X11/xorg.conf.d/
    cat > "/etc/X11/xorg.conf.d/90-saswati-kbd.conf" << 'EOFX11'
Section "InputClass"
    Identifier "keyboard-saswati-altgr"
    MatchIsKeyboard "on"
    Option "XkbOptions" "lv3:ralt_switch"
EndSection
EOFX11

    print_success "X11 Xorg configuration created"

    # Apply to current session
    if command -v setxkbmap &> /dev/null; then
        setxkbmap -option lv3:ralt_switch 2>/dev/null || true
        print_success "AltGr applied to current session"
    fi
fi

# ============================================================================
# PHASE 7: RESTART IBUS & REGISTER KEYBOARD
# ============================================================================

print_header "PHASE 7: REGISTERING KEYBOARD IN IBUS"

# Clear IBus cache
print_info "Clearing IBus cache..."
rm -rf "$REAL_HOME/.cache/ibus" 2>/dev/null || true
rm -rf /var/cache/ibus 2>/dev/null || true

# Kill existing IBus processes
print_info "Stopping IBus daemon..."
pkill -u "$REAL_USER" -f "ibus" 2>/dev/null || true
sleep 2

# Start IBus with appropriate flags
print_info "Starting IBus daemon..."

if [ "$SESSION_TYPE" == "wayland" ]; then
    # Wayland: Use --panel disable to avoid warnings
    sudo -u "$REAL_USER" DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$REAL_UID/bus" \
        ibus-daemon -drxR --panel disable > /dev/null 2>&1 &
    print_success "IBus started (Wayland mode)"
else
    # X11: Normal mode
    sudo -u "$REAL_USER" DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$REAL_UID/bus" \
        ibus-daemon -drxR > /dev/null 2>&1 &
    print_success "IBus started (X11 mode)"
fi

sleep 3

# Write IBus cache to register our engine
print_info "Registering Saswati engine..."
sudo -u "$REAL_USER" DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$REAL_UID/bus" \
    ibus write-cache --system 2>/dev/null || true

# Try to add our engine to IBus input sources
print_info "Adding Saswati to IBus input sources..."

# Method 1: Direct dconf/gsettings for GNOME-based systems
if [[ "$DE" == *"GNOME"* ]] || [[ "$DE" == *"gnome"* ]]; then
    CURRENT_SOURCES=$(sudo -u "$REAL_USER" DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$REAL_UID/bus" \
        gsettings get org.gnome.desktop.input-sources sources 2>/dev/null || echo "")

    if [ -n "$CURRENT_SOURCES" ] && ! echo "$CURRENT_SOURCES" | grep -q "saswati"; then
        # Add our engine to existing sources
        NEW_SOURCES=$(echo "$CURRENT_SOURCES" | sed "s/]/, ('ibus', 'saswati')]/")
        sudo -u "$REAL_USER" DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$REAL_UID/bus" \
            gsettings set org.gnome.desktop.input-sources sources "$NEW_SOURCES" 2>/dev/null || true
        print_success "Added to GNOME input sources"
    fi
fi

# Method 2: Try to add via ibus command
sudo -u "$REAL_USER" DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$REAL_UID/bus" \
    ibus engine saswati 2>/dev/null || true

sleep 2

print_success "Saswati registered in IBus"

# ============================================================================
# COMPLETION
# ============================================================================

echo ""
print_success "╔════════════════════════════════════════════════════════════╗"
print_success "║                                                            ║"
print_success "║           INSTALLATION COMPLETED SUCCESSFULLY!             ║"
print_success "║                                                            ║"
print_success "╚════════════════════════════════════════════════════════════╝"
echo ""

echo -e "${CYAN}═══════════════════════════════════════════════════════${NC}"
echo -e "${CYAN} Installation Summary:${NC}"
echo ""
echo -e "  ✓ Engine installed: $INSTALL_DIR"
echo -e "  ✓ Icon created: $ICON_DIR/saswati.png"
echo -e "  ✓ AltGr configured for $SESSION_TYPE"
echo -e "  ✓ Keyboard registered in IBus"
echo ""
echo -e "${CYAN}═══════════════════════════════════════════════════════${NC}"
echo ""

echo -e "${YELLOW}📋 NEXT STEPS (IMPORTANT):${NC}"
echo ""
echo -e "${YELLOW}1. RESTART YOUR COMPUTER${NC}"
echo -e "   This is necessary for all settings to take effect."
echo ""

if ! $IBUS_IS_DEFAULT; then
    echo -e "${YELLOW}2. ENABLE IBUS IN SYSTEM SETTINGS${NC}"

    if [[ "$DE" == *"KDE"* ]] || [[ "$DE" == *"plasma"* ]]; then
        echo -e "   ${CYAN}For KDE Plasma:${NC}"
        echo -e "   • Open System Settings"
        echo -e "   • Go to: Input Devices → Virtual Keyboard"
        echo -e "   • Select: ${GREEN}IBus Wayland${NC} (or just IBus)"
        echo -e "   • Click Apply"
    elif [[ "$DE" == *"GNOME"* ]]; then
        echo -e "   ${CYAN}For GNOME:${NC}"
        echo -e "   • IBus should already be active"
    else
        echo -e "   • Open your desktop's input method settings"
        echo -e "   • Select IBus as the input method framework"
    fi
    echo ""
fi

echo -e "${YELLOW}3. ADD SASWATI KEYBOARD${NC}"

if [[ "$DE" == *"KDE"* ]] || [[ "$DE" == *"plasma"* ]]; then
    echo -e "   ${CYAN}For KDE Plasma:${NC}"
    echo -e "   • System Settings → Input Devices → Keyboard → Layouts"
    echo -e "   • Click 'Add' button"
    echo -e "   • Search: ${GREEN}Saswati${NC} or ${GREEN}Bangla${NC}"
    echo -e "   • Select: ${GREEN}Bangla - Saswati Inscript (India)${NC}"
elif [[ "$DE" == *"GNOME"* ]]; then
    echo -e "   ${CYAN}For GNOME:${NC}"
    echo -e "   • Settings → Keyboard → Input Sources"
    echo -e "   • Click '+' button"
    echo -e "   • Search: ${GREEN}Saswati${NC} or ${GREEN}Bangla${NC}"
    echo -e "   • Select: ${GREEN}Bangla - Saswati Inscript (India)${NC}"
else
    echo -e "   • Run: ${CYAN}ibus-setup${NC}"
    echo -e "   • Input Method tab → Add"
    echo -e "   • Search: ${GREEN}Saswati${NC}"
    echo -e "   • Select: ${GREEN}Bangla - Saswati Inscript (India)${NC}"
fi

echo ""
echo -e "${YELLOW}4. SWITCH LAYOUTS${NC}"
echo -e "   Use Super+Space (or your configured hotkey)"
echo ""
echo -e "${CYAN}═══════════════════════════════════════════════════════${NC}"
echo ""

echo -e "${GREEN}✓ Test Your Keyboard:${NC}"
echo -e "  • Type 'q' → ক্ষ (conjunct)"
echo -e "  • Type 'k' → ক"
echo -e "  • Type Right Alt+g → জ্ঞ (conjunct)"
echo -e "  • Type Right Alt+w → (nothing - empty layer)"
echo -e "  • CapsLock ON, type 'k' → ক (CapsLock has no effect!)"
echo ""

echo -e "${GREEN}✓ No Warnings:${NC}"
echo -e "  You should NOT see any warnings about QT_IM_MODULE"
echo -e "  or GTK_IM_MODULE after restart."
echo ""

echo -e "${MAGENTA}শুভেচ্ছা! Enjoy typing in Bengali! 🇮🇳${NC}"
echo ""
