# Testing Translations - Complete Guide

This guide explains how to test the SDDM theme with different locales and configure keyboard layouts.

## Prerequisites

- Ubuntu Budgie system with SDDM installed
- Root/sudo access
- Theme installed at `/usr/share/sddm/themes/ubuntu-budgie-login/`

## Part 1: Testing Different Locales

### Understanding Locale Detection

SDDM uses the system locale to determine which language to display. The locale is determined by:

1. `/etc/default/locale` - System-wide default
2. User's locale settings (not relevant for login screen)
3. SDDM configuration override (optional)

### Method 1: Change System Locale (Recommended for Testing)

This changes the locale for the entire system, including SDDM:

```bash
# Install language packs for testing
sudo apt-get install language-pack-es language-pack-fr language-pack-de

# Check available locales
locale -a

# Generate locales if needed
sudo locale-gen es_ES.UTF-8
sudo locale-gen fr_FR.UTF-8
sudo locale-gen de_DE.UTF-8
sudo update-locale

# Set system locale (choose one)
# Spanish
sudo update-locale LANG=es_ES.UTF-8 LANGUAGE=es_ES

# French  
sudo update-locale LANG=fr_FR.UTF-8 LANGUAGE=fr_FR

# German
sudo update-locale LANG=de_DE.UTF-8 LANGUAGE=de_DE

# Reboot to apply changes
sudo reboot
```

After reboot, SDDM will display in the selected language.

### Method 2: Override in SDDM Configuration (Testing Only)

For quick testing without changing system locale:

```bash
# Edit SDDM configuration
sudo nano /etc/sddm.conf.d/theme.conf

# Add or modify:
[General]
Locale=es_ES.UTF-8

# Restart SDDM
sudo systemctl restart sddm
```

**Note:** This only affects SDDM, not the rest of the system.

### Method 3: Test in Virtual Machine

The cleanest way to test multiple locales:

```bash
# Install Ubuntu Budgie in VM
# During installation, select the language to test
# Install theme and verify translations appear
```

### Switching Back to English

```bash
sudo update-locale LANG=en_GB.UTF-8 LANGUAGE=en_GB
sudo reboot
```

Or for US English:
```bash
sudo update-locale LANG=en_US.UTF-8 LANGUAGE=en_US
sudo reboot
```

## Part 2: Configuring Keyboard Layouts

### Understanding Keyboard Layout Button

The keyboard layout button allows users to switch between different keyboard layouts (e.g., QWERTY US, AZERTY French, QWERTZ German) during login.

**This feature works on both X11 and Wayland sessions** - SDDM itself always runs on X11/XWayland.

### Configure Multiple Keyboard Layouts

1. **Edit SDDM configuration:**

```bash
sudo nano /etc/sddm.conf
```

2. **Add keyboard layouts:**

```ini
[General]
# Enable keyboard layouts
InputMethod=

# This section is often auto-configured, but verify:
[X11]
# Multiple layouts separated by commas
# Format: layout(variant)
ServerArguments=-nolisten tcp -dpi 96

# Alternative location for some systems:
# Create or edit /etc/sddm.conf.d/keyboard.conf
```

3. **Using dpkg-reconfigure (Ubuntu/Debian method):**

```bash
# Configure keyboard for the system (this affects SDDM)
sudo dpkg-reconfigure keyboard-configuration

# Select:
# - Keyboard model
# - Country of origin for keyboard
# - Keyboard layout
# - Additional layouts (if needed)

# Apply changes
sudo systemctl restart sddm
```

4. **Manual X11 keyboard configuration:**

Edit `/etc/X11/xorg.conf.d/00-keyboard.conf`:

```bash
sudo mkdir -p /etc/X11/xorg.conf.d/
sudo nano /etc/X11/xorg.conf.d/00-keyboard.conf
```

Add:

```
Section "InputClass"
    Identifier "system-keyboard"
    MatchIsKeyboard "on"
    Option "XkbLayout" "us,es,fr,de"
    Option "XkbVariant" ",,,nodeadkeys"
    Option "XkbOptions" "grp:alt_shift_toggle"
EndSection
```

This configures:
- US, Spanish, French, and German layouts
- Alt+Shift to switch between them
- German layout with no dead keys

5. **Restart SDDM:**

```bash
sudo systemctl restart sddm
```

### Verify Keyboard Layouts Work

1. Log out to return to SDDM
2. Click the keyboard layout button (should show current layout)
3. Try switching between layouts
4. Type in password field to verify layout changes

### Common Keyboard Layout Codes

| Language | Layout Code | Variant |
|----------|-------------|---------|
| English (US) | us | - |
| English (UK) | gb | - |
| Spanish | es | - |
| French | fr | - |
| German | de | - |
| Portuguese | pt | - |
| Italian | it | - |
| Russian | ru | - |
| Arabic | ara | - |
| Japanese | jp | - |
| Chinese | cn | - |

### Troubleshooting Keyboard Layouts

**Problem: No keyboard layouts appear**

```bash
# Check SDDM logs
journalctl -u sddm -b

# Verify X11 keyboard configuration
setxkbmap -query

# Check if keyboard module is loaded
ls /usr/lib/x86_64-linux-gnu/sddm/ | grep keyboard

# Reinstall SDDM if needed
sudo apt-get install --reinstall sddm
```

**Problem: Layout button shows but no layouts in dropdown**

This means SDDM keyboard API isn't detecting layouts. Fix:

```bash
# Ensure keyboard configuration exists
cat /etc/X11/xorg.conf.d/00-keyboard.conf

# If empty or missing, reconfigure:
sudo dpkg-reconfigure keyboard-configuration
sudo systemctl restart sddm
```

**Problem: Theme shows "No keyboard layouts configured"**

This is correct behavior when no layouts are configured. To hide the button:

Edit `theme.conf`:
```ini
[LoginScreen.MenuArea.Layout]
display = false
```

## Part 3: Complete Testing Checklist

### Before Testing

- [ ] Install required language packs
- [ ] Configure keyboard layouts
- [ ] Have test user account ready
- [ ] Know how to access TTY (Ctrl+Alt+F3) in case of issues

### Test Each Translation

For each language to test (Spanish, French, German, etc.):

- [ ] Set system locale to target language
- [ ] Reboot system
- [ ] Verify SDDM displays in correct language:
  - [ ] Lock screen message
  - [ ] Clock and date format
  - [ ] Username/Password placeholders
  - [ ] Login button text
  - [ ] Power menu items (Suspend, Reboot, Shutdown)
  - [ ] Session selector labels
  - [ ] Keyboard layout selector
  - [ ] Virtual keyboard toggle
  - [ ] Warning messages (test Caps Lock)
  - [ ] User tooltips (hover over user avatar)
- [ ] Test special characters in password input
- [ ] Verify keyboard layout switching works
- [ ] Switch to English and verify no translation artifacts remain

### Test String Length/Layout

Some languages use longer words. Check for UI issues:

- [ ] Text doesn't overflow containers
- [ ] Buttons are appropriately sized
- [ ] Tooltips appear correctly
- [ ] Popup menus display properly
- [ ] Multi-line text wraps correctly

### Test Right-to-Left Languages (Arabic, Hebrew)

If testing RTL languages:

- [ ] Text direction is correct
- [ ] Icons are properly positioned
- [ ] Layout mirrors appropriately
- [ ] Input fields work correctly

## Part 4: Automated Testing Script

Save as `test-translations.sh`:

```bash
#!/bin/bash
# Automated translation testing script

LOCALES=("es_ES.UTF-8" "fr_FR.UTF-8" "de_DE.UTF-8" "en_GB.UTF-8")
THEME_PATH="/usr/share/sddm/themes/ubuntu-budgie-login"

echo "SDDM Translation Testing Script"
echo "================================"

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo "Please run as root (sudo)"
    exit 1
fi

# Verify theme is installed
if [ ! -d "$THEME_PATH" ]; then
    echo "Error: Theme not found at $THEME_PATH"
    exit 1
fi

# Check translation files
echo -e "\nChecking translation files..."
for locale in "${LOCALES[@]}"; do
    lang_code="${locale:0:2}"
    trans_file="$THEME_PATH/translations/${lang_code}.json"
    
    if [ -f "$trans_file" ]; then
        # Validate JSON
        if python3 -m json.tool "$trans_file" > /dev/null 2>&1; then
            echo "✓ $lang_code - Valid"
        else
            echo "✗ $lang_code - Invalid JSON"
        fi
    else
        echo "⚠ $lang_code - Missing"
    fi
done

# Check keyboard configuration
echo -e "\nChecking keyboard configuration..."
if [ -f "/etc/X11/xorg.conf.d/00-keyboard.conf" ]; then
    echo "✓ Keyboard configuration exists"
    grep "XkbLayout" /etc/X11/xorg.conf.d/00-keyboard.conf | head -1
else
    echo "⚠ No keyboard configuration found"
    echo "  Run: sudo dpkg-reconfigure keyboard-configuration"
fi

echo -e "\nTo test a specific locale:"
echo "  sudo ./test-locale.sh es  # Spanish"
echo "  sudo ./test-locale.sh fr  # French"
echo "  sudo ./test-locale.sh de  # German"
```

Save as `test-locale.sh`:

```bash
#!/bin/bash
# Switch to specific locale for testing

if [ -z "$1" ]; then
    echo "Usage: sudo ./test-locale.sh <locale_code>"
    echo "Examples: es, fr, de, en"
    exit 1
fi

case $1 in
    es)
        LOCALE="es_ES.UTF-8"
        ;;
    fr)
        LOCALE="fr_FR.UTF-8"
        ;;
    de)
        LOCALE="de_DE.UTF-8"
        ;;
    en)
        LOCALE="en_GB.UTF-8"
        ;;
    *)
        echo "Unknown locale: $1"
        echo "Supported: es, fr, de, en"
        exit 1
        ;;
esac

echo "Switching system to $LOCALE..."
update-locale LANG=$LOCALE LANGUAGE=${LOCALE:0:5}

echo "Restarting SDDM..."
systemctl restart sddm

echo "✓ Locale changed to $LOCALE"
echo "  Log out to see SDDM in new language"
echo "  To switch back to English: sudo ./test-locale.sh en"
```

Make executable:
```bash
chmod +x test-translations.sh test-locale.sh
sudo ./test-translations.sh
```

## Part 5: Reporting Translation Issues

If you find translation problems:

1. **For incorrect translations:**
   - Note the exact string and context
   - Screenshot showing the issue
   - Report on Transifex or GitHub

2. **For UI layout issues:**
   - Screenshot showing overflow/clipping
   - Specify language and screen resolution
   - Open GitHub issue with details

3. **For missing translations:**
   - Note which string appears in English
   - Check if translation file exists
   - Verify locale is correctly set

## Resources

- SDDM Configuration: `/etc/sddm.conf`
- Theme Location: `/usr/share/sddm/themes/ubuntu-budgie-login/`
- Translation Files: `/usr/share/sddm/themes/ubuntu-budgie-login/translations/`
- SDDM Logs: `journalctl -u sddm`
- System Locale: `/etc/default/locale`

## Quick Reference Commands

```bash
# Check current locale
locale

# List available locales
locale -a

# View SDDM logs
journalctl -u sddm -b

# Restart SDDM
sudo systemctl restart sddm

# Test translation file validity
python3 -m json.tool /usr/share/sddm/themes/ubuntu-budgie-login/translations/es.json

# Check keyboard configuration
setxkbmap -query
```

---

For developer documentation, see [TRANSLATIONS.md](../TRANSLATIONS.md)
