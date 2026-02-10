# Translation Workflow Guide

Complete guide for managing translations in slickSDDM theme, from extracting strings from QML code to pushing them to Transifex.

## Overview

The slickSDDM theme uses a **three-step translation workflow**:

1. **Extract strings from QML** → `extract-strings.py` finds TranslationManager usage in QML files
2. **Merge into en.json** → New strings are added to the master English translation file
3. **Generate QML code** → `translate-manager.py` converts JSON to embedded QML properties

```
QML Files → extract-strings.py → en.json → Transifex → translate-manager.py → TranslationManager.qml
```

## Quick Reference

| Task | Command |
|------|---------|
| Find new strings in QML | `python3 extract-strings.py --dry-run` |
| Add new strings to en.json | `python3 extract-strings.py` |
| Push to Transifex | `tx push -s` |
| Pull from Transifex | `tx pull -a` |
| Update TranslationManager.qml | `python3 translate-manager.py` |
| Full workflow | See [Complete Workflow](#complete-workflow) below |

## The Scripts

### 1. extract-strings.py - Find Translation Strings

**Purpose:** Scans QML files to find all `TranslationManager.propertyName` references and merges new ones into en.json.

**What it does:**
- Scans all `.qml` files (except TranslationManager.qml itself)
- Finds patterns like `TranslationManager.username`, `TranslationManager.login`, etc.
- Compares with existing en.json
- Reports new strings and suggests values
- Merges new strings into en.json

**Usage:**

```bash
# Dry run - see what would change without making changes
python3 extract-strings.py --dry-run

# Interactive mode - prompts for each new string
python3 extract-strings.py

# Auto mode - uses suggested values without prompts
python3 extract-strings.py --auto
```

**Example Output:**

```
============================================================
QML String Extractor - Find new translation strings
============================================================

ℹ Scanning 15 QML files...
✓ Found 20 unique string keys in QML files
✓ Loaded 18 existing strings from en.json

============================================================
Analysis Results
============================================================

Found 2 NEW strings to add:

  welcomeMessage
    Suggested: "Welcome message"
  
  Used in:
    LoginPanel.qml:45
      text: TranslationManager.welcomeMessage
    UserList.qml:120
      tooltip: TranslationManager.welcomeMessage

  sessionTimeout
    Suggested: "Session timeout"
  
  Used in:
    SessionManager.qml:67
      message: TranslationManager.sessionTimeout

Found 1 UNUSED strings (in en.json but not in QML):
  - oldString: "This string is no longer used"

⚠ These strings might be obsolete or used in commented code
```

**Interactive Prompting:**

```
[1/2] Key: welcomeMessage
Suggested: "Welcome message"

Used in:
  LoginPanel.qml:45
    text: TranslationManager.welcomeMessage

Enter value (or press Enter to use suggestion): Welcome to Ubuntu Budgie!
✓ Using: "Welcome to Ubuntu Budgie!"
```

### 2. translate-manager.py - Generate QML Code

**Purpose:** Pulls translations from Transifex and generates embedded QML code in TranslationManager.qml.

**What it does:**
- Pulls translations from Transifex (optional)
- Validates all translation files
- Converts JSON to QML `readonly property string` declarations
- Creates automatic backups

**Usage:**

```bash
# Full update (pull from Transifex + generate)
python3 translate-manager.py

# Update without pulling (use existing JSON files)
python3 translate-manager.py --no-pull

# Validate only (no changes)
python3 translate-manager.py --validate-only
```

## Complete Workflow

### When Adding New Strings to QML

**Scenario:** You're developing a new feature and need to add translatable text.

1. **Write your QML code with TranslationManager references:**

   ```qml
   // LoginPanel.qml
   Text {
       text: TranslationManager.welcomeMessage
   }
   
   Button {
       text: TranslationManager.continueButton
   }
   ```

2. **Extract new strings from QML:**

   ```bash
   # See what's new (dry run)
   python3 extract-strings.py --dry-run
   
   # Add them to en.json (interactive)
   python3 extract-strings.py
   
   # Or use auto mode for quick additions
   python3 extract-strings.py --auto
   ```

3. **Update TranslationManager.qml with the new strings:**

   ```bash
   python3 translate-manager.py --no-pull
   ```

4. **Test your changes:**

   ```bash
   # Check that the strings appear in TranslationManager.qml
   grep "welcomeMessage" sddm-theme/components/TranslationManager.qml
   
   # Test the greeter
   sddm-greeter-qt6 --test-mode --theme ./sddm-theme
   ```

5. **Push source strings to Transifex for translation:**

   ```bash
   tx push -s
   ```

6. **Commit your changes:**

   ```bash
   git add sddm-theme/translations/en.json
   git add sddm-theme/components/TranslationManager.qml
   git commit -m "Add welcome message and continue button strings"
   ```

### Regular Translation Updates

**Scenario:** Translators have updated translations on Transifex, and you want to pull the latest.

1. **Pull and update everything:**

   ```bash
   python3 translate-manager.py
   ```
   
   This does:
   - Pulls from Transifex
   - Validates translations
   - Updates TranslationManager.qml

2. **Review the changes:**

   ```bash
   git diff sddm-theme/components/TranslationManager.qml
   git diff sddm-theme/translations/
   ```

3. **Test with different locales:**

   ```bash
   LANG=es_ES.UTF-8 sddm-greeter-qt6 --test-mode --theme ./sddm-theme
   LANG=fr_FR.UTF-8 sddm-greeter-qt6 --test-mode --theme ./sddm-theme
   ```

4. **Commit:**

   ```bash
   git commit -am "Update translations from Transifex"
   ```

### Before a Release

**Scenario:** You're preparing a release and want to ensure all translations are current.

1. **Extract any new strings that might have been added:**

   ```bash
   python3 extract-strings.py --dry-run
   ```
   
   If new strings are found:
   
   ```bash
   python3 extract-strings.py --auto
   tx push -s
   ```

2. **Pull latest translations:**

   ```bash
   python3 translate-manager.py
   ```

3. **Validate translation completeness:**

   ```bash
   python3 translate-manager.py --validate-only
   ```

4. **Review validation report:**

   ```
   ℹ Validating translations...
     ✓ es: 100.0% complete
     ✓ fr: 100.0% complete
     ⚠ de: 95.5% complete
     ⚠ de: Missing keys: sessionTimeout, welcomeMessage
   ```

5. **If critical strings are missing, contact translators or add temporary English fallbacks**

6. **Final update and commit:**

   ```bash
   python3 translate-manager.py
   git commit -am "Final translation update for release"
   ```

## File Structure

```
sddm-theme/
├── components/
│   ├── TranslationManager.qml         # Generated QML with embedded translations
│   ├── TranslationManager.qml.bak     # Automatic backup
│   ├── qmldir                          # Singleton registration
│   ├── LoginPanel.qml                  # Uses: TranslationManager.username
│   ├── PasswordField.qml               # Uses: TranslationManager.password
│   └── ... other QML components
└── translations/
    ├── en.json                         # English source (master file)
    ├── es.json                         # Spanish (from Transifex)
    ├── fr.json                         # French (from Transifex)
    ├── de.json                         # German (from Transifex)
    ├── en.json.bak                     # Backup (created by extract-strings.py)

scripts/
├── extract-strings.py                  # Extract strings from QML
└── translate-manager.py                # Generate TranslationManager.qml
```

## Understanding the Files

### en.json - Master Translation File

This is the **source of truth** for all translatable strings. It's manually maintained.

```json
{
  "pressAnyKey": "Press any key",
  "username": "Username",
  "password": "Password",
  "login": "Login",
  "welcomeMessage": "Welcome to Ubuntu Budgie!"
}
```

**Rules:**
- Keys must be valid JavaScript identifiers (camelCase recommended)
- Values are the English text
- Keys should be descriptive (`welcomeMessage` not `msg1`)
- Modified manually or via `extract-strings.py`
- Never edit other language JSON files manually

### TranslationManager.qml - Generated Code

This file is **automatically generated** by `translate-manager.py`. Do not edit manually.

```qml
pragma Singleton
import QtQuick

QtObject {
    // Basic strings
    readonly property string pressAnyKey: qsTr("Press any key")
    readonly property string username: qsTr("Username")
    readonly property string password: qsTr("Password")
    readonly property string login: qsTr("Login")
    
    // Other strings
    readonly property string welcomeMessage: qsTr("Welcome to Ubuntu Budgie!")
    
    // Parameterized strings
    function selectUserNamed(name) {
        return qsTr("Select user %1").arg(name)
    }
}
```

**How it works:**
- Each JSON key becomes a `readonly property string`
- Values are wrapped in `qsTr()` for Qt's translation system
- SDDM's Qt runtime handles the actual translation lookup
- Organized into categories for readability

### Usage in QML Components

Components import and use the singleton:

```qml
import QtQuick
import "." as Components

Item {
    // Simple property binding
    Text {
        text: TranslationManager.username
    }
    
    // In a function
    Button {
        onClicked: {
            console.log(TranslationManager.login)
        }
    }
    
    // Parameterized string
    Text {
        text: TranslationManager.selectUserNamed(currentUser)
    }
}
```

## How Strings Are Suggested

The `extract-strings.py` script uses smart heuristics to suggest translation values:

**Pattern: Insert spaces before capitals, capitalize first letter**

| Key | Suggested Value |
|-----|----------------|
| `username` | "Username" |
| `loginFailed` | "Login failed" |
| `pressAnyKey` | "Press any key" |
| `noKeyboardLayoutsConfigured` | "No keyboard layouts configured" |
| `selectUserNamed` | "Select user named" |

**You can override suggestions in interactive mode!**

## Parameterized Strings

For strings with dynamic content, use the `%1`, `%2` placeholder pattern:

**In en.json:**
```json
{
  "selectUserNamed": "Select user %1",
  "errorOnLine": "Error on line %1: %2"
}
```

**After running translate-manager.py, becomes:**
```qml
function selectUserNamed(name) {
    return qsTr("Select user %1").arg(name)
}

function errorOnLine(lineNum, message) {
    return qsTr("Error on line %1: %2").arg(lineNum).arg(message)
}
```

**Note:** You'll need to manually add the function wrapper to TranslationManager.qml for now. Future versions may auto-detect parameterized strings.

## Troubleshooting

### "No TranslationManager strings found"

**Problem:** `extract-strings.py` doesn't find any strings.

**Solutions:**
- Check that you're running from the correct directory
- Verify QML files use `TranslationManager.propertyName` pattern
- Ensure QML files are in `sddm-theme/` directory
- Try: `python3 extract-strings.py --project-root /path/to/project`

### "String already exists in en.json"

**Problem:** You want to change an existing translation value.

**Solution:** Edit `en.json` directly, then run:

```bash
python3 translate-manager.py --no-pull
tx push -s  # Push updated source to Transifex
```

### Unused strings reported

**Problem:** `extract-strings.py` reports strings in en.json that aren't used in QML.

**Possible causes:**
- String was removed from code but not from en.json (can be deleted)
- String is in commented code (should be removed)
- String is used dynamically (false positive - keep it)
- String is used in code not yet committed (keep it)

**Action:** Review each unused string and remove if truly obsolete.

### Translation doesn't appear in SDDM

**Checklist:**
1. Is the string in en.json? → Run `cat sddm-theme/translations/en.json | grep yourKey`
2. Is it in TranslationManager.qml? → Run `grep yourKey sddm-theme/components/TranslationManager.qml`
3. Is SDDM using the right locale? → Check `echo $LANG`
4. Did you restart SDDM? → Run `sudo systemctl restart sddm`

## Best Practices

### String Key Naming

✅ **Good:**
- `username` - Clear, concise
- `loginFailed` - Action + state
- `capslockWarning` - Context + type
- `noKeyboardLayoutsConfigured` - Descriptive

❌ **Bad:**
- `str1`, `text1` - Not descriptive
- `the_username` - Use camelCase
- `USERNAME` - Not a constant

### Workflow Discipline

1. **Always run dry-run first** → See changes before making them
2. **Review suggestions** → Auto-generated values might need tweaking
3. **Test before committing** → Run greeter in test mode
4. **Keep en.json as master** → Never edit other language JSONs
5. **Commit atomically** → Translation changes in separate commits

### Translation Quality

- **Be concise** → Greeter has limited space
- **Be consistent** → Use same terminology throughout
- **Add context in comments** → If a string is ambiguous
- **Test with long translations** → German/French can be 30% longer

## Integration with CI/CD

### Automated String Extraction

```yaml
# .github/workflows/check-translations.yml
name: Check Translations

on: [pull_request]

jobs:
  check-strings:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Check for new strings
        run: |
          python3 scripts/extract-strings.py --dry-run > /tmp/strings.txt
          if grep -q "NEW strings" /tmp/strings.txt; then
            echo "::warning::New translatable strings detected"
            cat /tmp/strings.txt
          fi
```

### Weekly Translation Updates

```yaml
# .github/workflows/update-translations.yml
name: Update Translations

on:
  schedule:
    - cron: '0 0 * * 0'  # Weekly
  workflow_dispatch:

jobs:
  update:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.10'
      
      - name: Install Transifex CLI
        run: pip install transifex-client
      
      - name: Pull translations
        env:
          TX_TOKEN: ${{ secrets.TX_TOKEN }}
        run: |
          echo "$TX_TOKEN" | tx init --token -
          python3 scripts/translate-manager.py
      
      - name: Create PR
        uses: peter-evans/create-pull-request@v5
        with:
          commit-message: 'Update translations from Transifex'
          title: 'chore: Update translations'
          body: 'Automated weekly translation update'
          branch: translations-auto-update
```

## Related Documentation

- [TRANSLATION_UPDATE_GUIDE.md](TRANSLATION_UPDATE_GUIDE.md) - Guide for translate-manager.py
- [TRANSLATIONS.md](../TRANSLATIONS.md) - Full translation system architecture
- [TESTING_TRANSLATIONS.md](TESTING_TRANSLATIONS.md) - How to test translations

## Summary

**Key Concepts:**
1. QML code references `TranslationManager.propertyName`
2. `extract-strings.py` finds these references and merges them into `en.json`
3. `en.json` is pushed to Transifex for translators
4. Translators work on Transifex
5. `translate-manager.py` pulls translations and generates `TranslationManager.qml`
6. SDDM loads `TranslationManager.qml` and uses Qt's translation system

**The Loop:**
```
Code → Extract → en.json → Transifex → Pull → TranslationManager.qml → Code
```

**Two Scripts:**
- `extract-strings.py` - QML → en.json (developer workflow)
- `translate-manager.py` - Transifex → TranslationManager.qml (update workflow)

**Remember:**
- Extract before releasing
- Update regularly from Transifex
- Never edit TranslationManager.qml manually
- Keep en.json as the source of truth
