# Directory Structure Reference

## Expected Project Layout

```
project-root/
│
├── scripts/                              # Translation management scripts
│   ├── extract-strings.py                # Extract TranslationManager.* from QML → en.json
│   ├── translate-manager.py              # Pull from Transifex → TranslationManager.qml
│   ├── update-all-translations.sh        # Complete automation workflow
│   ├── TRANSLATION_README.md             # Main overview documentation
│   ├── TRANSLATION_WORKFLOW.md           # Detailed workflow guide
│   └── TRANSLATION_QUICK_REFERENCE.md    # Quick reference cheat sheet
│
└── sddm-theme/                           # SDDM theme base directory
    │
    ├── components/                       # QML components
    │   ├── TranslationManager.qml        # ⚠️ AUTO-GENERATED - Don't edit!
    │   ├── TranslationManager.qml.bak    # Automatic backup
    │   ├── qmldir                         # Singleton registration
    │   ├── LoginPanel.qml                 # Example: Uses TranslationManager.username
    │   ├── PasswordField.qml              # Example: Uses TranslationManager.password
    │   └── ... other QML components
    │
    ├── translations/                     # Translation files
    │   ├── en.json                        # ✅ MASTER FILE - Edit this or use extract-strings.py
    │   ├── en.json.bak                    # Automatic backup
    │   ├── es.json                        # From Transifex - Don't edit manually
    │   ├── fr.json                        # From Transifex - Don't edit manually
    │   ├── de.json                        # From Transifex - Don't edit manually
    │   ├── theme_es.ts                    # Generated Qt translation (reference)
    │   ├── theme_fr.ts                    # Generated Qt translation (reference)
    │   └── theme_de.ts                    # Generated Qt translation (reference)
    │
    ├── theme.conf                         # SDDM theme configuration
    ├── Main.qml                           # Theme entry point
    └── ... other theme files
```

## How Scripts Find Files

### extract-strings.py

When you run from `scripts/` directory:
```bash
cd project-root/scripts/
python3 extract-strings.py
```

The script automatically:
1. Detects it's in `scripts/` directory
2. Uses parent directory as project root
3. Looks for QML files in: `../sddm-theme/components/*.qml`
4. Reads from: `../sddm-theme/translations/en.json`
5. Writes to: `../sddm-theme/translations/en.json`

**Custom project root:**
```bash
python3 extract-strings.py --project-root /path/to/project-root
```

### translate-manager.py

When you run from `scripts/` directory:
```bash
cd project-root/scripts/
python3 translate-manager.py
```

The script automatically:
1. Detects it's in `scripts/` directory
2. Uses parent directory as project root
3. Pulls translations to: `../sddm-theme/translations/*.json`
4. Generates: `../sddm-theme/components/TranslationManager.qml`

**Custom project root:**
```bash
python3 translate-manager.py --project-root /path/to/project-root
```

### update-all-translations.sh

Runs both scripts in sequence from the `scripts/` directory:
```bash
cd project-root/scripts/
bash update-all-translations.sh
```

## Path Resolution Examples

### Example 1: Standard Usage

```bash
# Your location
$ pwd
/home/user/slick-greeter/scripts

# Running extract-strings.py
$ python3 extract-strings.py

# Script resolves:
# - Project root: /home/user/slick-greeter
# - Theme dir: /home/user/slick-greeter/sddm-theme
# - en.json: /home/user/slick-greeter/sddm-theme/translations/en.json
# - QML files: /home/user/slick-greeter/sddm-theme/components/*.qml
```

### Example 2: Running from Project Root

```bash
# Your location
$ pwd
/home/user/slick-greeter

# Running from project root
$ python3 scripts/extract-strings.py

# Script resolves:
# - Project root: /home/user/slick-greeter (parent of scripts/)
# - Theme dir: /home/user/slick-greeter/sddm-theme
# - en.json: /home/user/slick-greeter/sddm-theme/translations/en.json
```

### Example 3: Custom Project Root

```bash
# Your location (anywhere)
$ pwd
/home/user/somewhere-else

# Running with custom root
$ python3 /path/to/extract-strings.py --project-root /home/user/slick-greeter

# Script uses specified root:
# - Project root: /home/user/slick-greeter
# - Theme dir: /home/user/slick-greeter/sddm-theme
```

## Quick Verification

To verify your directory structure is correct:

```bash
# From project root
ls -la scripts/
# Should show: extract-strings.py, translate-manager.py, etc.

ls -la sddm-theme/
# Should show: components/, translations/, theme.conf, Main.qml

ls -la sddm-theme/components/
# Should show: TranslationManager.qml, qmldir, and other .qml files

ls -la sddm-theme/translations/
# Should show: en.json, es.json, fr.json, etc.
```

## What Each Script Expects

### extract-strings.py expects:
- ✅ `sddm-theme/` exists
- ✅ `sddm-theme/components/` exists (contains QML files)
- ✅ `sddm-theme/translations/` exists
- ✅ `sddm-theme/translations/en.json` exists

### translate-manager.py expects:
- ✅ `sddm-theme/` exists
- ✅ `sddm-theme/translations/` exists
- ✅ `sddm-theme/translations/en.json` exists
- ✅ `sddm-theme/components/` exists
- ✅ `.tx/config` exists (Transifex config, created by `tx init`)

## Common Issues

### "No QML files found"

**Problem:** extract-strings.py can't find QML files

**Solution:**
```bash
# Check you're in the right place
pwd

# Should be either project-root/ or project-root/scripts/
# Verify structure exists
ls sddm-theme/components/*.qml

# If not found, specify project root
python3 extract-strings.py --project-root /correct/path
```

### "en.json not found"

**Problem:** Scripts can't find the master translation file

**Solution:**
```bash
# Verify it exists
ls sddm-theme/translations/en.json

# If not, create it
mkdir -p sddm-theme/translations
echo '{}' > sddm-theme/translations/en.json
```

### "Not authenticated with Transifex"

**Problem:** translate-manager.py can't access Transifex

**Solution:**
```bash
# From project root
tx init
# Enter API token from https://www.transifex.com/user/settings/api/
```

## File Ownership

### You Edit:
- ✅ `sddm-theme/translations/en.json` (manually or via extract-strings.py)
- ✅ QML files in `sddm-theme/components/`

### Scripts Generate (Don't Edit):
- ⚠️ `sddm-theme/components/TranslationManager.qml`
- ⚠️ `sddm-theme/translations/{es,fr,de,...}.json` (from Transifex)
- ⚠️ `sddm-theme/translations/theme_*.ts`

### Backups (Auto-created):
- `sddm-theme/components/TranslationManager.qml.bak`
- `sddm-theme/translations/en.json.bak`

## Summary

**Correct structure:**
```
project-root/
├── scripts/          ← Scripts live here
└── sddm-theme/       ← Theme lives here
    ├── components/   ← QML components including TranslationManager.qml
    └── translations/ ← JSON translation files
```

**Run from:**
- `project-root/scripts/` ← Recommended
- `project-root/` ← Also works
- Anywhere with `--project-root` option

**Key paths scripts use:**
- QML files: `sddm-theme/components/*.qml`
- Master file: `sddm-theme/translations/en.json`
- Output: `sddm-theme/components/TranslationManager.qml`
