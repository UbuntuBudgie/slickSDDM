#!/bin/bash
#
# verify-structure.sh - Verify the project directory structure is correct
#
# Run this script to check if all required directories and files exist
# for the translation system to work properly.

set -e

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get script directory and assume it's in scripts/
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

echo -e "${BLUE}================================================${NC}"
echo -e "${BLUE}Directory Structure Verification${NC}"
echo -e "${BLUE}================================================${NC}"
echo ""

echo -e "${BLUE}Project root detected: ${NC}$PROJECT_ROOT"
echo ""

# Check function
check_exists() {
    local path="$1"
    local type="$2"  # "file" or "dir"
    local required="$3"  # "required" or "optional"
    
    if [ "$type" = "dir" ]; then
        if [ -d "$path" ]; then
            echo -e "${GREEN}✓${NC} Directory exists: $path"
            return 0
        else
            if [ "$required" = "required" ]; then
                echo -e "${RED}✗${NC} Missing required directory: $path"
                return 1
            else
                echo -e "${YELLOW}⚠${NC} Optional directory missing: $path"
                return 0
            fi
        fi
    else
        if [ -f "$path" ]; then
            echo -e "${GREEN}✓${NC} File exists: $path"
            return 0
        else
            if [ "$required" = "required" ]; then
                echo -e "${RED}✗${NC} Missing required file: $path"
                return 1
            else
                echo -e "${YELLOW}⚠${NC} Optional file missing: $path"
                return 0
            fi
        fi
    fi
}

ERRORS=0

# Check directories
echo -e "${BLUE}Checking directories...${NC}"
check_exists "$PROJECT_ROOT/scripts" "dir" "required" || ERRORS=$((ERRORS+1))
check_exists "$PROJECT_ROOT/sddm-theme" "dir" "required" || ERRORS=$((ERRORS+1))
check_exists "$PROJECT_ROOT/sddm-theme/components" "dir" "required" || ERRORS=$((ERRORS+1))
check_exists "$PROJECT_ROOT/sddm-theme/translations" "dir" "required" || ERRORS=$((ERRORS+1))
echo ""

# Check script files
echo -e "${BLUE}Checking script files...${NC}"
check_exists "$PROJECT_ROOT/scripts/extract-strings.py" "file" "required" || ERRORS=$((ERRORS+1))
check_exists "$PROJECT_ROOT/scripts/translate-manager.py" "file" "required" || ERRORS=$((ERRORS+1))
check_exists "$PROJECT_ROOT/scripts/update-all-translations.sh" "file" "optional"
echo ""

# Check translation files
echo -e "${BLUE}Checking translation files...${NC}"
check_exists "$PROJECT_ROOT/sddm-theme/translations/en.json" "file" "required" || ERRORS=$((ERRORS+1))
check_exists "$PROJECT_ROOT/sddm-theme/components/TranslationManager.qml" "file" "optional"
check_exists "$PROJECT_ROOT/sddm-theme/components/qmldir" "file" "optional"
echo ""

# Check for QML files
echo -e "${BLUE}Checking for QML files...${NC}"
QML_COUNT=$(find "$PROJECT_ROOT/sddm-theme/components" -maxdepth 1 -name "*.qml" ! -name "TranslationManager.qml" 2>/dev/null | wc -l)
if [ "$QML_COUNT" -gt 0 ]; then
    echo -e "${GREEN}✓${NC} Found $QML_COUNT QML component files"
else
    echo -e "${YELLOW}⚠${NC} No QML component files found in sddm-theme/components/"
fi
echo ""

# Check Transifex config
echo -e "${BLUE}Checking Transifex configuration...${NC}"
if [ -d "$PROJECT_ROOT/.tx" ]; then
    echo -e "${GREEN}✓${NC} Transifex configuration exists (.tx/)"
    check_exists "$PROJECT_ROOT/.tx/config" "file" "optional"
else
    echo -e "${YELLOW}⚠${NC} Transifex not initialized (.tx/ missing)"
    echo -e "  ${BLUE}Run:${NC} tx init"
fi
echo ""

# Summary
echo -e "${BLUE}================================================${NC}"
echo -e "${BLUE}Summary${NC}"
echo -e "${BLUE}================================================${NC}"
echo ""

if [ $ERRORS -eq 0 ]; then
    echo -e "${GREEN}✓ All required files and directories found!${NC}"
    echo ""
    echo -e "${BLUE}Your directory structure is correct. You can now:${NC}"
    echo "  1. Extract strings: python3 scripts/extract-strings.py"
    echo "  2. Update translations: python3 scripts/translate-manager.py"
    echo ""
else
    echo -e "${RED}✗ Found $ERRORS missing required items${NC}"
    echo ""
    echo -e "${YELLOW}To fix:${NC}"
    echo "  1. Ensure you're running from the project root"
    echo "  2. Create missing directories"
    echo "  3. Check DIRECTORY_STRUCTURE.md for details"
    echo ""
    exit 1
fi

# Additional checks
echo -e "${BLUE}Additional Information:${NC}"
echo ""

# Check Python
if command -v python3 &> /dev/null; then
    PYTHON_VERSION=$(python3 --version 2>&1 | awk '{print $2}')
    echo -e "${GREEN}✓${NC} Python 3 installed: $PYTHON_VERSION"
else
    echo -e "${RED}✗${NC} Python 3 not found"
fi

# Check Transifex CLI
if command -v tx &> /dev/null; then
    TX_VERSION=$(tx --version 2>&1 | head -n1)
    echo -e "${GREEN}✓${NC} Transifex CLI installed: $TX_VERSION"
else
    echo -e "${YELLOW}⚠${NC} Transifex CLI not installed (optional)"
    echo -e "  ${BLUE}Install:${NC} pip install transifex-client"
fi

echo ""
echo -e "${BLUE}For more information, see:${NC}"
echo "  - DIRECTORY_STRUCTURE.md - Detailed structure documentation"
echo "  - TRANSLATION_README.md - Complete system overview"
echo "  - TRANSLATION_QUICK_REFERENCE.md - Quick command reference"
echo ""
