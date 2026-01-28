# Makefile for Ubuntu Budgie SDDM Theme Translations
# Simplifies translation workflow using Qt6 tools

THEME_DIR = /usr/share/sddm/themes/ubuntu-budgie-login
LUPDATE = /usr/lib/qt6/bin/lupdate
LRELEASE = /usr/lib/qt6/bin/lrelease
LINGUIST = linguist-qt6

# Find all translation files
TRANSLATIONS = $(wildcard translations/*.ts)
QM_FILES = $(TRANSLATIONS:.ts=.qm)

.PHONY: all help translations install clean check-tools update-ts stats

# Default target
all: check-tools translations

# Help information
help:
	@echo "Ubuntu Budgie SDDM Theme - Translation Management"
	@echo ""
	@echo "Available targets:"
	@echo "  make translations     - Compile all .ts files to .qm"
	@echo "  make update-ts        - Extract strings from QML and update .ts files"
	@echo "  make install          - Install translations to system and restart SDDM"
	@echo "  make stats            - Show translation statistics"
	@echo "  make edit-LANG        - Open LANG translation in Qt Linguist (e.g., make edit-es)"
	@echo "  make clean            - Remove compiled .qm files"
	@echo "  make check-tools      - Verify Qt6 tools are installed"
	@echo ""
	@echo "Examples:"
	@echo "  make update-ts        # Extract new strings"
	@echo "  make edit-es          # Edit Spanish translation"
	@echo "  make translations     # Compile all"
	@echo "  sudo make install     # Deploy to system"

# Check if required tools are installed
check-tools:
	@echo "Checking for required Qt6 tools..."
	@which $(LUPDATE) > /dev/null 2>&1 || (echo "Error: lupdate not found. Install with: sudo apt install qt6-l10n-tools" && exit 1)
	@which $(LRELEASE) > /dev/null 2>&1 || (echo "Error: lrelease not found. Install with: sudo apt install qt6-l10n-tools" && exit 1)
	@echo "✓ Qt6 tools found"

# Compile all translations
translations: $(QM_FILES)
	@echo "✓ All translations compiled"

# Rule to compile individual .ts to .qm
%.qm: %.ts
	@echo "Compiling $<..."
	@$(LRELEASE) $< -qm $@

# Extract translatable strings from source code and update .ts files
update-ts: check-tools
	@echo "Extracting translatable strings from QML files..."
	@$(LUPDATE) -recursive components -ts $(TRANSLATIONS)
	@echo "✓ Translation files updated"

# Open translation in Qt Linguist for editing
edit-%: check-tools
	@echo "Opening theme_$*.ts in Qt Linguist..."
	@test -f translations/theme_$*.ts || (echo "Error: translations/theme_$*.ts not found" && exit 1)
	@$(LINGUIST) translations/theme_$*.ts &

# Install to system
install: translations
	@echo "Installing translations to $(THEME_DIR)..."
	@install -d $(THEME_DIR)/translations
	@install -m 644 translations/*.ts $(THEME_DIR)/translations/
	@install -m 644 translations/*.qm $(THEME_DIR)/translations/
	@echo "✓ Translations installed"
	@echo ""
	@read -p "Restart SDDM now? [y/N] " -n 1 -r; \
	echo; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		echo "Restarting SDDM..."; \
		systemctl restart sddm; \
		echo "✓ SDDM restarted"; \
	else \
		echo "Remember to restart SDDM: sudo systemctl restart sddm"; \
	fi

# Clean compiled files
clean:
	@echo "Removing compiled .qm files..."
	@rm -f translations/*.qm
	@echo "✓ Clean complete"

# Show translation statistics
stats: check-tools
	@echo "Translation Statistics:"
	@echo "======================"
	@for ts in $(TRANSLATIONS); do \
		lang=$$(basename $$ts .ts | sed 's/theme_//'); \
		echo ""; \
		echo "$$lang ($$(basename $$ts)):"; \
		$(LRELEASE) -verbose $$ts 2>&1 | grep -E "Generated|translation" | head -2; \
	done
	@echo ""

# Test all translations
test: check-tools
	@echo "Testing translations..."
	@for ts in $(TRANSLATIONS); do \
		lang=$$(basename $$ts .ts | sed 's/theme_//'); \
		echo "Testing $$lang..."; \
		LANGUAGE=$$lang sddm-greeter --test-mode & \
		sleep 2; \
		killall sddm-greeter-qt6 2>/dev/null || true; \
	done
	@echo "✓ Testing complete"

# Create a new translation
new-%: check-tools
	@echo "Creating new translation for $*..."
	@test -f translations/theme_$*.ts && echo "Warning: translations/theme_$*.ts already exists" || true
	@$(LUPDATE) -recursive components -ts translations/theme_$*.ts
	@echo "✓ Created translations/theme_$*.ts"
	@echo "Edit it with: make edit-$*"

# Verify installation
verify:
	@echo "Verifying installation..."
	@echo ""
	@echo "Checking .ts files:"
	@ls -lh $(THEME_DIR)/translations/*.ts 2>/dev/null || echo "  No .ts files found"
	@echo ""
	@echo "Checking .qm files:"
	@ls -lh $(THEME_DIR)/translations/*.qm 2>/dev/null || echo "  No .qm files found"
	@echo ""
	@echo "Checking TranslationManager:"
	@grep -q "qsTr" $(THEME_DIR)/components/TranslationManager.qml && echo "  ✓ Using qsTr() (new system)" || echo "  ✗ Not using qsTr() (old system?)"
	@echo ""
	@echo "Recent SDDM logs:"
	@journalctl -u sddm -b | tail -5

.PHONY: test new-% verify
