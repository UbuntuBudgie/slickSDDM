# Keyboard Layout Configuration for SDDM

Complete guide to setting up multiple keyboard layouts in the slickSDDM theme.

## Overview

The keyboard layout selector allows users to switch between different keyboard layouts at the login screen. This is useful for:

- Multilingual users
- Users with different keyboard hardware
- International keyboards (AZERTY, QWERTZ, etc.)

## Quick Setup (Recommended Method)

```bash
# 1. Configure keyboard using system tool
sudo dpkg-reconfigure keyboard-configuration

# 2. Select your layouts when prompted

# 3. Restart SDDM
sudo systemctl restart sddm

# 4. Verify layouts appear in SDDM
# Log out and check the keyboard button
```

## Detailed Configuration

### Method 1: Using dpkg-reconfigure (Ubuntu/Debian)

This is the recommended method for Ubuntu Budgie:

```bash
sudo dpkg-reconfigure keyboard-configuration
```

You'll be prompted to select:

1. **Keyboard model** (usually "Generic 105-key PC" for standard keyboards)
2. **Country of origin** (select your primary keyboard layout)
3. **Keyboard layout** (confirm or change)
4. **Additional layouts** (add as many as needed)
5. **Key to switch layouts** (recommended: Alt+Shift)

Example selections:
- Model: Generic 105-key PC (intl.)
- Origin: English (US)
- Layout: English (US)
- Additional: Spanish, French, German
- Switch key: Alt+Shift

After configuration:
```bash
sudo systemctl restart sddm
```

### Method 2: Manual X11 Configuration

For more control, configure X11 directly:

```bash
# Create configuration directory
sudo mkdir -p /etc/X11/xorg.conf.d/

# Create keyboard configuration file
sudo nano /etc/X11/xorg.conf.d/00-keyboard.conf
```

Add the following content:

```
Section "InputClass"
    Identifier "system-keyboard"
    MatchIsKeyboard "on"
    
    # Layouts (comma-separated)
    # Order determines the default (first = default)
    Option "XkbLayout" "us,es,fr,de"
    
    # Variants for each layout (empty for default variant)
    Option "XkbVariant" ",,,nodeadkeys"
    
    # Model (optional)
    Option "XkbModel" "pc105"
    
    # Options for switching layouts
    # Alt+Shift switches layouts
    Option "XkbOptions" "grp:alt_shift_toggle"
EndSection
```

Save and restart SDDM:
```bash
sudo systemctl restart sddm
```

## Common Keyboard Layouts

### Basic Latin Layouts

```
Option "XkbLayout" "us,gb"  # US and UK English
```

### European Layouts

```
# Western Europe
Option "XkbLayout" "us,gb,fr,de,es,it,pt"

# Northern Europe
Option "XkbLayout" "us,dk,no,se,fi"

# Eastern Europe
Option "XkbLayout" "us,pl,cz,hu,ro"
```

### Specialized Layouts

```
# Programmer-friendly
Option "XkbLayout" "us"
Option "XkbVariant" "dvorak"

# German without dead keys
Option "XkbLayout" "de"
Option "XkbVariant" "nodeadkeys"

# Spanish (Latin America)
Option "XkbLayout" "latam"
```

## Layout Switch Options

Different ways to switch between layouts:

```
# Alt+Shift (recommended)
Option "XkbOptions" "grp:alt_shift_toggle"

# Caps Lock (use Caps Lock to switch)
Option "XkbOptions" "grp:caps_toggle"

# Right Alt (AltGr)
Option "XkbOptions" "grp:switch"

# Both Shift keys together
Option "XkbOptions" "grp:shifts_toggle"

# Ctrl+Shift
Option "XkbOptions" "grp:ctrl_shift_toggle"

# Ctrl+Alt
Option "XkbOptions" "grp:ctrl_alt_toggle"

# Menu key
Option "XkbOptions" "grp:menu_toggle"
```

## Complete Configuration Examples

### Example 1: Bilingual User (US/Spanish)

```
Section "InputClass"
    Identifier "system-keyboard"
    MatchIsKeyboard "on"
    Option "XkbLayout" "us,es"
    Option "XkbOptions" "grp:alt_shift_toggle"
EndSection
```

### Example 2: European Office (Multiple Languages)

```
Section "InputClass"
    Identifier "system-keyboard"
    MatchIsKeyboard "on"
    Option "XkbLayout" "us,gb,fr,de,es,it"
    Option "XkbVariant" ",,,,,"
    Option "XkbOptions" "grp:alt_shift_toggle,grp_led:scroll"
EndSection
```

The `grp_led:scroll` option makes the Scroll Lock LED indicate the current layout.

### Example 3: Programmer with Multiple Scripts

```
Section "InputClass"
    Identifier "system-keyboard"
    MatchIsKeyboard "on"
    Option "XkbLayout" "us,ru,ara,jp"
    Option "XkbOptions" "grp:alt_shift_toggle,grp_led:caps"
EndSection
```

## Keyboard Variants

Many layouts have variants. Common ones:

```
# English
us              # Standard US
us(dvorak)      # Dvorak
us(colemak)     # Colemak
us(intl)        # International with dead keys

# German
de              # Standard German (QWERTZ)
de(nodeadkeys)  # Without dead keys
de(neo)         # Neo layout

# French
fr              # Standard French (AZERTY)
fr(oss)         # Alternative French
fr(bepo)        # BÉPO layout

# Spanish
es              # Standard Spanish
es(cat)         # Catalan
latam           # Latin American
```

To use variants:

```
Option "XkbLayout" "us,de,fr"
Option "XkbVariant" ",nodeadkeys,bepo"
```

## Testing Your Configuration

### Check Current Settings

```bash
# View current keyboard configuration
setxkbmap -query

# Example output:
# rules:      evdev
# model:      pc105
# layout:     us,es,fr
# options:    grp:alt_shift_toggle
```

### Test Layout Switching

```bash
# Switch to next layout
setxkbmap -layout us,es -option grp:alt_shift_toggle

# Test by typing in terminal
# Press Alt+Shift to switch layouts
```

### View Available Layouts

```bash
# List all available layouts
localectl list-x11-keymap-layouts

# List variants for a layout
localectl list-x11-keymap-variants us
```

## Troubleshooting

### Problem: No keyboard layouts in SDDM

**Diagnosis:**
```bash
# Check if configuration file exists
cat /etc/X11/xorg.conf.d/00-keyboard.conf

# Check SDDM logs
journalctl -u sddm -b | grep -i keyboard
```

**Solution:**
```bash
# Reconfigure keyboard
sudo dpkg-reconfigure keyboard-configuration
sudo systemctl restart sddm
```

### Problem: Layouts configured but button doesn't appear

**Check theme configuration:**
```bash
grep -A2 "\[LoginScreen.MenuArea.Layout\]" /usr/share/sddm/themes/*/theme.conf
```

Ensure it shows:
```ini
[LoginScreen.MenuArea.Layout]
display = true
```

### Problem: Wrong layouts appear

**Reset configuration:**
```bash
# Remove existing configuration
sudo rm /etc/X11/xorg.conf.d/00-keyboard.conf

# Reconfigure from scratch
sudo dpkg-reconfigure keyboard-configuration
```

### Problem: Can't switch layouts with keyboard shortcut

**Test shortcut:**
```bash
# Try different switch option
sudo nano /etc/X11/xorg.conf.d/00-keyboard.conf

# Change to:
Option "XkbOptions" "grp:ctrl_shift_toggle"

# Restart SDDM
sudo systemctl restart sddm
```

### Problem: Keyboard doesn't work in SDDM at all

**Emergency fix (from TTY - Ctrl+Alt+F3):**
```bash
# Log in from TTY
# Remove custom configuration
sudo rm /etc/X11/xorg.conf.d/00-keyboard.conf

# Restart SDDM with defaults
sudo systemctl restart sddm
```

## Advanced: Per-User vs System-Wide

**System-wide (recommended for SDDM):**
- Configured in `/etc/X11/xorg.conf.d/`
- Affects all users and SDDM
- Persists across updates

**Per-user:**
- Configured in `~/.config/`
- Only affects logged-in sessions
- Does NOT affect SDDM login screen

For SDDM, always use system-wide configuration.

## Integration with Desktop Environment

After logging in, the desktop environment (Budgie) may have its own keyboard layout settings. To keep them in sync:

```bash
# Set keyboard layouts for Budgie
gsettings set org.gnome.desktop.input-sources sources "[('xkb', 'us'), ('xkb', 'es'), ('xkb', 'fr')]"

# Set layout switch shortcut
gsettings set org.gnome.desktop.wm.keybindings switch-input-source "['<Alt>Shift_L']"
```

## Additional Resources

- **List of Layout Codes**: `/usr/share/X11/xkb/rules/base.lst`
- **X Keyboard Extension**: `man xkeyboard-config`
- **SDDM Configuration**: `man sddm.conf`
- **Test Keyboard**: `xev` (shows key presses)

## Quick Reference

```bash
# View current layout
setxkbmap -query

# Test layout manually
setxkbmap -layout us,es -option grp:alt_shift_toggle

# List available layouts
localectl list-x11-keymap-layouts

# Configure keyboard (interactive)
sudo dpkg-reconfigure keyboard-configuration

# Restart SDDM
sudo systemctl restart sddm

# View SDDM logs
journalctl -u sddm -b
```

## Recommended Configurations

**For most users:**
```
Option "XkbLayout" "us,<your_language>"
Option "XkbOptions" "grp:alt_shift_toggle"
```

**For international offices:**
```
Option "XkbLayout" "us,gb,fr,de,es"
Option "XkbOptions" "grp:alt_shift_toggle,grp_led:scroll"
```

**For programmers:**
```
Option "XkbLayout" "us"
Option "XkbVariant" "dvorak"  # or "colemak"
```

---

For translation testing, see [TESTING_TRANSLATIONS.md](TESTING_TRANSLATIONS.md)