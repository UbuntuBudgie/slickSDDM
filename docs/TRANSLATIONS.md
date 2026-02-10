# slickSDDM Theme - Translation Guide

This document describes how to work with translations for the slickSDDM theme.

## Overview

The theme uses a JSON-based translation system that integrates with Transifex for community translations. Translations are loaded dynamically at runtime based on the system locale.

## File Structure

```
sddm-theme/
├── translations/
│   ├── en.json          # Source English strings
│   ├── es.json          # Spanish translations
│   ├── fr.json          # French translations
│   ├── de.json          # German translations
│   └── ...              # Other languages
└── components/
    └── TranslationManager.qml  # Translation loader
```

## For Translators

### Getting Started with Transifex

1. **Join the project on Transifex:**
   - Visit: https://www.transifex.com/ubuntu-budgie/slicksddm/
   - Request to join as a translator for your language
   - Wait for approval from the project maintainers

2. **Start translating:**
   - Select your language from the dashboard
   - Click on the resource "translations"
   - Translate the strings in the web interface

3. **Translation guidelines:**
   - Keep placeholders like `{name}` intact
   - Maintain similar string length when possible (UI space is limited)
   - Use appropriate formal/informal tone for your locale
   - Test the context - strings are used in a login screen

### Key Translation Considerations

| String | Context | Notes |
|--------|---------|-------|
| `pressAnyKey` | Lock screen message | Very short, visible on lock screen |
| `username` | Input field placeholder | Single word preferred |
| `password` | Input field placeholder | Single word preferred |
| `capslockWarning` | Warning message | Appears when Caps Lock is on |
| `selectUserNamed` | Tooltip | Contains `{name}` placeholder - keep it! |

## For Developers

### Initial Setup (First Time Only)

When setting up the project for the first time or seeding Transifex with initial translations:

1. **Install Transifex CLI:**
   ```bash
   make install-tx-cli
   # or manually:
   pip3 install transifex-client
   ```

2. **Get your Transifex API token:**
   - Visit: https://www.transifex.com/user/settings/api/
   - Generate a new token
   - Save it securely

3. **Run initial setup:**
   ```bash
   export TX_TOKEN=your_token_here
   make translations-setup-initial
   ```

   This will:
   - Initialize Transifex configuration
   - Validate all translation JSON files
   - Push source strings (en.json) to Transifex
   - Push existing translations (es.json, fr.json, de.json)
   - Display translation statistics

### Daily Development Workflow

### Daily Development Workflow

Once initial setup is complete, use these commands for regular work:

1. **Pull latest translations:**
   ```bash
   make translations-pull
   # Pulls all translations with at least 30% completion
   ```

2. **Test translations:**
   ```bash
   make translations-test
   # Runs comprehensive validation
   ```

3. **Check translation status:**
   ```bash
   make translations-stats
   # Shows completion percentages for all languages
   ```

### Working with Translations

When you add new translatable strings to the theme:

1. Update `sddm-theme/translations/en.json`:
   ```json
   {
     "existingKey": "Existing String",
     "newKey": "New String to Translate"
   }
   ```

2. Update `TranslationManager.qml` to expose the new string:
   ```qml
   readonly property string newKey: tr("newKey", "New String to Translate")
   ```

3. Push to Transifex:
   ```bash
   make translations-push
   ```

### Adding a New Translatable String

1. **Add to source file** (`sddm-theme/translations/en.json`):
   ```json
   {
     "myNewString": "This is a new translatable string"
   }
   ```

2. **Add to TranslationManager.qml**:
   ```qml
   readonly property string myNewString: tr("myNewString", "This is a new translatable string")
   ```

3. **Use in QML components**:
   ```qml
   Text {
       text: TranslationManager.myNewString
   }
   ```

4. **For parameterized strings**:
   ```json
   {
     "welcomeUser": "Welcome, {username}!"
   }
   ```
   
   ```qml
   // In TranslationManager.qml
   function welcomeUser(username) {
       return trWith("welcomeUser", "Welcome, {username}!", {"username": username})
   }
   
   // In your component
   Text {
       text: TranslationManager.welcomeUser("Alice")
   }
   ```

## Testing Translations

### Quick Test

```bash
# Change system locale to Spanish
sudo update-locale LANG=es_ES.UTF-8
sudo reboot

# SDDM will now display in Spanish
# Change back: sudo update-locale LANG=en_GB.UTF-8
```

### Comprehensive Testing

For detailed instructions on:
- Testing translations with different locales
- Configuring keyboard layouts
- Setting up locale switching
- Automated testing scripts
- Troubleshooting locale issues

See the complete guide: **[TESTING_TRANSLATIONS.md](docs/TESTING_TRANSLATIONS.md)**

For keyboard layout configuration specifically, see: **[KEYBOARD_LAYOUT_SETUP.md](docs/KEYBOARD_LAYOUT_SETUP.md)**

The test suite (`tests/test_translations.py`) performs the following checks:

1. **Source file exists**: Verifies `en.json` is present
2. **JSON validity**: All translation files are valid JSON
3. **Key completeness**: All languages have all keys from source
4. **Placeholder consistency**: Placeholders like `{name}` are preserved
5. **No empty values**: No translation has empty strings
6. **Coverage statistics**: Shows translation completion percentage

Example output:
```
slickSDDM Theme - Translation Tests
===================================

Test: Source file exists
  ✓ PASSED

Test: JSON validity
  ✓ en.json
  ✓ es.json
  ✓ fr.json
  ✓ PASSED

Test: Translation coverage
  ✓ es.json - 100.0%
  ✓ fr.json - 95.5%
  ⚠ de.json - 72.7%
  ✓ PASSED

Tests passed: 6/6
✓ All tests passed!
```

### CI/CD Integration

The project includes GitHub Actions workflow that:

1. **Runs on every push** to translation files
2. **Weekly scheduled** pull from Transifex
3. **Automatically creates PRs** with new translations
4. **Validates** all translations pass tests

See `.github/workflows/translations.yml` for details.

### Translation Statistics

View current translation status:

```bash
make translations-stats

# Output:
# Translation Statistics
# ======================
# 
# es -> slicksddm: translations
#   ...
# Local files:
#   Translation files: 15
#   Source strings: 18
```

## Supported Languages

The theme loads translations from JSON files in the `translations/` folder. Initial translations are included for:

- English (en) - Source language
- Spanish (es) - Complete translation
- French (fr) - Complete translation  
- German (de) - Complete translation

**All translations are managed through Transifex.** When you run `make translations-pull`, the latest community translations are downloaded to the `translations/` folder.

To add a new language:
1. Request it on the Transifex project page
2. Complete translations via the Transifex web interface
3. Run `make translations-pull` to download
4. The theme will automatically detect and use it

## Fallback Behavior

The theme uses a simple, predictable fallback chain:

1. **Primary**: Attempts to load JSON file for current locale (e.g., `es.json` for Spanish)
2. **Secondary**: If not found or invalid, attempts to load `en.json` (English)
3. **Final**: If English file also unavailable, uses hardcoded fallback strings in code

This approach ensures:
- All translations come from the `translations/` folder
- Easy to update via Transifex pull
- No redundant embedded translations to maintain
- English is always the ultimate fallback

## Troubleshooting

### Translations not appearing

1. Check the file exists: `ls sddm-theme/translations/[your-locale].json`
2. Validate JSON: `python3 -m json.tool sddm-theme/translations/[your-locale].json`
3. Check console output: Look for loading errors in SDDM logs
4. Verify locale detection: Check `Qt.locale().name` matches your file

### Test failures

```bash
# Run tests with verbose output
python3 tests/test_translations.py

# Fix common issues:
# - Invalid JSON: Use a JSON validator
# - Missing keys: Compare with en.json
# - Wrong placeholders: Match source placeholders exactly
```

### Transifex authentication issues

```bash
# Re-initialize configuration
rm ~/.transifexrc
make translations-init TX_TOKEN=your_new_token
```

## Contributing Translations

1. **For new languages:**
   - Request language addition on Transifex
   - Start translating via web interface
   - Aim for at least 70% completion before release

2. **For updates:**
   - Translate new strings as they appear
   - Fix reported issues via Transifex comments
   - Review and vote on suggestions from other translators

3. **Quality guidelines:**
   - Use native speakers when possible
   - Test translations in actual theme (if possible)
   - Keep UI text concise
   - Maintain consistency across strings

## Resources

- [Transifex Project](https://www.transifex.com/ubuntu-budgie/slicksddm/)
- [Transifex CLI Documentation](https://docs.transifex.com/client/introduction)
- [Qt Locale Documentation](https://doc.qt.io/qt-6/qlocale.html)
- [JSON Specification](https://www.json.org/)

## Questions?

- For translation questions: Use Transifex comments
- For technical issues: Open a GitHub issue
- For general help: Contact the Ubuntu Budgie team

---

Thank you for helping make the slickSDDM theme accessible to users worldwide!