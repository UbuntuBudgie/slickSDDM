# Translation Maintainer Checklist

Quick reference for maintaining translations in the slickSDDM theme.

## Initial Project Setup (One Time)

- [ ] Install Transifex CLI: `make install-tx-cli`
- [ ] Get Transifex API token from https://www.transifex.com/user/settings/api/
- [ ] Run initial setup: `TX_TOKEN=xxx make translations-setup-initial`
- [ ] Verify on Transifex web interface that all files uploaded
- [ ] Invite initial translators to the project

## Adding a New Translatable String

- [ ] Add to `sddm-theme/translations/en.json`:
  ```json
  "myNewKey": "My new English string"
  ```
- [ ] Add to `sddm-theme/components/TranslationManager.qml`:
  ```qml
  readonly property string myNewKey: tr("myNewKey", "My new English string")
  ```
- [ ] Use in your QML component:
  ```qml
  Text { text: TranslationManager.myNewKey }
  ```
- [ ] Test locally that it appears correctly
- [ ] Run tests: `make translations-test`
- [ ] Push to Transifex: `make translations-push`
- [ ] Verify on Transifex that translators can see the new string

## Weekly Maintenance

- [ ] Pull latest translations: `make translations-pull`
- [ ] Run test suite: `make translations-test`
- [ ] Review any warnings or errors
- [ ] Check translation coverage: `make translations-stats`
- [ ] Commit and push updated translation files
- [ ] Create PR if using automated workflow

## Before Each Release

- [ ] Pull latest translations: `make translations-pull`
- [ ] Run full test suite: `make translations-test`
- [ ] Verify all tests pass
- [ ] Check coverage of major languages (aim for 90%+):
  - English (en) - should be 100%
  - Spanish (es)
  - French (fr)
  - German (de)
  - Portuguese (pt)
- [ ] Test theme with different locales:
  ```bash
  # Set test locale and restart SDDM
  export LANG=es_ES.UTF-8
  # Test login screen appearance
  ```
- [ ] Update CHANGELOG with translation improvements
- [ ] Tag release including latest translations

## Handling Translator Requests

### New Language Request
- [ ] Check if language is supported by Qt (https://doc.qt.io/qt-6/qlocale.html)
- [ ] Add language on Transifex project settings
- [ ] Notify requester that translation can begin
- [ ] When 30%+ complete, pull translations: `make translations-pull`
- [ ] Test with that locale if possible
- [ ] Announce new language support

### Translation Issue Report
- [ ] Verify the issue on Transifex
- [ ] Check if it's a translation error or code issue
- [ ] If translation error: contact translator or fix directly
- [ ] If code issue: fix in source, push update
- [ ] Pull corrected translations
- [ ] Thank reporter

### Translator Question
- [ ] Provide context about where string appears
- [ ] Include screenshot if helpful
- [ ] Explain any technical constraints (length, placeholders, etc.)
- [ ] Point to TRANSLATOR_QUICKSTART.md for general guidance

## Monthly Review

- [ ] Review Transifex activity (new translators, progress)
- [ ] Thank active translators (comment on Transifex or social media)
- [ ] Identify stalled translations (< 50% for > 3 months)
- [ ] Consider recruiting translators for low-coverage languages
- [ ] Update translation statistics in documentation
- [ ] Check for abandoned translation files (test suite warnings)

## Troubleshooting Common Issues

### Test failures after pull
```bash
# Re-run tests with verbose output
python3 tests/test_translations.py

# Common fixes:
# - Invalid JSON: Fix syntax in the .json file
# - Missing keys: Add missing translations or mark as TODO
# - Wrong placeholders: Verify {placeholder} format matches source
```

### Transifex authentication issues
```bash
# Re-initialize
rm ~/.transifexrc
TX_TOKEN=xxx make translations-init
```

### Pull gets no new translations
```bash
# Check Transifex status
tx status

# Try manual pull with lower threshold
tx pull -a --minimum-perc=10

# Verify translators have pushed their work
```

### Translation doesn't appear in theme
1. Verify JSON file exists in `sddm-theme/translations/`
2. Check JSON is valid: `python3 -m json.tool file.json`
3. Verify locale code matches filename (e.g., `es.json` for Spanish)
4. Check SDDM logs for loading errors
5. Restart SDDM to reload translations

## Quick Commands Reference

```bash
# Daily
make translations-pull              # Get latest translations
make translations-test              # Run tests

# When adding strings
make translations-push              # Send to Transifex

# Checking status
make translations-stats             # Show coverage
tx status                          # Detailed Transifex status

# Troubleshooting
python3 tests/test_translations.py  # Verbose test output
python3 -m json.tool file.json     # Validate JSON
```

## Resources

- Transifex Project: https://www.transifex.com/ubuntu-budgie/slicksddm/
- Transifex CLI Docs: https://docs.transifex.com/client/introduction
- Translation Docs: [TRANSLATIONS.md](../TRANSLATIONS.md)
- Translator Guide: [TRANSLATOR_QUICKSTART.md](TRANSLATOR_QUICKSTART.md)

---

Last updated: [DATE]
