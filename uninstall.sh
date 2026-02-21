#!/bin/bash

# ============================================================================
# Saswati Bangla Uninstaller
# Author: Bonanto <bonanto18@protonmail.com>
# Version: 1.0
# ============================================================================

set -e

INSTALL_DIR="/usr/share/ibus-saswati"
COMPONENT_DIR="/usr/share/ibus/component"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

print_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
print_success() { echo -e "${GREEN}[✓]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[!]${NC} $1"; }
print_error() { echo -e "${RED}[✗]${NC} $1"; }

if [ "$EUID" -ne 0 ]; then
    print_error "Please run as root (use sudo)"
    exit 1
fi

echo ""
echo -e "${YELLOW}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${YELLOW}║                                                            ║${NC}"
echo -e "${YELLOW}║         Saswati Bangla Keyboard Uninstaller               ║${NC}"
echo -e "${YELLOW}║                                                            ║${NC}"
echo -e "${YELLOW}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

print_warning "This will remove the Saswati Bengali keyboard layout."
echo ""
read -p "Are you sure you want to continue? (y/N) " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    print_info "Uninstallation cancelled."
    exit 0
fi

echo ""
print_info "Starting uninstallation..."
echo ""

# Detect real user
if [ -n "$SUDO_USER" ]; then
    REAL_USER="$SUDO_USER"
    REAL_UID=$(id -u "$SUDO_USER")
    REAL_HOME=$(getent passwd "$SUDO_USER" | cut -d: -f6)
else
    REAL_USER=$(logname 2>/dev/null || echo "$USER")
    REAL_UID=$(id -u "$REAL_USER" 2>/dev/null || echo "$UID")
    REAL_HOME=$(getent passwd "$REAL_USER" 2>/dev/null | cut -d: -f6 || echo "$HOME")
fi

# Detect session type
SESSION_TYPE=""
for session_id in $(loginctl list-sessions --no-legend 2>/dev/null | awk '{print $1}'); do
    session_user=$(loginctl show-session "$session_id" -p Name --value 2>/dev/null)
    if [ "$session_user" == "$REAL_USER" ]; then
        SESSION_TYPE=$(loginctl show-session "$session_id" -p Type --value 2>/dev/null)
        break
    fi
done

if [ -z "$SESSION_TYPE" ]; then
    SESSION_TYPE="x11"
fi

# Stop IBus
print_info "Stopping IBus daemon..."
pkill -u "$REAL_USER" -f "ibus" 2>/dev/null || true
sleep 2
print_success "IBus stopped"

# Remove files
print_info "Removing Saswati files..."

if [ -d "$INSTALL_DIR" ]; then
    rm -rf "$INSTALL_DIR"
    print_success "Removed: $INSTALL_DIR"
fi

if [ -f "$COMPONENT_DIR/saswati.xml" ]; then
    rm -f "$COMPONENT_DIR/saswati.xml"
    print_success "Removed: $COMPONENT_DIR/saswati.xml"
fi

# Remove X11 config
if [ -f "/etc/X11/xorg.conf.d/90-saswati-kbd.conf" ]; then
    rm -f "/etc/X11/xorg.conf.d/90-saswati-kbd.conf"
    print_success "Removed X11 configuration"
fi

# Clear IBus cache
print_info "Clearing IBus cache..."
rm -rf "$REAL_HOME/.cache/ibus" 2>/dev/null || true
rm -rf /var/cache/ibus 2>/dev/null || true
print_success "Cache cleared"

# Restart IBus
print_info "Restarting IBus daemon..."

if [ "$SESSION_TYPE" == "wayland" ]; then
    sudo -u "$REAL_USER" DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$REAL_UID/bus" \
        ibus-daemon -drxR --panel disable > /dev/null 2>&1 &
else
    sudo -u "$REAL_USER" DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$REAL_UID/bus" \
        ibus-daemon -drxR > /dev/null 2>&1 &
fi

sleep 2
print_success "IBus restarted"

echo ""
echo -e "${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║                                                            ║${NC}"
echo -e "${GREEN}║          Uninstallation Completed Successfully!           ║${NC}"
echo -e "${GREEN}║                                                            ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

echo -e "${CYAN}═══════════════════════════════════════════════════════${NC}"
echo -e "${CYAN} Next Steps:${NC}"
echo ""
echo "  1. Remove 'Saswati' from your keyboard layouts:"
echo ""
echo "     ${YELLOW}KDE Plasma:${NC}"
echo "     System Settings → Keyboard → Layouts"
echo "     Select Saswati and click 'Remove'"
echo ""
echo "     ${YELLOW}GNOME:${NC}"
echo "     Settings → Keyboard → Input Sources"
echo "     Select Saswati and click '-' button"
echo ""
echo "     ${YELLOW}Other DE:${NC}"
echo "     Run: ibus-setup"
echo "     Input Method tab → Remove Saswati"
echo ""
echo "  2. Log out and log back in (or restart)"
echo ""
echo -e "${CYAN}═══════════════════════════════════════════════════════${NC}"
echo ""
print_info "The Saswati keyboard has been removed from your system."
echo ""
