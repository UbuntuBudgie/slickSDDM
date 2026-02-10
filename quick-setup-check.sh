#!/bin/bash
#
# quick-setup-check.sh - Quick check for required files
#

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Checking translation scripts setup..."
echo ""
echo "Script directory: $SCRIPT_DIR"
echo ""

check_file() {
    if [ -f "$1" ]; then
        echo "✓ $2"
    else
        echo "✗ MISSING: $2"
        echo "  Expected at: $1"
    fi
}

check_file "$SCRIPT_DIR/extract-strings.py" "extract-strings.py"
check_file "$SCRIPT_DIR/translate-manager.py" "translate-manager.py"
check_file "$SCRIPT_DIR/update-all-translations.sh" "update-all-translations.sh"

echo ""
echo "If any files are missing, copy them from the downloaded files:"
echo "  cp translate-manager.py $SCRIPT_DIR/"
echo "  cp extract-strings.py $SCRIPT_DIR/"
echo "  cp update-all-translations.sh $SCRIPT_DIR/"
