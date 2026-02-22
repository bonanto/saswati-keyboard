#!/usr/bin/env python3
# -*- coding: utf-8 -*-
#
# Saswati Bangla Input Method Engine
# Author: Bonanto <bonanto18@protonmail.com>
# License: GPL
# Version: 1.0.0

import gi
gi.require_version('IBus', '1.0')
from gi.repository import IBus
from gi.repository import GLib
from gi.repository import GObject
import sys
import subprocess

# Key mapping dictionary
# Format: (keyval, state) -> output_text
# IMPORTANT: If a key+modifier combination is not in this dict, it will pass through
# This prevents empty AltGr layers from outputting base characters

KEY_MAP = {
    # ========== NORMAL KEYS (NO MODIFIERS) ==========
    (IBus.KEY_q, 0): "ক্ষ",
    (IBus.KEY_w, 0): "ঙ",
    (IBus.KEY_e, 0): "ে",
    (IBus.KEY_r, 0): "র",
    (IBus.KEY_t, 0): "ট",
    (IBus.KEY_y, 0): "য",
    (IBus.KEY_u, 0): "ু",
    (IBus.KEY_i, 0): "ি",
    (IBus.KEY_o, 0): "ো",
    (IBus.KEY_p, 0): "প",
    (IBus.KEY_a, 0): "া",
    (IBus.KEY_s, 0): "স",
    (IBus.KEY_d, 0): "ড",
    (IBus.KEY_f, 0): "ফ",
    (IBus.KEY_g, 0): "গ",
    (IBus.KEY_h, 0): "হ",
    (IBus.KEY_j, 0): "জ",
    (IBus.KEY_k, 0): "ক",
    (IBus.KEY_l, 0): "ল",
    (IBus.KEY_z, 0): "ৃ",
    (IBus.KEY_x, 0): "ত",
    (IBus.KEY_c, 0): "চ",
    (IBus.KEY_v, 0): "দ",
    (IBus.KEY_b, 0): "ব",
    (IBus.KEY_n, 0): "ন",
    (IBus.KEY_m, 0): "ম",

    # ========== SHIFT + KEYS ==========
    (IBus.KEY_Q, IBus.ModifierType.SHIFT_MASK): "ক্ষ",
    (IBus.KEY_W, IBus.ModifierType.SHIFT_MASK): "ঞ",
    (IBus.KEY_E, IBus.ModifierType.SHIFT_MASK): "ৈ",
    (IBus.KEY_R, IBus.ModifierType.SHIFT_MASK): "ড়",
    (IBus.KEY_T, IBus.ModifierType.SHIFT_MASK): "ঠ",
    (IBus.KEY_Y, IBus.ModifierType.SHIFT_MASK): "য়",
    (IBus.KEY_U, IBus.ModifierType.SHIFT_MASK): "ূ",
    (IBus.KEY_I, IBus.ModifierType.SHIFT_MASK): "ী",
    (IBus.KEY_O, IBus.ModifierType.SHIFT_MASK): "ৌ",
    (IBus.KEY_P, IBus.ModifierType.SHIFT_MASK): "ফ",
    (IBus.KEY_A, IBus.ModifierType.SHIFT_MASK): "অ",
    (IBus.KEY_S, IBus.ModifierType.SHIFT_MASK): "শ",
    (IBus.KEY_D, IBus.ModifierType.SHIFT_MASK): "ঢ",
    (IBus.KEY_F, IBus.ModifierType.SHIFT_MASK): "়",
    (IBus.KEY_G, IBus.ModifierType.SHIFT_MASK): "ঘ",
    (IBus.KEY_H, IBus.ModifierType.SHIFT_MASK): "ঽ",
    (IBus.KEY_J, IBus.ModifierType.SHIFT_MASK): "ঝ",
    (IBus.KEY_K, IBus.ModifierType.SHIFT_MASK): "খ",
    (IBus.KEY_L, IBus.ModifierType.SHIFT_MASK): "ঌ",
    (IBus.KEY_Z, IBus.ModifierType.SHIFT_MASK): "ঁ",
    (IBus.KEY_X, IBus.ModifierType.SHIFT_MASK): "থ",
    (IBus.KEY_C, IBus.ModifierType.SHIFT_MASK): "ছ",
    (IBus.KEY_V, IBus.ModifierType.SHIFT_MASK): "ধ",
    (IBus.KEY_B, IBus.ModifierType.SHIFT_MASK): "ভ",
    (IBus.KEY_N, IBus.ModifierType.SHIFT_MASK): "ণ",
    (IBus.KEY_M, IBus.ModifierType.SHIFT_MASK): "ং",

    # ========== ALTGR + KEYS (MOD5_MASK) ==========
    (IBus.KEY_e, IBus.ModifierType.MOD5_MASK): "এ",
    (IBus.KEY_r, IBus.ModifierType.MOD5_MASK): "ঢ়",
    (IBus.KEY_t, IBus.ModifierType.MOD5_MASK): "ৎ",
    (IBus.KEY_y, IBus.ModifierType.MOD5_MASK): "্য",
    (IBus.KEY_u, IBus.ModifierType.MOD5_MASK): "উ",
    (IBus.KEY_i, IBus.ModifierType.MOD5_MASK): "ই",
    (IBus.KEY_o, IBus.ModifierType.MOD5_MASK): "ও",
    (IBus.KEY_a, IBus.ModifierType.MOD5_MASK): "আ",
    (IBus.KEY_s, IBus.ModifierType.MOD5_MASK): "ষ",
    (IBus.KEY_d, IBus.ModifierType.MOD5_MASK): "ড্ড",
    (IBus.KEY_f, IBus.ModifierType.MOD5_MASK): "ঀ",
    (IBus.KEY_g, IBus.ModifierType.MOD5_MASK): "জ্ঞ",
    (IBus.KEY_j, IBus.ModifierType.MOD5_MASK): "জ়",
    (IBus.KEY_k, IBus.ModifierType.MOD5_MASK): "ক্ক",
    (IBus.KEY_l, IBus.ModifierType.MOD5_MASK): "ৡ",
    (IBus.KEY_z, IBus.ModifierType.MOD5_MASK): "ঃ",
    (IBus.KEY_x, IBus.ModifierType.MOD5_MASK): "৺",
    (IBus.KEY_c, IBus.ModifierType.MOD5_MASK): "ঞ্চ",
    (IBus.KEY_v, IBus.ModifierType.MOD5_MASK): "দ্ধ",
    (IBus.KEY_b, IBus.ModifierType.MOD5_MASK): "ৱ",
    (IBus.KEY_n, IBus.ModifierType.MOD5_MASK): "ষ্ণ",

    # ========== ALTGR + SHIFT + KEYS ==========
    (IBus.KEY_W, IBus.ModifierType.MOD5_MASK | IBus.ModifierType.SHIFT_MASK): "ॐ",
    (IBus.KEY_E, IBus.ModifierType.MOD5_MASK | IBus.ModifierType.SHIFT_MASK): "ঐ",
    (IBus.KEY_R, IBus.ModifierType.MOD5_MASK | IBus.ModifierType.SHIFT_MASK): "ঋ",
    (IBus.KEY_T, IBus.ModifierType.MOD5_MASK | IBus.ModifierType.SHIFT_MASK): "৳",
    (IBus.KEY_Y, IBus.ModifierType.MOD5_MASK | IBus.ModifierType.SHIFT_MASK): "ৗ",
    (IBus.KEY_U, IBus.ModifierType.MOD5_MASK | IBus.ModifierType.SHIFT_MASK): "ঊ",
    (IBus.KEY_I, IBus.ModifierType.MOD5_MASK | IBus.ModifierType.SHIFT_MASK): "ঈ",
    (IBus.KEY_O, IBus.ModifierType.MOD5_MASK | IBus.ModifierType.SHIFT_MASK): "ঔ",
    (IBus.KEY_H, IBus.ModifierType.MOD5_MASK | IBus.ModifierType.SHIFT_MASK): "৾",
    (IBus.KEY_J, IBus.ModifierType.MOD5_MASK | IBus.ModifierType.SHIFT_MASK): "ঞ্জ",
    (IBus.KEY_L, IBus.ModifierType.MOD5_MASK | IBus.ModifierType.SHIFT_MASK): "ৢ",
    (IBus.KEY_Z, IBus.ModifierType.MOD5_MASK | IBus.ModifierType.SHIFT_MASK): "ৄ",
    (IBus.KEY_B, IBus.ModifierType.MOD5_MASK | IBus.ModifierType.SHIFT_MASK): "ৰ",
    (IBus.KEY_N, IBus.ModifierType.MOD5_MASK | IBus.ModifierType.SHIFT_MASK): "ৣ",
    (IBus.KEY_M, IBus.ModifierType.MOD5_MASK | IBus.ModifierType.SHIFT_MASK): "ৼ",

    # ========== NUMBERS (BENGALI) ==========
    (IBus.KEY_1, 0): "১",
    (IBus.KEY_2, 0): "২",
    (IBus.KEY_3, 0): "৩",
    (IBus.KEY_4, 0): "৪",
    (IBus.KEY_5, 0): "৫",
    (IBus.KEY_6, 0): "৬",
    (IBus.KEY_7, 0): "৭",
    (IBus.KEY_8, 0): "৮",
    (IBus.KEY_9, 0): "৯",
    (IBus.KEY_0, 0): "০",

    # ========== SPECIAL CHARACTERS ==========
    (IBus.KEY_grave, 0): "্",
    (IBus.KEY_asciitilde, IBus.ModifierType.SHIFT_MASK): "‌",
    (IBus.KEY_grave, IBus.ModifierType.MOD5_MASK): "~",
    (IBus.KEY_asciitilde, IBus.ModifierType.MOD5_MASK | IBus.ModifierType.SHIFT_MASK): "‍",
    (IBus.KEY_period, 0): "।",
    (IBus.KEY_greater, IBus.ModifierType.MOD5_MASK | IBus.ModifierType.SHIFT_MASK): "॥",

    # ========== SHIFTED SPECIAL CHARACTERS ==========
    (IBus.KEY_dollar, IBus.ModifierType.SHIFT_MASK): "₹",

    # ========== ALTGR + NUMBERS ==========
    (IBus.KEY_1, IBus.ModifierType.MOD5_MASK): "৴",
    (IBus.KEY_2, IBus.ModifierType.MOD5_MASK): "৵",
    (IBus.KEY_3, IBus.ModifierType.MOD5_MASK): "৶",
    (IBus.KEY_4, IBus.ModifierType.MOD5_MASK): "$",
    (IBus.KEY_5, IBus.ModifierType.MOD5_MASK): "৸",
    (IBus.KEY_6, IBus.ModifierType.MOD5_MASK): "৹",
    (IBus.KEY_7, IBus.ModifierType.MOD5_MASK): "৲",
    (IBus.KEY_8, IBus.ModifierType.MOD5_MASK): "৻",

    # ========== ALTGR + SHIFT + SPECIAL ==========
    (IBus.KEY_dollar, IBus.ModifierType.MOD5_MASK | IBus.ModifierType.SHIFT_MASK): "৷",
    (IBus.KEY_quotedbl, IBus.ModifierType.MOD5_MASK | IBus.ModifierType.SHIFT_MASK): "৽",
}


class SaswatiEngine(IBus.Engine):
    __gtype_name__ = 'SaswatiEngine'

    def __init__(self):
        super(SaswatiEngine, self).__init__()
        self.is_invalidate = False
        self.preedit_string = ""
        self._altgr_timer = None

    def _apply_altgr_fix(self):
        """Apply AltGr fix - called on focus and with delay"""
        try:
            # Method 1: setxkbmap (works for most systems)
            subprocess.run(['setxkbmap', '-option', 'lv3:ralt_switch'],
                         stdout=subprocess.DEVNULL,
                         stderr=subprocess.DEVNULL,
                         timeout=2)
        except:
            pass

        try:
            # Method 2: xmodmap as fallback (older systems)
            subprocess.run(['xmodmap', '-e', 'keycode 108 = ISO_Level3_Shift'],
                         stdout=subprocess.DEVNULL,
                         stderr=subprocess.DEVNULL,
                         timeout=2)
        except:
            pass

        return False  # Don't repeat timer

    def _schedule_altgr_fix(self):
        """Schedule AltGr fix with slight delay to override system changes"""
        # Cancel existing timer if any
        if self._altgr_timer:
            GLib.source_remove(self._altgr_timer)

        # Apply immediately
        self._apply_altgr_fix()

        # Schedule for 500ms later (after system might reset it)
        self._altgr_timer = GLib.timeout_add(500, self._apply_altgr_fix)

        # And once more at 1000ms
        GLib.timeout_add(1000, self._apply_altgr_fix)

    def do_process_key_event(self, keyval, keycode, state):
        """Process key press events"""

        # Ignore key release events
        if state & IBus.ModifierType.RELEASE_MASK:
            return False

        # Remove CapsLock and NumLock from state
        state = state & ~IBus.ModifierType.LOCK_MASK
        state = state & ~IBus.ModifierType.MOD2_MASK

        # Hardware Shift validation to bypass display server (Wayland/X11) LOCK_MASK inconsistencies
        # This handles CapsLock by normalizing keyval based on actual Shift state
        is_shift = bool(state & IBus.ModifierType.SHIFT_MASK)
        if is_shift:
            # Shift is pressed: ensure keyval is uppercase
            if IBus.KEY_a <= keyval <= IBus.KEY_z:
                keyval -= 32  # Convert to uppercase
        else:
            # Shift is NOT pressed: ensure keyval is lowercase
            if IBus.KEY_A <= keyval <= IBus.KEY_Z:
                keyval += 32  # Convert to lowercase

        # Normalize state to relevant modifiers only
        relevant_state = state & (
            IBus.ModifierType.SHIFT_MASK |
            IBus.ModifierType.CONTROL_MASK |
            IBus.ModifierType.MOD1_MASK |
            IBus.ModifierType.MOD5_MASK
        )

        # Don't process Ctrl combinations (let system shortcuts work)
        if (relevant_state & IBus.ModifierType.CONTROL_MASK):
            return False

        # Don't process Alt combinations (let system shortcuts work)
        if (relevant_state & IBus.ModifierType.MOD1_MASK) and \
           not (relevant_state & IBus.ModifierType.MOD5_MASK):
            return False

        # Try to find exact mapping
        key_combo = (keyval, relevant_state)
        output = KEY_MAP.get(key_combo)

        if output:
            self.commit_text(IBus.Text.new_from_string(output))
            return True

        # If AltGr is pressed but no mapping found, block the key
        # This prevents AltGr+w from typing the base character
        if relevant_state & IBus.ModifierType.MOD5_MASK:
            return True  # Consume the key, output nothing

        # Let other keys pass through
        return False

    def do_focus_in(self):
        """Called when this input method gains focus"""
        # Re-apply AltGr configuration when switching to this keyboard
        # This fixes the issue on GNOME/Cinnamon/Mint where AltGr gets reset
        self._schedule_altgr_fix()
        self.register_properties(IBus.PropList())

    def do_focus_out(self):
        """Called when this input method loses focus"""
        # Cancel any pending timers
        if self._altgr_timer:
            GLib.source_remove(self._altgr_timer)
            self._altgr_timer = None

    def do_reset(self):
        """Called when input context is reset"""
        self.preedit_string = ""

    def do_enable(self):
        """Called when this input method is enabled"""
        # Apply AltGr fix when keyboard is first enabled
        self._schedule_altgr_fix()

    def do_disable(self):
        """Called when this input method is disabled"""
        # Clean up timers
        if self._altgr_timer:
            GLib.source_remove(self._altgr_timer)
            self._altgr_timer = None


class IMApp:
    def __init__(self, exec_by_ibus):
        self.__mainloop = GLib.MainLoop()
        self.__bus = IBus.Bus()
        self.__bus.connect("disconnected", self.__bus_disconnected_cb)
        self.__factory = IBus.Factory.new(self.__bus.get_connection())
        self.__factory.add_engine("saswati",
                                    GObject.GType.from_name("SaswatiEngine"))

        if exec_by_ibus:
            self.__bus.request_name("org.freedesktop.IBus.Saswati", 0)
        else:
            self.__component = IBus.Component.new(
                "org.freedesktop.IBus.Saswati",
                "Saswati Bangla (India) Inscript Keyboard",
                "1.0.2",
                "GPL",
                "Bonanto <bonanto18@protonmail.com>",
                "https://github.com/bonanto/saswati-keyboard",
                "/usr/share/ibus-saswati/saswati",
                "ibus-saswati"
            )
            engine = IBus.EngineDesc.new(
                "saswati",
                "Saswati Inscript (India)",
                "Saswati Bangla (India) Inscript Keyboard",
                "bn",
                "GPL",
                "Bonanto <bonanto18@protonmail.com>",
                "/usr/share/ibus-saswati/icons/saswati.png",
                "us"
            )
            self.__component.add_engine(engine)
            self.__bus.register_component(self.__component)

    def run(self):
        self.__mainloop.run()

    def __bus_disconnected_cb(self, bus):
        self.__mainloop.quit()


def main():
    IBus.init()
    exec_by_ibus = False
    if "--ibus" in sys.argv:
        exec_by_ibus = True

    IMApp(exec_by_ibus).run()


if __name__ == "__main__":
    main()
