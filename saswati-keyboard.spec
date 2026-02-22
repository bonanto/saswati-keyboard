Name:           saswati-keyboard
Version:        1.0.0
Release:        1%{?dist}
Summary:        Saswati Bangla (India) Inscript Keyboard
BuildArch:      noarch
License:        GPLv3
URL:            https://github.com/bonanto/saswati-keyboard
Source0:        saswati-1.0.0.tar.gz

# Fedora-specific dependencies
Requires:       python3-gobject, ibus, librsvg2-tools, ImageMagick, bash

%description
A comprehensive Bengali Inscript keyboard layout for Linux using the IBus framework.
Includes assertive AltGr logic for maximum cross-distro compatibility.

%prep
%setup -q -n saswati-1.0.0

%install
# Create the necessary directories inside the RPM build root
mkdir -p %{buildroot}/usr/share/ibus-saswati/icons
mkdir -p %{buildroot}/usr/share/ibus/component

# Install files from the source tarball
install -m 644 saswati.xml %{buildroot}/usr/share/ibus/component/
install -m 755 main.py %{buildroot}/usr/share/ibus-saswati/main.py
install -m 755 saswati %{buildroot}/usr/share/ibus-saswati/saswati
cp -r icons/* %{buildroot}/usr/share/ibus-saswati/icons/

%post
# This script runs automatically AFTER the files are installed
echo "Running Saswati post-installation setup..."

# Clean old configs
rm -f /etc/profile.d/ibus-saswati.sh

# X11 Configuration
mkdir -p /etc/X11/xorg.conf.d/
cat > /etc/X11/xorg.conf.d/90-saswati-kbd.conf << 'EOFX11'
Section "InputClass"
    Identifier "keyboard-saswati-altgr"
    MatchIsKeyboard "on"
    Option "XkbOptions" "lv3:ralt_switch"
EndSection
EOFX11

# Wayland Configuration
if command -v localectl > /dev/null 2>&1; then
    localectl set-x11-keymap us "" "" lv3:ralt_switch 2>/dev/null || true
fi

# IBus System Cache
if command -v ibus > /dev/null 2>&1; then
    ibus write-cache --system 2>/dev/null || true
fi
rm -rf /var/cache/ibus 2>/dev/null || true

# Iterate through real users to set Wayland kxkbrc and GNOME settings
for user_home in /home/*; do
    if [ -d "$user_home" ]; then
        username=$(basename "$user_home")
        user_uid=$(id -u "$username" 2>/dev/null || echo 0)

        if [ "$user_uid" -ge 1000 ]; then
            # Clean bashrc/profile
            sed -i '/export GTK_IM_MODULE=ibus/d' "$user_home/.bashrc" 2>/dev/null || true
            sed -i '/export QT_IM_MODULE=ibus/d' "$user_home/.bashrc" 2>/dev/null || true
            sed -i '/export XMODIFIERS=@im=ibus/d' "$user_home/.bashrc" 2>/dev/null || true

            sed -i '/export GTK_IM_MODULE=ibus/d' "$user_home/.profile" 2>/dev/null || true
            sed -i '/export QT_IM_MODULE=ibus/d' "$user_home/.profile" 2>/dev/null || true
            sed -i '/export XMODIFIERS=@im=ibus/d' "$user_home/.profile" 2>/dev/null || true

            # KDE Wayland
            USER_CONFIG="$user_home/.config/kxkbrc"
            if [ -d "$user_home/.config" ]; then
                if [ -f "$USER_CONFIG" ]; then
                    if ! grep -q "lv3:ralt_switch" "$USER_CONFIG"; then
                        if grep -q "^\[Layout\]" "$USER_CONFIG"; then
                            sed -i '/^\[Layout\]/a Options=lv3:ralt_switch' "$USER_CONFIG"
                        else
                            echo -e "\n[Layout]\nOptions=lv3:ralt_switch" >> "$USER_CONFIG"
                        fi
                    fi
                else
                    cat > "$USER_CONFIG" << 'EOFKXKB'
[Layout]
Options=lv3:ralt_switch
ResetOldOptions=true
Use=true
EOFKXKB
                    chown "$username:$username" "$USER_CONFIG"
                fi
            fi

            # Layer 2 & 3: GNOME/Cinnamon Aggressive Fixes (Autostart & dconf)
            AUTOSTART_DIR="$user_home/.config/autostart"
            mkdir -p "$AUTOSTART_DIR"
            cat > "$AUTOSTART_DIR/saswati-config.desktop" << 'EOFCONFIG'
[Desktop Entry]
Type=Application
Name=Saswati Keyboard Configuration
Exec=sh -c "sleep 3 && setxkbmap -option lv3:ralt_switch && gsettings set org.gnome.desktop.wm.keybindings switch-input-source '[]' && gsettings set org.gnome.desktop.wm.keybindings switch-input-source-backward '[]'"
Icon=input-keyboard
Comment=Ensure AltGr and shortcuts work for Saswati keyboard
X-GNOME-Autostart-enabled=true
NoDisplay=true
EOFCONFIG
            chown "$username:$username" "$AUTOSTART_DIR/saswati-config.desktop"
            chmod 644 "$AUTOSTART_DIR/saswati-config.desktop"

            # GNOME Wayland/X11 Settings
            sudo -u "$username" DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$user_uid/bus" \
                gsettings set org.gnome.desktop.input-sources xkb-options "['lv3:ralt_switch']" 2>/dev/null || true
            sudo -u "$username" DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$user_uid/bus" \
                dconf write /org/gnome/desktop/input-sources/xkb-options "['lv3:ralt_switch']" 2>/dev/null || true

            rm -rf "$user_home/.cache/ibus" 2>/dev/null || true
        fi
    fi
done

echo "======================================================================"
echo " Saswati Keyboard installed successfully!                             "
echo " IMPORTANT: Please RESTART your computer or log out and log back in.  "
echo "======================================================================"

%files
%defattr(-,root,root,-)
/usr/share/ibus/component/saswati.xml
/usr/share/ibus-saswati/main.py
/usr/share/ibus-saswati/saswati
/usr/share/ibus-saswati/icons/*

%changelog
* Sun Feb 22 2026 Bonanto <bonanto18@protonmail.com> - 1.0.0-1
- Initial release of Saswati Keyboard for Linux
- Ported from the original Rabiraag Windows engine
- Full support for IBus and AltGr on X11 and Wayland
- Added 3-Layer Defense for Cinnamon/GNOME DEs
