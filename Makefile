# slickSDDM Theme - Flexible Installation Makefile
# Supports both direct installation and git submodule usage

# ============================================================================
# Configuration Variables
# ============================================================================

# Theme identification
THEME_NAME ?= ubuntu-budgie-login
THEME_VERSION ?= 1.0.0

# Installation paths
PREFIX ?= /usr
INSTALL_DIR ?= $(PREFIX)/share/sddm/themes/$(THEME_NAME)
SDDM_CONF_DIR ?= /etc/sddm.conf.d

# Distro-specific configuration
# Can be:
#  - Path to distro folder (e.g., distro/ubuntu-budgie)
#  - External path (e.g., ../my-distro-config for submodule usage)
DISTRO_DIR ?= distro/ubuntu-budgie

# Optional: Override individual distro components
DISTRO_METADATA ?= $(DISTRO_DIR)/metadata.desktop
DISTRO_THEME_CONF ?= $(DISTRO_DIR)/theme.conf
DISTRO_SDDM_CONF ?= $(DISTRO_DIR)/*.conf
DISTRO_FACES_DIR ?= $(DISTRO_DIR)/faces

# Build settings
VERBOSE ?= 0

# ============================================================================
# Colors for output
# ============================================================================

ifeq ($(VERBOSE),1)
  Q =
else
  Q = @
endif

GREEN  := \033[0;32m
YELLOW := \033[1;33m
BLUE   := \033[0;34m
RED    := \033[0;31m
NC     := \033[0m

define print_info
	@echo "$(BLUE)>>> $(1)$(NC)"
endef

define print_success
	@echo "$(GREEN)✓ $(1)$(NC)"
endef

define print_warning
	@echo "$(YELLOW)⚠ $(1)$(NC)"
endef

define print_error
	@echo "$(RED)✗ $(1)$(NC)"
endef

# ============================================================================
# Main Targets
# ============================================================================

.PHONY: all help install install-core install-distro install-translations \
        uninstall clean check-distro-config info test

# Default target
all: help

help:
	@echo "$(GREEN)slickSDDM Theme Installation$(NC)"
	@echo "======================================"
	@echo ""
	@echo "Usage:"
	@echo "  make install                    - Install complete theme (core + distro config)"
	@echo "  make install-core               - Install only core theme files"
	@echo "  make install-distro             - Install only distro-specific files"
	@echo "  make uninstall                  - Remove installed theme"
	@echo ""
	@echo "Configuration Variables:"
	@echo "  THEME_NAME=name                 - Theme name (default: ubuntu-budgie-login)"
	@echo "  DISTRO_DIR=path                 - Path to distro config folder"
	@echo "  INSTALL_DIR=path                - Installation directory"
	@echo "  SDDM_CONF_DIR=path              - SDDM config directory"
	@echo ""
	@echo "Examples:"
	@echo "  # Standard installation (Ubuntu Budgie)"
	@echo "  sudo make install"
	@echo ""
	@echo "  # Installation from git submodule"
	@echo "  sudo make install DISTRO_DIR=../my-distro-config THEME_NAME=my-theme"
	@echo ""
	@echo "  # Install without distro files (use defaults)"
	@echo "  sudo make install-core"
	@echo ""
	@echo "  # Custom installation paths"
	@echo "  sudo make install INSTALL_DIR=/opt/sddm-themes/my-theme"
	@echo ""
	@echo "Info:"
	@echo "  make info                       - Display configuration"
	@echo "  make check-distro-config        - Validate distro configuration"
	@echo ""
	@echo "Testing:"
	@echo "  make test                       - Run translation tests"
	@echo ""
	@echo "Documentation: See INTEGRATION_GUIDE.md for using as submodule"

# Display current configuration
info:
	@echo "$(BLUE)Current Configuration:$(NC)"
	@echo "  Theme Name:        $(THEME_NAME)"
	@echo "  Theme Version:     $(THEME_VERSION)"
	@echo "  Install Directory: $(INSTALL_DIR)"
	@echo "  SDDM Config Dir:   $(SDDM_CONF_DIR)"
	@echo "  Distro Directory:  $(DISTRO_DIR)"
	@echo ""
	@echo "Distro Components:"
	@echo "  Metadata:          $(DISTRO_METADATA)"
	@echo "  Theme Config:      $(DISTRO_THEME_CONF)"
	@echo "  SDDM Config:       $(DISTRO_SDDM_CONF)"
	@echo "  Faces Directory:   $(DISTRO_FACES_DIR)"

# Check if distro configuration is valid
check-distro-config:
	$(call print_info,Checking distro configuration...)
	$(Q)if [ ! -d "$(DISTRO_DIR)" ]; then \
		$(call print_error,Distro directory not found: $(DISTRO_DIR)); \
		exit 1; \
	fi
	$(Q)if [ ! -f "$(DISTRO_METADATA)" ]; then \
		$(call print_warning,metadata.desktop not found, will use example); \
	fi
	$(Q)if [ ! -f "$(DISTRO_THEME_CONF)" ]; then \
		$(call print_warning,theme.conf not found, will use example); \
	fi
	$(call print_success,Distro configuration valid)

# ============================================================================
# Installation Targets
# ============================================================================

# Complete installation
install: check-distro-config install-core install-distro install-translations
	$(call print_success,Theme installation complete!)
	@echo ""
	@echo "$(YELLOW)Next steps:$(NC)"
	@echo "  1. Test theme: sddm-greeter-qt6 --test-mode --theme $(INSTALL_DIR)"
	@echo "  2. Restart SDDM: sudo systemctl restart sddm"
	@echo "  3. Customize: sudo customize-theme --interactive"

# Install core theme files (distro-agnostic)
install-core:
	$(call print_info,Installing core theme files to $(INSTALL_DIR))
	
	# Create directories
	$(Q)install -d $(INSTALL_DIR)
	$(Q)install -d $(INSTALL_DIR)/components
	$(Q)install -d $(INSTALL_DIR)/components/QtQuick/VirtualKeyboard/Styles/vkeyboardStyle
	$(Q)install -d $(INSTALL_DIR)/icons
	$(Q)install -d $(INSTALL_DIR)/icons/sessions
	$(Q)install -d $(INSTALL_DIR)/backgrounds
	$(Q)install -d $(INSTALL_DIR)/translations
	
	# Install QML files
	$(call print_info,Installing QML components...)
	$(Q)install -m 644 sddm-theme/Main.qml $(INSTALL_DIR)/
	$(Q)install -m 644 sddm-theme/components/*.qml $(INSTALL_DIR)/components/
	$(Q)install -m 644 sddm-theme/components/qmldir $(INSTALL_DIR)/components/
	$(Q)install -m 644 sddm-theme/components/QtQuick/VirtualKeyboard/Styles/vkeyboardStyle/*.qml \
		$(INSTALL_DIR)/components/QtQuick/VirtualKeyboard/Styles/vkeyboardStyle/
	
	# Install icons
	$(call print_info,Installing icons...)
	$(Q)install -m 644 sddm-theme/icons/*.svg $(INSTALL_DIR)/icons/
	$(Q)install -m 644 sddm-theme/icons/sessions/*.svg $(INSTALL_DIR)/icons/sessions/
	
	# Install default background
	$(call print_info,Installing default background...)
	$(Q)if [ -f sddm-theme/backgrounds/default.jpg ]; then \
		install -m 644 sddm-theme/backgrounds/default.jpg $(INSTALL_DIR)/backgrounds/; \
	fi
	
	# Install example configuration if no distro config
	$(Q)if [ ! -f "$(DISTRO_THEME_CONF)" ]; then \
		$(call print_warning,Using example theme.conf); \
		install -m 644 sddm-theme/theme.conf.example $(INSTALL_DIR)/theme.conf; \
	fi
	
	# Install example metadata if no distro metadata
	$(Q)if [ ! -f "$(DISTRO_METADATA)" ]; then \
		$(call print_warning,Using example metadata.desktop); \
		install -m 644 sddm-theme/metadata.desktop.example $(INSTALL_DIR)/metadata.desktop; \
	fi
	
	$(call print_success,Core theme files installed)

# Install distro-specific files
install-distro: check-distro-config
	$(call print_info,Installing distro-specific files from $(DISTRO_DIR))
	
	# Install metadata.desktop
	$(Q)if [ -f "$(DISTRO_METADATA)" ]; then \
		$(call print_info,Installing metadata.desktop...); \
		install -m 644 $(DISTRO_METADATA) $(INSTALL_DIR)/metadata.desktop; \
	fi
	
	# Install theme.conf
	$(Q)if [ -f "$(DISTRO_THEME_CONF)" ]; then \
		$(call print_info,Installing theme.conf...); \
		install -m 644 $(DISTRO_THEME_CONF) $(INSTALL_DIR)/theme.conf; \
	fi
	
	# Install SDDM configuration
	$(Q)if [ -n "$(wildcard $(DISTRO_SDDM_CONF))" ]; then \
		$(call print_info,Installing SDDM configuration...); \
		install -d $(SDDM_CONF_DIR); \
		install -m 644 $(DISTRO_SDDM_CONF) $(SDDM_CONF_DIR)/; \
	fi
	
	# Install avatar faces
	$(Q)if [ -d "$(DISTRO_FACES_DIR)" ] && [ -n "$$(ls -A $(DISTRO_FACES_DIR) 2>/dev/null)" ]; then \
		$(call print_info,Installing avatar faces...); \
		install -d $(INSTALL_DIR)/faces; \
		install -m 644 $(DISTRO_FACES_DIR)/*.png $(INSTALL_DIR)/faces/ 2>/dev/null || true; \
	else \
		$(call print_warning,No avatar faces found in $(DISTRO_FACES_DIR)); \
		$(call print_info,Generating default faces...); \
		install -d $(INSTALL_DIR)/faces; \
		bash scripts/generate-default-faces.sh || true; \
	fi
	
	$(call print_success,Distro-specific files installed)

# Install translations
install-translations:
	$(call print_info,Installing translations...)
	$(Q)install -d $(INSTALL_DIR)/translations
	$(Q)if [ -n "$$(ls -A sddm-theme/translations/*.ts 2>/dev/null)" ]; then \
		install -m 644 sddm-theme/translations/*.ts $(INSTALL_DIR)/translations/; \
	fi
	$(call print_success,Translations installed)

# Install customization script
install-scripts:
	$(call print_info,Installing customization scripts...)
	$(Q)install -d $(PREFIX)/bin
	$(Q)install -m 755 scripts/customize-theme $(PREFIX)/bin/
	$(call print_success,Scripts installed)

# ============================================================================
# Uninstallation
# ============================================================================

uninstall:
	$(call print_info,Removing theme from $(INSTALL_DIR))
	$(Q)rm -rf $(INSTALL_DIR)
	$(Q)rm -f $(SDDM_CONF_DIR)/*$(THEME_NAME)*.conf
	$(Q)rm -f $(PREFIX)/bin/customize-theme
	$(call print_success,Theme uninstalled)

# ============================================================================
# Development Targets
# ============================================================================

# Run translation tests
test:
	$(call print_info,Running translation tests...)
	$(Q)python3 tests/test_translations.py

# Clean build artifacts
clean:
	$(call print_info,Cleaning build artifacts...)
	$(Q)find sddm-theme/translations -name "*.qm" -delete
	$(call print_success,Clean complete)

# Pull translations from Transifex
translations-pull:
	$(call print_info,Pulling translations from Transifex...)
	$(Q)bash scripts/tx-pull.sh

# ============================================================================
# Quick Install Targets for Common Scenarios
# ============================================================================

# Quick install for Ubuntu Budgie (default)
.PHONY: install-ubuntu-budgie
install-ubuntu-budgie:
	$(MAKE) install THEME_NAME=ubuntu-budgie-login DISTRO_DIR=distro/ubuntu-budgie

# Install with automatic face generation
.PHONY: install-with-faces
install-with-faces: install
	$(call print_info,Generating avatar faces...)
	$(Q)bash scripts/generate-default-faces.sh

# Install for testing (with verbose output)
.PHONY: install-test
install-test:
	$(MAKE) install VERBOSE=1
	$(call print_info,Testing theme...)
	sddm-greeter-qt6 --test-mode --theme $(INSTALL_DIR)

# ============================================================================
# Packaging Helpers
# ============================================================================

.PHONY: install-debian install-rpm

# Debian/Ubuntu packaging
install-debian: INSTALL_DIR = $(DESTDIR)/usr/share/sddm/themes/$(THEME_NAME)
install-debian: SDDM_CONF_DIR = $(DESTDIR)/etc/sddm.conf.d
install-debian: PREFIX = $(DESTDIR)/usr
install-debian: install

# RPM packaging  
install-rpm: INSTALL_DIR = $(DESTDIR)/usr/share/sddm/themes/$(THEME_NAME)
install-rpm: SDDM_CONF_DIR = $(DESTDIR)/etc/sddm.conf.d
install-rpm: PREFIX = $(DESTDIR)/usr
install-rpm: install

# ============================================================================
# Help for Submodule Integration
# ============================================================================

.PHONY: help-submodule
help-submodule:
	@echo "$(GREEN)Using slickSDDM as a Git Submodule$(NC)"
	@echo "======================================"
	@echo ""
	@echo "1. Add as submodule to your project:"
	@echo "   git submodule add https://github.com/ubuntubudgie/slickSDDM.git"
	@echo ""
	@echo "2. Create your distro configuration:"
	@echo "   mkdir -p my-distro-config"
	@echo "   cp slickSDDM/distro/ubuntu-budgie/* my-distro-config/"
	@echo "   # Edit files in my-distro-config/"
	@echo ""
	@echo "3. Install with your configuration:"
	@echo "   cd slickSDDM"
	@echo "   sudo make install DISTRO_DIR=../my-distro-config THEME_NAME=my-theme"
	@echo ""
	@echo "See INTEGRATION_GUIDE.md for complete documentation."
