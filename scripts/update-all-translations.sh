#!/bin/bash
#
# update-all-translations.sh - Complete translation workflow automation
#
# This script demonstrates the full translation workflow:
# 1. Extract new strings from QML code
# 2. Update TranslationManager.qml
# 3. Optionally push to Transifex
#
# Usage:
#   ./update-all-translations.sh                 # Local update only
#   ./update-all-translations.sh --push          # Also push to Transifex
#   ./update-all-translations.sh --pull-first    # Pull from Transifex first

set -e  # Exit on error

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Parse arguments
PUSH_TO_TRANSIFEX=false
PULL_FROM_TRANSIFEX=false

for arg in "$@"; do
    case $arg in
        --push)
            PUSH_TO_TRANSIFEX=true
            shift
            ;;
        --pull-first)
            PULL_FROM_TRANSIFEX=true
            shift
            ;;
        --help)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --push          Push updated source (en.json) to Transifex after extraction"
            echo "  --pull-first    Pull from Transifex before updating TranslationManager.qml"
            echo "  --help          Show this help message"
            echo ""
            echo "Examples:"
            echo "  $0                    # Local update only"
            echo "  $0 --push             # Extract strings and push to Transifex"
            echo "  $0 --pull-first       # Pull translations, then update"
            exit 0
            ;;
    esac
done

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

echo -e "${GREEN}======================================================${NC}"
echo -e "${GREEN}Complete Translation Update Workflow${NC}"
echo -e "${GREEN}======================================================${NC}"
echo ""

# Step 1: Extract new strings from QML
echo -e "${BLUE}Step 1: Extracting new strings from QML files...${NC}"
if python3 "$SCRIPT_DIR/extract-strings.py" --project-root "$PROJECT_ROOT" --dry-run | grep -q "NEW strings"; then
    echo -e "${YELLOW}New strings found! Adding them to en.json...${NC}"
    python3 "$SCRIPT_DIR/extract-strings.py" --project-root "$PROJECT_ROOT" --auto
    
    NEW_STRINGS_ADDED=true
else
    echo -e "${GREEN}✓ No new strings found - en.json is up to date${NC}"
    NEW_STRINGS_ADDED=false
fi
echo ""

# Step 2: Push to Transifex if requested and new strings were added
if [ "$PUSH_TO_TRANSIFEX" = true ] && [ "$NEW_STRINGS_ADDED" = true ]; then
    echo -e "${BLUE}Step 2: Pushing source to Transifex...${NC}"
    
    if command -v tx &> /dev/null; then
        cd "$PROJECT_ROOT"
        tx push -s
        echo -e "${GREEN}✓ Source pushed to Transifex${NC}"
        echo -e "${YELLOW}Note: Wait for translators to update their translations${NC}"
    else
        echo -e "${RED}✗ Transifex CLI not found. Skipping push.${NC}"
        echo -e "${YELLOW}Install with: pip install transifex-client${NC}"
    fi
    echo ""
fi

# Step 3: Update TranslationManager.qml
echo -e "${BLUE}Step 3: Updating TranslationManager.qml...${NC}"

if [ "$PULL_FROM_TRANSIFEX" = true ]; then
    echo -e "${YELLOW}Pulling latest translations from Transifex...${NC}"
    python3 "$SCRIPT_DIR/translate-manager.py" --project-root "$PROJECT_ROOT"
else
    echo -e "${YELLOW}Using existing JSON files (not pulling from Transifex)...${NC}"
    python3 "$SCRIPT_DIR/translate-manager.py" --project-root "$PROJECT_ROOT" --no-pull
fi
echo ""

# Step 4: Summary
echo -e "${GREEN}======================================================${NC}"
echo -e "${GREEN}Update Complete!${NC}"
echo -e "${GREEN}======================================================${NC}"
echo ""
echo -e "${BLUE}What was done:${NC}"
echo "  1. Scanned QML files for TranslationManager usage"
if [ "$NEW_STRINGS_ADDED" = true ]; then
    echo "  2. Added new strings to en.json"
else
    echo "  2. No new strings to add"
fi
if [ "$PUSH_TO_TRANSIFEX" = true ] && [ "$NEW_STRINGS_ADDED" = true ]; then
    echo "  3. Pushed source to Transifex"
fi
if [ "$PULL_FROM_TRANSIFEX" = true ]; then
    echo "  4. Pulled translations from Transifex"
fi
echo "  5. Updated TranslationManager.qml"
echo ""

echo -e "${BLUE}Next steps:${NC}"
echo "  1. Review changes:"
echo "     git diff sddm-theme/translations/en.json"
echo "     git diff sddm-theme/components/TranslationManager.qml"
echo ""
echo "  2. Test the greeter:"
echo "     sddm-greeter-qt6 --test-mode --theme ./sddm-theme"
echo ""
echo "  3. Test different locales:"
echo "     LANG=es_ES.UTF-8 sddm-greeter-qt6 --test-mode --theme ./sddm-theme"
echo "     LANG=fr_FR.UTF-8 sddm-greeter-qt6 --test-mode --theme ./sddm-theme"
echo ""
echo "  4. Commit changes:"
echo "     git add sddm-theme/translations/ sddm-theme/components/TranslationManager.qml"
echo "     git commit -m \"Update translations\""
echo ""

# Check for uncommitted changes
if [ -d "$PROJECT_ROOT/.git" ]; then
    if ! git -C "$PROJECT_ROOT" diff --quiet sddm-theme/; then
        echo -e "${YELLOW}⚠ Uncommitted changes detected in sddm-theme/${NC}"
        echo "Run 'git status' to see what changed."
        echo ""
    fi
fi

echo -e "${GREEN}Done!${NC}"
