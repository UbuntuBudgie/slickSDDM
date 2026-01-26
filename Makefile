# slickSDDM Theme - Translation Management Makefile

.PHONY: help translations-pull translations-test translations-push translations-init translations-setup-initial translations-stats install-tx-cli

help:
	@echo "slickSDDM Theme - Translation Management"
	@echo "=================================================="
	@echo ""
	@echo "Available targets:"
	@echo "  translations-pull          - Pull latest translations from Transifex"
	@echo "  translations-test          - Run translation test suite"
	@echo "  translations-push          - Push source strings to Transifex"
	@echo "  translations-init          - Initialize Transifex configuration"
	@echo "  translations-setup-initial - Initial setup (run once to seed Transifex)"
	@echo "  translations-stats         - Show translation statistics"
	@echo "  install-tx-cli             - Install Transifex CLI"
	@echo ""

install-tx-cli:
	@echo "Installing Transifex CLI..."
	pip3 install --user transifex-client
	@echo "Done! You may need to add ~/.local/bin to your PATH"

translations-init:
	@echo "Initializing Transifex configuration..."
	tx init --token=$(TX_TOKEN)
	@echo "Done! You can now pull/push translations"

translations-setup-initial:
	@echo "Running initial Transifex setup..."
	@bash scripts/tx-setup-initial.sh

translations-pull:
	@echo "Pulling translations from Transifex..."
	@bash scripts/tx-pull.sh

translations-push:
	@echo "Pushing source strings to Transifex..."
	tx push -s

translations-test:
	@echo "Running translation test suite..."
	@python3 tests/test_translations.py

translations-stats:
	@echo "Translation Statistics"
	@echo "======================"
	@echo ""
	@tx status
	@echo ""
	@echo "Local files:"
	@ls -1 sddm-theme/translations/*.json | wc -l | xargs echo "  Translation files:"
	@python3 -c "import json; data = json.load(open('sddm-theme/translations/en.json')); print(f'  Source strings: {len(data)}')"

# Development targets
dev-setup: install-tx-cli translations-init translations-setup-initial
	@echo "Development environment setup complete!"

dev-test: translations-pull translations-test
	@echo "Translation testing complete!"
