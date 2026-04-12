# AccountsService Per-User Wallpapers for SDDM
## Manual Installation Guide

This guide provides step-by-step instructions for manually installing the AccountsService integration feature into the ubuntu-budgie-login SDDM theme.

---

## Overview

This feature enables SDDM to display each user's desktop wallpaper on the login screen by reading wallpaper preferences from AccountsService files. It includes:

- **Smooth crossfade transitions** between user wallpapers
- **Automatic cache updates** when wallpapers change
- **Fallback support** to theme's default backgrounds
- **SystemD integration** for automatic updates

---

## Prerequisites

- SDDM with Qt6 installed
- ubuntu-budgie-login theme installed at `/usr/share/sddm/themes/ubuntu-budgie-login/`
- Root/sudo access
- SystemD-based system

---

## Installation Steps

### 1. Install Theme Files

```bash
# Create components directory if it doesn't exist
sudo mkdir -p /usr/share/sddm/themes/ubuntu-budgie-login/components

# Install AccountsService QML singleton
sudo cp AccountsService.qml /usr/share/sddm/themes/ubuntu-budgie-login/components/

# Install qmldir (required for singleton registration)
sudo cp qmldir /usr/share/sddm/themes/ubuntu-budgie-login/components/

# Replace Main.qml with crossfade-enabled version
sudo cp Main.qml /usr/share/sddm/themes/ubuntu-budgie-login/

# Set correct permissions
sudo chmod 644 /usr/share/sddm/themes/ubuntu-budgie-login/components/AccountsService.qml
sudo chmod 644 /usr/share/sddm/themes/ubuntu-budgie-login/components/qmldir
sudo chmod 644 /usr/share/sddm/themes/ubuntu-budgie-login/Main.qml
```

### 2. Install Cache Update Script

```bash
# Create scripts directory
sudo mkdir -p /usr/share/sddm/themes/ubuntu-budgie-login/scripts

# Install update script
sudo cp update-sddm-backgrounds-cache /usr/share/sddm/themes/ubuntu-budgie-login/scripts/

# Make it executable
sudo chmod 755 /usr/share/sddm/themes/ubuntu-budgie-login/scripts/update-sddm-backgrounds-cache

# Create cache directory
sudo mkdir -p /usr/share/sddm/themes/ubuntu-budgie-login/cache
```

### 3. Install SystemD Units

```bash
# Install service, timer, and path units
sudo cp sddm-backgrounds-cache.service /etc/systemd/system/
sudo cp sddm-backgrounds-cache.timer /etc/systemd/system/
sudo cp sddm-backgrounds-cache.path /etc/systemd/system/

# Set correct permissions
sudo chmod 644 /etc/systemd/system/sddm-backgrounds-cache.service
sudo chmod 644 /etc/systemd/system/sddm-backgrounds-cache.timer
sudo chmod 644 /etc/systemd/system/sddm-backgrounds-cache.path

# Reload systemd
sudo systemctl daemon-reload
```

### 4. Enable and Start SystemD Units

```bash
# Enable timer (periodic updates every 5 minutes)
sudo systemctl enable sddm-backgrounds-cache.timer

# Enable path watcher (triggers on AccountsService file changes)
sudo systemctl enable sddm-backgrounds-cache.path

# Start units
sudo systemctl start sddm-backgrounds-cache.timer
sudo systemctl start sddm-backgrounds-cache.path

# Run initial cache generation
sudo systemctl start sddm-backgrounds-cache.service
```

### 5. Enable Feature in Theme Configuration

Edit the theme configuration file:

```bash
sudo nano /usr/share/sddm/themes/ubuntu-budgie-login/theme.conf
```

Add or modify under `[General]` section:

```ini
[General]
use-accounts-service-backgrounds = true
```

Save and exit (Ctrl+X, Y, Enter in nano).

### 6. Restart SDDM

```bash
sudo systemctl restart sddm
```

---

## Verification

### Test Cache Generation

```bash
# Check that cache was created
cat /usr/share/sddm/themes/ubuntu-budgie-login/cache/user-backgrounds.json

# Example output:
# {
#   "username1": "/home/username1/.local/share/backgrounds/image.jpg",
#   "username2": "/usr/share/backgrounds/warty-final-ubuntu.png"
# }
```

### Check SystemD Status

```bash
# Check timer status
systemctl status sddm-backgrounds-cache.timer

# Check path watcher status
systemctl status sddm-backgrounds-cache.path

# View service logs
journalctl -u sddm-backgrounds-cache.service
```

### Test in SDDM

```bash
# Run SDDM greeter in test mode
sddm-greeter-qt6 --test-mode --theme /usr/share/sddm/themes/ubuntu-budgie-login

# Switch between users and verify:
# 1. Each user shows their own wallpaper
# 2. Smooth 400ms crossfade transition occurs
# 3. Fallback to default background if user has no wallpaper set
```

---

## File Structure After Installation

```
/usr/share/sddm/themes/ubuntu-budgie-login/
├── Main.qml                      # Modified with crossfade support
├── theme.conf                    # Must include use-accounts-service-backgrounds = true
├── components/
│   ├── AccountsService.qml       # Auto-generated singleton (DO NOT EDIT)
│   └── qmldir                    # Singleton registration
├── scripts/
│   └── update-sddm-backgrounds-cache  # Cache generation script
└── cache/
    └── user-backgrounds.json     # JSON cache (auto-generated)

/etc/systemd/system/
├── sddm-backgrounds-cache.service    # Cache update service
├── sddm-backgrounds-cache.timer      # Periodic trigger (every 5 min)
└── sddm-backgrounds-cache.path       # File change trigger
```

---

## How It Works

### Data Flow

1. **Desktop environment** (Budgie) writes wallpaper path to `/var/lib/AccountsService/users/USERNAME`
2. **SystemD path unit** detects file modification
3. **Update script** runs, reads all user files, strips quotes from paths
4. **JSON cache** is generated in `cache/user-backgrounds.json`
5. **AccountsService.qml** is regenerated with embedded JSON data
6. **SDDM** loads theme, reads embedded cache
7. **Main.qml** displays appropriate wallpaper with crossfade transitions

### Crossfade Implementation

- **Two-layer system**: Layer A (z:0) and Layer B (z:1)
- **Ping-pong switching**: Alternates which layer is visible
- **Smooth transitions**: 400ms fade using QML Behaviors
- **Effect integration**: MultiEffect (blur/brightness) applied to entire container

### Quote Stripping

Budgie stores paths in AccountsService files with surrounding single quotes:
```ini
BackgroundFile='/path/to/image.jpg'
```

The update script strips these quotes using:
```bash
sed "s/^['\"]//;s/['\"]$//"
```

---

## Troubleshooting

### No wallpapers showing

```bash
# Check if cache is populated
cat /usr/share/sddm/themes/ubuntu-budgie-login/cache/user-backgrounds.json

# Manually run cache update
sudo /usr/share/sddm/themes/ubuntu-budgie-login/scripts/update-sddm-backgrounds-cache

# Check AccountsService files exist
ls -la /var/lib/AccountsService/users/

# Verify BackgroundFile entries
grep BackgroundFile /var/lib/AccountsService/users/*
```

### Wallpapers not updating

```bash
# Check timer is running
systemctl status sddm-backgrounds-cache.timer

# Check path watcher is active
systemctl status sddm-backgrounds-cache.path

# View recent updates
journalctl -u sddm-backgrounds-cache.service -n 20

# Manually trigger update
sudo systemctl start sddm-backgrounds-cache.service
```

### No crossfade animation

```bash
# Check theme.conf has animations enabled
grep enableAnimations /usr/share/sddm/themes/ubuntu-budgie-login/theme.conf

# Should show: enableAnimations = true
```

### Permission errors

```bash
# Fix ownership of cache directory
sudo chown -R root:root /usr/share/sddm/themes/ubuntu-budgie-login/cache
sudo chmod 755 /usr/share/sddm/themes/ubuntu-budgie-login/cache
sudo chmod 644 /usr/share/sddm/themes/ubuntu-budgie-login/cache/user-backgrounds.json
```

---

## Customization

### Adjust Crossfade Duration

Edit `/usr/share/sddm/themes/ubuntu-budgie-login/Main.qml`:

```qml
Behavior on opacity {
    enabled: Config.enableAnimations
    NumberAnimation {
        duration: 400  // Change this value (in milliseconds)
        easing.type: Easing.InOutQuad
    }
}
```

### Change Update Frequency

Edit `/etc/systemd/system/sddm-backgrounds-cache.timer`:

```ini
[Timer]
OnBootSec=30sec
OnUnitActiveSec=5min  # Change this value
```

Then reload:
```bash
sudo systemctl daemon-reload
sudo systemctl restart sddm-backgrounds-cache.timer
```

---

## Uninstallation

```bash
# Stop and disable systemd units
sudo systemctl stop sddm-backgrounds-cache.timer
sudo systemctl stop sddm-backgrounds-cache.path
sudo systemctl disable sddm-backgrounds-cache.timer
sudo systemctl disable sddm-backgrounds-cache.path

# Remove systemd units
sudo rm /etc/systemd/system/sddm-backgrounds-cache.service
sudo rm /etc/systemd/system/sddm-backgrounds-cache.timer
sudo rm /etc/systemd/system/sddm-backgrounds-cache.path
sudo systemctl daemon-reload

# Remove theme components (restore from backup if available)
sudo rm /usr/share/sddm/themes/ubuntu-budgie-login/components/AccountsService.qml
sudo rm /usr/share/sddm/themes/ubuntu-budgie-login/components/qmldir
# Restore original Main.qml from backup

# Remove scripts and cache
sudo rm -rf /usr/share/sddm/themes/ubuntu-budgie-login/scripts
sudo rm -rf /usr/share/sddm/themes/ubuntu-budgie-login/cache

# Disable in theme.conf
sudo nano /usr/share/sddm/themes/ubuntu-budgie-login/theme.conf
# Set: use-accounts-service-backgrounds = false

# Restart SDDM
sudo systemctl restart sddm
```

---

## Notes for Package Maintainers

### Install Locations

- Theme files → `/usr/share/sddm/themes/ubuntu-budgie-login/`
- SystemD units → `/etc/systemd/system/` or `/lib/systemd/system/`
- Scripts → `/usr/share/sddm/themes/ubuntu-budgie-login/scripts/`

### Post-Install Actions

```bash
# In postinst script:
systemctl daemon-reload
systemctl enable sddm-backgrounds-cache.timer
systemctl enable sddm-backgrounds-cache.path
systemctl start sddm-backgrounds-cache.timer
systemctl start sddm-backgrounds-cache.path
/usr/share/sddm/themes/ubuntu-budgie-login/scripts/update-sddm-backgrounds-cache
```

### Pre-Remove Actions

```bash
# In prerm script:
systemctl stop sddm-backgrounds-cache.timer
systemctl stop sddm-backgrounds-cache.path
systemctl disable sddm-backgrounds-cache.timer
systemctl disable sddm-backgrounds-cache.path
```

### Dependencies

- `sddm` (with Qt6)
- `systemd`
- `bash`
- `sed`, `grep`, `cut` (coreutils)

---

## License & Credits

Part of the ubuntu-budgie-login SDDM theme.
AccountsService integration implementation for displaying per-user wallpapers.

This implementation uses:
- QML singleton pattern for cache access
- SystemD for automatic updates
- Embedded JSON data (no file I/O at runtime)
- Two-layer crossfade for smooth transitions
