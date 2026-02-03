# slickSDDM Integration Guide

Guide for integrating slickSDDM theme into your distribution or project.

## Table of Contents

1. [Integration Methods](#integration-methods)
2. [Using as Git Submodule](#using-as-git-submodule)
3. [Creating Distro Configuration](#creating-distro-configuration)
4. [Installation Options](#installation-options)
5. [Packaging](#packaging)
6. [Testing](#testing)

---

## Integration Methods

### Method 1: Direct Fork

Clone and modify the theme directly:
```bash
git clone https://github.com/ubuntubudgie/slickSDDM.git my-theme
cd my-theme
# Modify distro/ubuntu-budgie or create new distro folder
sudo make install DISTRO_DIR=distro/my-distro THEME_NAME=my-theme
```

### Method 2: Git Submodule (Recommended)

Keep the theme separate from your distro customizations:
```bash
# In your project
git submodule add https://github.com/ubuntubudgie/slickSDDM.git
```

---

## Using as Git Submodule

### Project Structure
```
my-distro-project/
├── slickSDDM/                    # Git submodule
│   ├── sddm-theme/
│   ├── Makefile
│   └── ...
├── distro-config/                # Your customizations
│   ├── metadata.desktop
│   ├── theme.conf
│   ├── 50-my-distro.conf
│   └── faces/
│       └── *.png
├── Makefile                      # Your project Makefile
└── README.md
```

### Setup Steps

#### 1. Add Submodule
```bash
git submodule add https://github.com/ubuntubudgie/slickSDDM.git
git submodule update --init --recursive
```

#### 2. Create Distro Configuration
```bash
mkdir -p distro-config
cd distro-config

# Copy templates from submodule
cp ../slickSDDM/distro/ubuntu-budgie/metadata.desktop .
cp ../slickSDDM/distro/ubuntu-budgie/theme.conf .
cp ../slickSDDM/distro/ubuntu-budgie/50-ubuntu-budgie.conf 50-my-distro.conf

# Create faces directory (optional)
mkdir -p faces
```

#### 3. Customize Files

**metadata.desktop:**
```ini
[SddmGreeterTheme]
Name=My Distro Login
Description=My Distro themed login screen
Author=Your Name
Copyright=(C) 2026
License=GPLv3
Type=sddm-theme
Version=1.0
Website=https://mydistro.org
Screenshot=preview.png
MainScript=Main.qml
ConfigFile=theme.conf
Theme-Id=my-distro-login
Theme-API=2.0
QtVersion=6
```

**50-my-distro.conf:**
```ini
[Theme]
Current=my-distro-login
ThemeDir=/usr/share/sddm/themes

[General]
InputMethod=qtvirtualkeyboard
GreeterEnvironment=QML2_IMPORT_PATH=/usr/share/sddm/themes/my-distro-login/components/,QT_IM_MODULE=qtvirtualkeyboard
```

**theme.conf:**
- Edit colors, fonts, backgrounds to match your branding
- See CUSTOMIZATION.md for all options

#### 4. Create Project Makefile
```makefile
# my-distro-project/Makefile

THEME_NAME = my-distro-login
DISTRO_CONFIG = distro-config

.PHONY: install uninstall

install:
	cd slickSDDM && \
	sudo $(MAKE) install \
		THEME_NAME=$(THEME_NAME) \
		DISTRO_DIR=../$(DISTRO_CONFIG)

uninstall:
	cd slickSDDM && \
	sudo $(MAKE) uninstall \
		THEME_NAME=$(THEME_NAME)

test:
	cd slickSDDM && $(MAKE) test
```

#### 5. Install
```bash
make install
```

---

## Creating Distro Configuration

### Required Files

#### metadata.desktop

Defines theme metadata for SDDM:
```ini
[SddmGreeterTheme]
Name=Theme Display Name           # Required
Description=Short description     # Required
Author=Author Name                # Required
Type=sddm-theme                   # Required
Theme-Id=unique-theme-id          # Required
Theme-API=2.0                     # Required
MainScript=Main.qml               # Required
ConfigFile=theme.conf             # Required
QtVersion=6                       # Required (for SDDM ≥ 0.21)

# Optional
License=GPLv3
Version=1.0
Website=https://example.org
Copyright=(C) 2026 Your Name
Screenshot=preview.png
```

#### theme.conf

Main theme configuration. Start from example:
```bash
cp slickSDDM/sddm-theme/theme.conf.example my-config/theme.conf
```

Key sections to customize:
- `[LockScreen]` - Background, clock colors
- `[LoginScreen]` - Background, avatar colors
- `[LoginScreen.LoginArea.Avatar]` - Border colors
- `[LoginScreen.LoginArea.PasswordInput]` - Border colors
- `[LoginScreen.MenuArea.*]` - Menu colors

See CUSTOMIZATION.md for complete reference.

#### SDDM Configuration (50-*.conf)

SDDM system configuration:
```ini
[Theme]
Current=your-theme-name
ThemeDir=/usr/share/sddm/themes

[General]
InputMethod=qtvirtualkeyboard
GreeterEnvironment=QML2_IMPORT_PATH=/usr/share/sddm/themes/your-theme-name/components/,QT_IM_MODULE=qtvirtualkeyboard
```

**Important**: Filename should be `50-yourname.conf` to ensure proper load order.

### Optional Files

#### Avatar Faces

Custom default avatars in `faces/` directory:
```
faces/
├── face-1.png
├── face-2.png
├── ...
└── face-15.png
```

Requirements:
- PNG format
- 256x256 pixels recommended
- Transparent background

If not provided, generic avatars will be generated automatically.

#### Custom Backgrounds

Place in your distro config and reference in theme.conf:
```
distro-config/
└── backgrounds/
    ├── login.jpg
    └── lock.jpg
```
```ini
[LockScreen]
background = /usr/share/backgrounds/mydistro/lock.jpg

[LoginScreen]
background = /usr/share/backgrounds/mydistro/login.jpg
```

---

## Installation Options

### Basic Installation
```bash
sudo make -C slickSDDM install \
    DISTRO_DIR=../distro-config \
    THEME_NAME=my-theme
```

### Custom Paths
```bash
sudo make -C slickSDDM install \
    DISTRO_DIR=../distro-config \
    THEME_NAME=my-theme \
    INSTALL_DIR=/opt/sddm-themes/my-theme \
    SDDM_CONF_DIR=/etc/sddm.conf.d
```

### Install Only Core (No Distro Files)
```bash
sudo make -C slickSDDM install-core
```

### Install Only Distro Files
```bash
sudo make -C slickSDDM install-distro \
    DISTRO_DIR=../distro-config
```

### Check Configuration Before Installing
```bash
make -C slickSDDM check-distro-config \
    DISTRO_DIR=../distro-config
```

---

## Packaging

### Debian/Ubuntu Package

Example `debian/rules`:
```makefile
#!/usr/bin/make -f

%:
	dh $@

override_dh_auto_install:
	cd slickSDDM && \
	$(MAKE) install-debian \
		DISTRO_DIR=../distro-config \
		THEME_NAME=my-distro-login \
		DESTDIR=$(CURDIR)/debian/my-distro-sddm-theme
```

Example `debian/install`:
```
# Additional files not handled by Makefile
distro-config/backgrounds/* usr/share/backgrounds/my-distro/
```

### RPM Package

Example `my-distro-sddm-theme.spec`:
```spec
Name: my-distro-sddm-theme
Version: 1.0.0
Release: 1%{?dist}
Summary: My Distro SDDM Theme

License: GPLv3
URL: https://mydistro.org
Source0: %{name}-%{version}.tar.gz

BuildArch: noarch
Requires: sddm >= 0.21

%description
Custom SDDM theme for My Distro.

%prep
%setup -q

%build
# Nothing to build

%install
cd slickSDDM
make install-rpm \
    DISTRO_DIR=../distro-config \
    THEME_NAME=my-distro-login \
    DESTDIR=%{buildroot}

%files
%license LICENSE
%doc README.md
/usr/share/sddm/themes/my-distro-login/
/etc/sddm.conf.d/50-my-distro.conf

%post
# Restart SDDM if running
systemctl is-active --quiet sddm && systemctl restart sddm || true
```

### Arch Linux PKGBUILD
```bash
pkgname=my-distro-sddm-theme
pkgver=1.0.0
pkgrel=1
pkgdesc="My Distro SDDM Theme"
arch=('any')
url="https://mydistro.org"
license=('GPL3')
depends=('sddm>=0.21' 'qt6-svg' 'qt6-virtualkeyboard')
source=("git+https://github.com/yourusername/my-distro-project.git")

build() {
    cd "$srcdir/my-distro-project"
    git submodule update --init --recursive
}

package() {
    cd "$srcdir/my-distro-project/slickSDDM"
    make install-core \
        INSTALL_DIR="$pkgdir/usr/share/sddm/themes/my-distro-login"
    
    make install-distro \
        DISTRO_DIR=../distro-config \
        INSTALL_DIR="$pkgdir/usr/share/sddm/themes/my-distro-login" \
        SDDM_CONF_DIR="$pkgdir/etc/sddm.conf.d"
}
```

---

## Testing

### Test Before Installation
```bash
# Validate distro configuration
make -C slickSDDM check-distro-config DISTRO_DIR=../distro-config

# Run translation tests
make -C slickSDDM test
```

### Test Installed Theme
```bash
# Test mode (doesn't require restarting SDDM)
sddm-greeter-qt6 --test-mode --theme /usr/share/sddm/themes/my-distro-login

# Check SDDM configuration
sddm-greeter-qt6 --show-config

# View logs
journalctl -u sddm -b
```

### Test in Virtual Machine

Recommended for safety:
```bash
# Create VM with your distro
# Install theme package
# Test login/logout cycles
# Verify translations with different locales
```

---

## Updating Submodule
```bash
# Update to latest version
git submodule update --remote slickSDDM

# Update to specific version
cd slickSDDM
git checkout v1.0.1
cd ..
git add slickSDDM
git commit -m "Update slickSDDM to v1.0.1"
```

---

## Troubleshooting

### Theme Not Appearing
```bash
# Check SDDM configuration
cat /etc/sddm.conf.d/*.conf | grep Current

# Verify installation
ls -la /usr/share/sddm/themes/my-distro-login/

# Check SDDM logs
journalctl -u sddm -n 50
```

### Configuration Not Applied
```bash
# Verify theme.conf syntax
grep -v '^#' /usr/share/sddm/themes/*/theme.conf | grep -v '^$'

# Test with defaults
sudo slicksddm-customize --reset
```

### Distro Files Not Found
```bash
# Check paths
make -C slickSDDM info DISTRO_DIR=../distro-config

# Validate configuration
make -C slickSDDM check-distro-config DISTRO_DIR=../distro-config
```

---

## Support

- Main Project: https://github.com/ubuntubudgie/slickSDDM
- Issues: https://github.com/ubuntubudgie/slickSDDM/issues
- Documentation: See README.md and CUSTOMIZATION.md

---

**Happy theming!**
