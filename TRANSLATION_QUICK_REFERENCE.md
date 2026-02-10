# Translation Quick Reference

One-page cheat sheet for managing slickSDDM translations.

## The Two Scripts

| Script | Purpose | When to Use |
|--------|---------|-------------|
| `extract-strings.py` | Find strings in QML → add to en.json | After adding new translatable text to QML |
| `translate-manager.py` | Pull from Transifex → generate TranslationManager.qml | Regular updates, before releases |

## Common Commands

```bash
# 1. Extract new strings from QML code
python3 extract-strings.py --dry-run    # Preview only
python3 extract-strings.py              # Interactive
python3 extract-strings.py --auto       # Auto-add with suggestions

# 2. Push source to Transifex
tx push -s

# 3. Pull translations from Transifex
python3 translate-manager.py            # Full update
python3 translate-manager.py --no-pull  # Skip Transifex pull
python3 translate-manager.py --validate-only  # Check only

# 4. Validate translations
python3 translate-manager.py --validate-only
```

## Daily Workflows

### Adding New Translatable Text

```bash
# 1. Write QML code
# Text { text: TranslationManager.myNewString }

# 2. Extract to en.json
python3 extract-strings.py --auto

# 3. Update TranslationManager.qml
python3 translate-manager.py --no-pull

# 4. Test
sddm-greeter-qt6 --test-mode --theme ./sddm-theme

# 5. Push to Transifex (when ready)
tx push -s
```

### Updating Translations

```bash
# Pull from Transifex and update everything
python3 translate-manager.py

# Test different locales
LANG=es_ES.UTF-8 sddm-greeter-qt6 --test-mode --theme ./sddm-theme

# Commit
git commit -am "Update translations"
```

### Before a Release

```bash
# 1. Extract any new strings
python3 extract-strings.py --dry-run
# If found: python3 extract-strings.py --auto && tx push -s

# 2. Pull latest translations
python3 translate-manager.py

# 3. Validate completeness
python3 translate-manager.py --validate-only

# 4. Commit
git commit -am "Final translation update for v1.x.x"
```

## File Overview

```
sddm-theme/
├── components/
│   └── TranslationManager.qml    # AUTO-GENERATED - don't edit!
└── translations/
    ├── en.json                    # MASTER FILE - edit this
    ├── es.json                    # From Transifex - don't edit
    ├── fr.json                    # From Transifex - don't edit
    └── *.ts                       # Generated - ignore
```

## Usage in QML

```qml
// Simple property
Text {
    text: TranslationManager.username
}

// Parameterized (if function exists)
Text {
    text: TranslationManager.selectUserNamed("Alice")
}
```

## Adding to en.json Manually

```json
{
  "myNewKey": "My New Text",
  "anotherKey": "Another translatable string"
}
```

Then run:
```bash
python3 translate-manager.py --no-pull
```

## Key Patterns

| Pattern | Example |
|---------|---------|
| Extract from QML | `python3 extract-strings.py` |
| Update from JSON | `python3 translate-manager.py --no-pull` |
| Pull from Transifex | `python3 translate-manager.py` |
| Push to Transifex | `tx push -s` |
| Validate only | `python3 translate-manager.py --validate-only` |

## Troubleshooting

| Problem | Solution |
|---------|----------|
| Script doesn't find strings | Run from project root or use `--project-root` |
| String not translating | Check LANG variable, restart SDDM |
| Transifex auth failed | Run `tx init` and enter API token |
| en.json parse error | Check JSON syntax with `python3 -m json.tool en.json` |

## Don't Forget

- ✅ Always backup before modifying (scripts do this automatically)
- ✅ Test in multiple locales before releasing
- ✅ Run `--dry-run` first to preview changes
- ✅ Keep en.json as source of truth
- ❌ Never edit TranslationManager.qml manually
- ❌ Never edit language-specific JSON files (es.json, fr.json, etc.)
- ❌ Don't commit .bak files

## Help

```bash
python3 extract-strings.py --help
python3 translate-manager.py --help
```

## Full Documentation

See `TRANSLATION_WORKFLOW.md` for complete guide.
