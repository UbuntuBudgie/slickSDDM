# SlickSDDM Translation System

Complete documentation for the slickSDDM translation management system.

## 📋 Table of Contents

- [Overview](#overview)
- [The Files](#the-files)
- [Quick Start](#quick-start)
- [Detailed Workflows](#detailed-workflows)
- [Architecture](#architecture)
- [For Developers](#for-developers)
- [For Translators](#for-translators)
- [For Maintainers](#for-maintainers)

## Overview

The slickSDDM theme uses a **dual-script translation system** that works around SDDM's limitation of not being able to load external translation files:

```
┌─────────────────────────────────────────────────────────────┐
│                    Translation Flow                          │
└─────────────────────────────────────────────────────────────┘

  QML Files                     en.json                  Transifex
  ┌─────────┐                   ┌─────┐                   ┌────┐
  │ Text {  │                   │ {   │                   │ es │
  │   text: │  extract-strings  │ "k" │   tx push -s      │ fr │
  │   TM.*  │  ────────────────>│ "v" │  ──────────────>  │ de │
  │ }       │      .py          │ }   │                   │ .. │
  └─────────┘                   └─────┘                   └────┘
                                   │                         │
                                   │                         │
                                   │         tx pull -a      │
                                   │    <────────────────────┘
                                   │
                              translate-manager.py
                                   │
                                   ▼
                          TranslationManager.qml
                          ┌──────────────────┐
                          │ readonly prop    │
                          │ string k: qsTr() │
                          └──────────────────┘
```

## The Files

### Scripts

| File | Purpose | Use When |
|------|---------|----------|
| **extract-strings.py** | Find TranslationManager usage in QML → merge into en.json | After coding new UI with translatable text |
| **translate-manager.py** | Pull from Transifex → generate TranslationManager.qml | Regular updates, before releases |
| **update-all-translations.sh** | Automate the complete workflow | Quick all-in-one update |

### Data Files

| File | Purpose | Edit? |
|------|---------|-------|
| **en.json** | Master English translation source | ✅ Yes (manually or via extract-strings.py) |
| **es.json, fr.json, etc.** | Translated strings from Transifex | ❌ No (auto-generated) |
| **TranslationManager.qml** | Generated QML singleton with embedded translations | ❌ No (auto-generated) |

### Documentation

| File | Purpose |
|------|---------|
| **TRANSLATION_WORKFLOW.md** | Complete detailed workflow guide |
| **TRANSLATION_QUICK_REFERENCE.md** | One-page cheat sheet |
| **README.md** | This file - overview and index |

## Quick Start

### For Developers Adding New Strings

```bash
# 1. Write QML code with TranslationManager
#    Text { text: TranslationManager.myNewString }

# 2. Extract and add to en.json
python3 scripts/extract-strings.py --auto

# 3. Update TranslationManager.qml
python3 scripts/translate-manager.py --no-pull

# 4. Test
sddm-greeter-qt6 --test-mode --theme ./sddm-theme
```

### For Maintainers Updating Translations

```bash
# Pull from Transifex and update everything
python3 scripts/translate-manager.py

# Or use the automation script
bash scripts/update-all-translations.sh --pull-first
```

### For Translators

Work directly on Transifex:
1. Go to https://www.transifex.com/ubuntu-budgie/slicksddm/
2. Select your language
3. Translate strings in the web interface
4. Done! Maintainers will pull your translations

## Detailed Workflows

### 1. Adding New Translatable Strings

**What:** You're developing a feature and need to add new translatable text.

**Steps:**

1. **Write your QML code:**
   ```qml
   Text {
       text: TranslationManager.welcomeMessage
   }
   ```

2. **Extract new strings:**
   ```bash
   # See what's new
   python3 extract-strings.py --dry-run
   
   # Add them (interactive mode)
   python3 extract-strings.py
   
   # Or auto-add with suggestions
   python3 extract-strings.py --auto
   ```

3. **Update TranslationManager.qml:**
   ```bash
   python3 translate-manager.py --no-pull
   ```

4. **Test:**
   ```bash
   sddm-greeter-qt6 --test-mode --theme ./sddm-theme
   ```

5. **Push to Transifex (when ready):**
   ```bash
   tx push -s
   ```

**See:** [TRANSLATION_WORKFLOW.md](TRANSLATION_WORKFLOW.md) → "When Adding New Strings to QML"

### 2. Regular Translation Updates

**What:** Translators have updated translations on Transifex.

**Steps:**

```bash
# One command does it all
python3 translate-manager.py

# Or use the automation script
bash update-all-translations.sh --pull-first
```

**See:** [TRANSLATION_WORKFLOW.md](TRANSLATION_WORKFLOW.md) → "Regular Translation Updates"

### 3. Pre-Release Checklist

**What:** You're preparing a release.

**Steps:**

```bash
# 1. Extract any new strings that were added
python3 extract-strings.py --dry-run

# 2. Pull latest translations
python3 translate-manager.py

# 3. Validate completeness
python3 translate-manager.py --validate-only

# 4. Test multiple locales
LANG=es_ES.UTF-8 sddm-greeter-qt6 --test-mode
LANG=fr_FR.UTF-8 sddm-greeter-qt6 --test-mode

# 5. Commit
git commit -am "Final translation update for v1.x.x"
```

**See:** [TRANSLATION_WORKFLOW.md](TRANSLATION_WORKFLOW.md) → "Before a Release"

## Architecture

### Why This Approach?

**Problem:** SDDM cannot load external `.qm` translation files at runtime.

**Solution:** Embed translations directly into QML code as `readonly property string` declarations wrapped in `qsTr()`.

### How It Works

1. **Developer writes QML:**
   ```qml
   Text { text: TranslationManager.username }
   ```

2. **extract-strings.py finds these references** and adds them to `en.json`:
   ```json
   { "username": "Username" }
   ```

3. **en.json is pushed to Transifex** for translators to work on.

4. **Translators create** `es.json`, `fr.json`, etc. on Transifex.

5. **translate-manager.py generates TranslationManager.qml:**
   ```qml
   readonly property string username: qsTr("Username")
   ```

6. **Qt's translation system** (via `qsTr()`) handles the actual runtime translation lookup based on system locale.

### Key Concepts

- **en.json** = Source of truth, manually maintained
- **Other JSON files** = From Transifex, auto-generated
- **TranslationManager.qml** = Generated QML code, never edit manually
- **qsTr()** = Qt's translation function that enables runtime translation

## For Developers

### Adding a New String

```qml
// 1. Use TranslationManager in your QML
Text {
    text: TranslationManager.myNewString
}

// 2. Run extract-strings.py
// 3. The string is now available!
```

### String Naming Convention

✅ **Good:**
- `username` - Clear, concise
- `loginFailed` - Action + state, camelCase
- `noUsersFound` - Descriptive

❌ **Bad:**
- `str1` - Not descriptive
- `the_username` - Use camelCase
- `USERNAME` - Not a constant

### Parameterized Strings

For dynamic content:

```qml
// In code:
Text {
    text: TranslationManager.selectUserNamed("Alice")
}
```

**Note:** You may need to manually add the function wrapper to `TranslationManager.qml` for parameterized strings. Example:

```qml
function selectUserNamed(name) {
    return qsTr("Select user %1").arg(name)
}
```

### Testing Translations

```bash
# Test with specific locale
LANG=es_ES.UTF-8 sddm-greeter-qt6 --test-mode --theme ./sddm-theme

# Or set system locale
export LANG=fr_FR.UTF-8
sudo systemctl restart sddm
```

### Common Commands

```bash
# Find new strings
python3 extract-strings.py --dry-run

# Add new strings (auto)
python3 extract-strings.py --auto

# Update QML without Transifex
python3 translate-manager.py --no-pull

# Full update
python3 translate-manager.py
```

**See:** [TRANSLATION_QUICK_REFERENCE.md](TRANSLATION_QUICK_REFERENCE.md)

## For Translators

### Where to Translate

**On Transifex:** https://www.transifex.com/ubuntu-budgie/slicksddm/

### Workflow

1. Select your language
2. Translate strings in the web interface
3. Save
4. Done! Maintainers will pull your work

### Translation Tips

- **Be concise** - UI space is limited
- **Maintain tone** - Professional but friendly
- **Test if possible** - Longer translations (German, French) should be tested
- **Use placeholders correctly** - `%1`, `%2` must be preserved in order
- **Ask questions** - Use Transifex comments if context is unclear

### Context

Most strings are self-explanatory, but here's context for tricky ones:

| String | Context |
|--------|---------|
| `pressAnyKey` | Shown on initial screen, prompts user to begin |
| `capslockWarning` | Warning when Caps Lock is on during password entry |
| `selectUserNamed` | Dynamic string - `%1` is replaced with username |
| `noKeyboardLayoutsConfigured` | Error when SDDM config is missing keyboard layouts |

## For Maintainers

### Regular Maintenance

```bash
# Weekly/monthly translation sync
python3 translate-manager.py
git commit -am "Update translations"
```

### When New Strings Are Added

```bash
# 1. Developers run extract-strings.py (done by developer)
# 2. Review en.json changes
git diff sddm-theme/translations/en.json

# 3. Push source to Transifex
tx push -s

# 4. Wait for translators, then pull
python3 translate-manager.py
```

### Validation

```bash
# Check translation completeness
python3 translate-manager.py --validate-only
```

**Output:**
```
✓ es: 100.0% complete
✓ fr: 100.0% complete
⚠ de: 95.5% complete
⚠ de: Missing keys: sessionTimeout
```

### Before Release

```bash
# Complete pre-release workflow
bash update-all-translations.sh --pull-first

# Validate
python3 translate-manager.py --validate-only

# If issues, contact translators or add English fallbacks temporarily
```

### CI/CD Integration

See [TRANSLATION_WORKFLOW.md](TRANSLATION_WORKFLOW.md) → "Integration with CI/CD" for GitHub Actions examples.

## Troubleshooting

### extract-strings.py finds no strings

- Ensure QML files use `TranslationManager.propertyName` pattern
- Run from project root or use `--project-root`
- Check that QML files are in `sddm-theme/` directory

### Translations don't appear

- Verify `TranslationManager.qml` has the property
- Check system locale: `echo $LANG`
- Restart SDDM: `sudo systemctl restart sddm`
- Verify translation file exists (e.g., `es.json` for Spanish)

### Transifex authentication failed

```bash
tx init
# Enter your API token from https://www.transifex.com/user/settings/api/
```

### Script errors

```bash
# Check Python version (needs 3.6+)
python3 --version

# Check Transifex CLI
tx --version

# Validate JSON syntax
python3 -m json.tool sddm-theme/translations/en.json
```

## Project Structure

```
project-root/
├── scripts/
│   ├── extract-strings.py              # QML → en.json
│   ├── translate-manager.py            # Transifex → TranslationManager.qml
│   ├── update-all-translations.sh      # Complete automation
│   ├── TRANSLATION_WORKFLOW.md         # Detailed guide
│   ├── TRANSLATION_QUICK_REFERENCE.md  # Cheat sheet
│   ├── DIRECTORY_STRUCTURE.md          # This structure explained
│   └── README.md                       # This file
│
└── sddm-theme/
    ├── components/
    │   ├── TranslationManager.qml      # AUTO-GENERATED
    │   ├── TranslationManager.qml.bak  # Auto backup
    │   ├── qmldir                       # Singleton registration
    │   ├── LoginPanel.qml               # Uses: TranslationManager.*
    │   ├── PasswordField.qml
    │   └── ... other QML files
    │
    └── translations/
        ├── en.json                      # MASTER - edit this
        ├── es.json                      # From Transifex
        ├── fr.json                      # From Transifex
        ├── de.json                      # From Transifex
        ├── en.json.bak                  # Auto backup
        ├── theme_es.ts                  # Reference
        ├── theme_fr.ts
        └── theme_de.ts
```

**📁 See [DIRECTORY_STRUCTURE.md](DIRECTORY_STRUCTURE.md) for detailed path resolution and troubleshooting.**

## Getting Help

### Documentation

- **TRANSLATION_WORKFLOW.md** - Complete detailed guide
- **TRANSLATION_QUICK_REFERENCE.md** - Quick command reference
- **This README** - Overview and architecture

### Command Help

```bash
python3 extract-strings.py --help
python3 translate-manager.py --help
bash update-all-translations.sh --help
```

### Community

- GitHub Issues: Report bugs or request features
- Transifex: Ask translation questions in comments
- Developer chat: Discuss implementation details

## License

Part of the slickSDDM project. See main project LICENSE file.

---

**Quick Links:**

- 📖 [Full Workflow Guide](TRANSLATION_WORKFLOW.md)
- 📋 [Quick Reference](TRANSLATION_QUICK_REFERENCE.md)
- 🌐 [Transifex Project](https://www.transifex.com/ubuntu-budgie/slicksddm/)
- 🐛 [Report Issues](https://github.com/ubuntu-budgie/slick-greeter/issues)
