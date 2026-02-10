#!/bin/bash
# Transifex translation pull script for slickSDDM Theme

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
TRANSLATIONS_DIR="$PROJECT_ROOT/sddm-theme/translations"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}slickSDDM Theme - Translation Updater${NC}"
echo "=============================================="

# Check if Transifex CLI is installed
if ! command -v tx &> /dev/null; then
    echo -e "${RED}Error: Transifex CLI (tx) is not installed.${NC}"
    echo "Please install it with: pip install transifex-client"
    exit 1
fi

# Check if we're authenticated
if ! tx status &> /dev/null; then
    echo -e "${YELLOW}Warning: Not authenticated with Transifex.${NC}"
    echo "Please run: tx init"
    exit 1
fi

# Create translations directory if it doesn't exist
mkdir -p "$TRANSLATIONS_DIR"

# Pull all translations from Transifex
echo -e "${GREEN}Pulling translations from Transifex...${NC}"
cd "$PROJECT_ROOT"

# Pull only translations with minimum 30% completion
tx pull -a --minimum-perc=30

# Validate JSON files
echo -e "${GREEN}Validating translation files...${NC}"
INVALID_FILES=0

for file in "$TRANSLATIONS_DIR"/*.json; do
    if [ -f "$file" ]; then
        filename=$(basename "$file")
        if python3 -m json.tool "$file" > /dev/null 2>&1; then
            echo -e "  ✓ $filename is valid"
        else
            echo -e "${RED}  ✗ $filename is invalid${NC}"
            INVALID_FILES=$((INVALID_FILES + 1))
        fi
    fi
done

if [ $INVALID_FILES -gt 0 ]; then
    echo -e "${RED}Error: $INVALID_FILES invalid translation file(s) found.${NC}"
    exit 1
fi

# Count available translations
TRANSLATION_COUNT=$(find "$TRANSLATIONS_DIR" -name "*.json" | wc -l)
echo -e "${GREEN}Successfully pulled $TRANSLATION_COUNT translation file(s).${NC}"

# List available languages
echo -e "\n${GREEN}Available languages:${NC}"
for file in "$TRANSLATIONS_DIR"/*.json; do
    if [ -f "$file" ]; then
        lang=$(basename "$file" .json)
        echo "  - $lang"
    fi
done

echo -e "\n${GREEN}Translation update complete!${NC}"
