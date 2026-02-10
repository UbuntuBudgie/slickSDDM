#!/usr/bin/env python3
"""
translate-manager.py - Comprehensive translation management for slickSDDM

This script handles:
- Pulling translations from Transifex
- Converting JSON to QML code in TranslationManager.qml
- Validating translations
"""

import json
import os
import sys
import subprocess
import argparse
from pathlib import Path
from typing import Dict, List, Set

# ANSI colors
GREEN = '\033[0;32m'
YELLOW = '\033[1;33m'
RED = '\033[0;31m'
BLUE = '\033[0;34m'
NC = '\033[0m'

def print_color(color: str, message: str):
    """Print colored message"""
    print(f"{color}{message}{NC}")

def print_success(message: str):
    print_color(GREEN, f"✓ {message}")

def print_error(message: str):
    print_color(RED, f"✗ {message}")

def print_warning(message: str):
    print_color(YELLOW, f"⚠ {message}")

def print_info(message: str):
    print_color(BLUE, f"ℹ {message}")


class TranslationManager:
    def __init__(self, project_root: Path):
        self.project_root = project_root
        self.translations_dir = project_root / "sddm-theme" / "translations"
        self.translation_manager_file = project_root / "sddm-theme" / "components" / "TranslationManager.qml"
        self.en_json = self.translations_dir / "en.json"
        
    def validate_environment(self) -> bool:
        """Validate that required files and tools exist"""
        # Check Transifex CLI
        try:
            subprocess.run(["tx", "--version"], capture_output=True, check=True)
        except (subprocess.CalledProcessError, FileNotFoundError):
            print_error("Transifex CLI not installed")
            print_info("Install with: pip install transifex-client")
            return False
        
        # Check if authenticated
        try:
            subprocess.run(["tx", "status"], capture_output=True, check=True, cwd=self.project_root)
        except subprocess.CalledProcessError:
            print_error("Not authenticated with Transifex")
            print_info("Run: tx init")
            return False
        
        # Check if source file exists
        if not self.en_json.exists():
            print_error(f"Source file not found: {self.en_json}")
            return False
        
        return True
    
    def pull_translations(self) -> bool:
        """Pull translations from Transifex"""
        print_info("Pulling translations from Transifex...")
        try:
            result = subprocess.run(
                ["tx", "pull", "-a", "--minimum-perc=30"],
                cwd=self.project_root,
                capture_output=True,
                text=True
            )
            
            if result.returncode != 0:
                print_error("Failed to pull translations")
                print(result.stderr)
                return False
            
            print_success("Translations pulled successfully")
            return True
        except Exception as e:
            print_error(f"Error pulling translations: {e}")
            return False
    
    def load_json_translations(self) -> Dict[str, Dict[str, str]]:
        """Load all JSON translation files"""
        translations = {}
        
        for json_file in self.translations_dir.glob("*.json"):
            lang_code = json_file.stem
            try:
                with open(json_file, 'r', encoding='utf-8') as f:
                    translations[lang_code] = json.load(f)
            except json.JSONDecodeError as e:
                print_warning(f"Failed to parse {json_file.name}: {e}")
        
        return translations
    
    def categorize_strings(self, en_data: Dict[str, str]) -> Dict[str, List[str]]:
        """Categorize translation strings for better organization"""
        categories = {
            "Basic strings": [
                'pressAnyKey', 'username', 'password', 'login', 'loggingIn',
                'loginFailed', 'promptUser', 'capslockWarning'
            ],
            "Power menu": [
                'suspend', 'reboot', 'shutdown'
            ],
            "Tooltips and UI": [
                'changeSession', 'changeKeyboardLayout', 'toggleVirtualKeyboard',
                'powerOptions', 'closeUserSelection', 'selectUser'
            ],
            "Error messages": [
                'noKeyboardLayoutsConfigured', 'noUsersFound'
            ]
        }
        
        # Find uncategorized strings
        all_categorized = set()
        for keys in categories.values():
            all_categorized.update(keys)
        
        other_strings = [key for key in sorted(en_data.keys()) if key not in all_categorized]
        if other_strings:
            categories["Other strings"] = other_strings
        
        return categories
    
    def generate_qml_code(self, all_translations: Dict[str, Dict[str, str]]) -> str:
        """
        Generate QML code for TranslationManager.qml with embedded translations
        
        Since SDDM cannot load external translation files, we embed ALL translations
        directly in the QML and use Qt.locale() to select the right one at runtime.
        """
        if 'en' not in all_translations:
            raise ValueError("English source translations not found")
        
        en_data = all_translations['en']
        categories = self.categorize_strings(en_data)
        
        lines = [
            "pragma Singleton",
            "",
            "import QtQuick",
            "",
            "QtObject {",
            "    id: translationManager",
            "    ",
            "    // Embedded translations for SDDM",
            "    // Since SDDM cannot load external .qm files, all translations are embedded here",
            "    // and selected based on Qt.locale().name at runtime",
            "    ",
            "    readonly property string currentLocale: Qt.locale().name",
            "    "
        ]
        
        # Generate embedded translations object
        lines.append("    // All translations embedded")
        lines.append("    readonly property var translations: ({")
        
        # Add each language
        for lang_code in sorted(all_translations.keys()):
            trans_data = all_translations[lang_code]
            lines.append(f"        '{lang_code}': {{")
            
            for key in sorted(trans_data.keys()):
                value = trans_data[key].replace('"', '\\"').replace('\n', '\\n')
                lines.append(f"            '{key}': \"{value}\",")
            
            lines.append("        },")
        
        lines.append("    })")
        lines.append("")
        
        # Helper function to get translated string
        lines.extend([
            "    // Get translation for current locale, fallback to English",
            "    function tr(key) {",
            "        // Try full locale (e.g., 'es_ES')",
            "        if (translations[currentLocale] && translations[currentLocale][key]) {",
            "            return translations[currentLocale][key]",
            "        }",
            "        ",
            "        // Try language code only (e.g., 'es' from 'es_ES')",
            "        var langCode = currentLocale.split('_')[0]",
            "        if (translations[langCode] && translations[langCode][key]) {",
            "            return translations[langCode][key]",
            "        }",
            "        ",
            "        // Fallback to English",
            "        if (translations['en'] && translations['en'][key]) {",
            "            return translations['en'][key]",
            "        }",
            "        ",
            "        // Last resort: return key itself",
            "        return key",
            "    }",
            ""
        ])
        
        # Generate properties for each category using the tr() function
        for category, keys in categories.items():
            if not keys:
                continue
            
            lines.append(f"    // {category}")
            for key in keys:
                if key in en_data:
                    lines.append(f"    readonly property string {key}: tr('{key}')")
            lines.append("")
        
        # Add parameterized functions
        lines.extend([
            "    // Parameterized strings",
            "    function selectUserNamed(name) {",
            "        return tr('selectUserNamed').replace('%1', name).replace('{name}', name)",
            "    }",
            "}"
        ])
        
        return "\n".join(lines)
    
    def update_translation_manager(self) -> bool:
        """Update TranslationManager.qml with embedded translations from all languages"""
        print_info("Updating TranslationManager.qml...")
        
        try:
            # Load ALL translations (not just English)
            all_translations = self.load_json_translations()
            
            if not all_translations:
                print_error("No translation files found")
                return False
            
            if 'en' not in all_translations:
                print_error("English source file (en.json) not found")
                return False
            
            # Create backup
            backup_file = self.translation_manager_file.with_suffix('.qml.bak')
            if self.translation_manager_file.exists():
                with open(self.translation_manager_file, 'r') as src:
                    with open(backup_file, 'w') as dst:
                        dst.write(src.read())
                print_success(f"Backup created: {backup_file.name}")
            
            # Generate new QML code with ALL translations embedded
            qml_code = self.generate_qml_code(all_translations)
            
            # Write new file
            with open(self.translation_manager_file, 'w', encoding='utf-8') as f:
                f.write(qml_code)
            
            # Report what was embedded
            lang_count = len(all_translations)
            lang_list = ', '.join(sorted(all_translations.keys()))
            print_success(f"TranslationManager.qml updated with {lang_count} languages: {lang_list}")
            return True
            
        except Exception as e:
            print_error(f"Failed to update TranslationManager.qml: {e}")
            import traceback
            traceback.print_exc()
            return False
    
    def generate_ts_files(self) -> bool:
        """Generate .ts files from JSON for Qt"""
        print_info("Generating .ts files...")
        
        try:
            translations = self.load_json_translations()
            
            # Load English source
            if 'en' not in translations:
                print_error("English source not found")
                return False
            
            en_data = translations['en']
            
            # Generate .ts file for each language
            for lang_code, trans_data in translations.items():
                if lang_code == 'en':
                    continue  # Skip source language
                
                ts_file = self.translations_dir / f"theme_{lang_code}.ts"
                
                # Build .ts XML
                ts_lines = [
                    '<?xml version="1.0" encoding="utf-8"?>',
                    '<!DOCTYPE TS>',
                    f'<TS version="2.1" language="{lang_code}">',
                    '<context>',
                    '    <name>TranslationManager</name>'
                ]
                
                for key in sorted(en_data.keys()):
                    source_text = en_data[key]
                    translated_text = trans_data.get(key, '')
                    
                    ts_lines.extend([
                        '    <message>',
                        '      <location filename="../components/TranslationManager.qml" line="0"/>',
                        f'      <source>{self._escape_xml(source_text)}</source>',
                    ])
                    
                    if translated_text:
                        ts_lines.append(f'      <translation>{self._escape_xml(translated_text)}</translation>')
                    else:
                        ts_lines.append('      <translation type="unfinished"/>')
                    
                    ts_lines.extend([
                        f'      <comment>Key: {key}</comment>',
                        '    </message>'
                    ])
                
                ts_lines.extend([
                    '  </context>',
                    '</TS>'
                ])
                
                # Write .ts file
                with open(ts_file, 'w', encoding='utf-8') as f:
                    f.write('\n'.join(ts_lines))
                
                print_success(f"Generated {ts_file.name}")
            
            return True
            
        except Exception as e:
            print_error(f"Failed to generate .ts files: {e}")
            return False
    

    def validate_translations(self) -> bool:
        """Validate all translation files"""
        print_info("Validating translations...")
        
        translations = self.load_json_translations()
        
        if 'en' not in translations:
            print_error("English source file missing")
            return False
        
        en_keys = set(translations['en'].keys())
        all_valid = True
        
        for lang_code, trans_data in translations.items():
            if lang_code == 'en':
                continue
            
            trans_keys = set(trans_data.keys())
            
            # Check for missing keys
            missing = en_keys - trans_keys
            if missing:
                print_warning(f"{lang_code}: Missing keys: {', '.join(sorted(missing))}")
                all_valid = False
            
            # Check for extra keys
            extra = trans_keys - en_keys
            if extra:
                print_warning(f"{lang_code}: Extra keys: {', '.join(sorted(extra))}")
            
            # Check for empty values
            empty = [key for key, value in trans_data.items() if not value]
            if empty:
                print_warning(f"{lang_code}: Empty values: {', '.join(sorted(empty))}")
                all_valid = False
            
            # Calculate completion
            complete_keys = [key for key in en_keys if key in trans_data and trans_data[key]]
            completion = (len(complete_keys) / len(en_keys)) * 100 if en_keys else 0
            
            status = "✓" if completion == 100 else "⚠"
            print(f"  {status} {lang_code}: {completion:.1f}% complete")
        
        return all_valid
    
    def run(self, pull: bool = True, validate_only: bool = False):
        """Run the full translation update process"""
        print_color(GREEN, "=" * 50)
        print_color(GREEN, "SDDM Translation Manager")
        print_color(GREEN, "=" * 50)
        print()
        
        # Only validate Transifex if we're going to pull
        if pull:
            if not self.validate_environment():
                return False
        else:
            # Just check if source file exists
            if not self.en_json.exists():
                print_error(f"Source file not found: {self.en_json}")
                return False
        
        if validate_only:
            return self.validate_translations()
        
        # Pull from Transifex
        if pull:
            if not self.pull_translations():
                return False
        
        # Validate translations
        if not self.validate_translations():
            print_warning("Validation found issues, but continuing...")
        
        # Update TranslationManager.qml
        if not self.update_translation_manager():
            return False
        
        print()
        print_success("Translation update complete!")
        print()
        print_info("Next steps:")
        print("  1. Review changes in TranslationManager.qml")
        print("  2. Commit the updated files")
        print("  3. Test the theme with different locales")
        
        return True


def main():
    parser = argparse.ArgumentParser(
        description="Manage translations for slickSDDM theme"
    )
    parser.add_argument(
        '--no-pull',
        action='store_true',
        help="Skip pulling from Transifex (use existing JSON files)"
    )
    parser.add_argument(
        '--validate-only',
        action='store_true',
        help="Only validate existing translations without updating"
    )
    parser.add_argument(
        '--project-root',
        type=Path,
        default=Path(__file__).parent.parent,
        help="Path to project root (default: script parent directory)"
    )
    
    args = parser.parse_args()
    
    manager = TranslationManager(args.project_root)
    success = manager.run(pull=not args.no_pull, validate_only=args.validate_only)
    
    sys.exit(0 if success else 1)


if __name__ == '__main__':
    main()
