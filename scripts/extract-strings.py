#!/usr/bin/env python3
"""
extract-strings.py - Extract translation strings from QML files and merge into en.json

This script:
- Scans QML files for TranslationManager property usage
- Finds new strings not yet in en.json
- Merges them into en.json while preserving existing translations
- Reports on changes made

Usage:
    python3 extract-strings.py                    # Interactive mode
    python3 extract-strings.py --dry-run          # Show what would change
    python3 extract-strings.py --auto             # Auto-merge without prompts
"""

import json
import os
import re
import sys
import argparse
from pathlib import Path
from typing import Dict, Set, List, Tuple
from collections import defaultdict

# ANSI colors
GREEN = '\033[0;32m'
YELLOW = '\033[1;33m'
RED = '\033[0;31m'
BLUE = '\033[0;34m'
CYAN = '\033[0;36m'
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


class StringExtractor:
    def __init__(self, project_root: Path):
        self.project_root = project_root
        # Assuming script is in root/scripts/ and theme is in root/sddm-theme/
        self.sddm_theme_dir = project_root / "sddm-theme"
        self.translations_dir = self.sddm_theme_dir / "translations"
        self.en_json = self.translations_dir / "en.json"
        self.components_dir = self.sddm_theme_dir / "components"
        
        # Patterns to find TranslationManager usage in QML
        self.patterns = [
            # TranslationManager.propertyName
            re.compile(r'TranslationManager\.([a-zA-Z_][a-zA-Z0-9_]*)', re.MULTILINE),
            # For function calls: TranslationManager.functionName(...)
            # These are captured the same way - we'll validate manually
        ]
        
    def find_qml_files(self) -> List[Path]:
        """Find all QML files in the project"""
        qml_files = []
        
        # Search in sddm-theme directory
        if self.sddm_theme_dir.exists():
            qml_files.extend(self.sddm_theme_dir.rglob("*.qml"))
        
        # Exclude TranslationManager.qml itself and backups
        excluded = {'TranslationManager.qml', 'TranslationManager.qml.bak'}
        qml_files = [f for f in qml_files if f.name not in excluded]
        
        return sorted(qml_files)
    
    def extract_strings_from_file(self, qml_file: Path) -> Dict[str, List[Tuple[int, str]]]:
        """
        Extract TranslationManager references from a QML file
        Returns: Dict mapping string keys to list of (line_number, line_content) tuples
        """
        strings = defaultdict(list)
        
        try:
            with open(qml_file, 'r', encoding='utf-8') as f:
                lines = f.readlines()
                
            for line_num, line in enumerate(lines, 1):
                # Skip comments
                if line.strip().startswith('//'):
                    continue
                
                # Find all TranslationManager references
                for pattern in self.patterns:
                    matches = pattern.findall(line)
                    for match in matches:
                        # Store the string key with its location
                        strings[match].append((line_num, line.strip()))
        
        except Exception as e:
            print_warning(f"Error reading {qml_file.name}: {e}")
        
        return dict(strings)
    
    def extract_all_strings(self) -> Dict[str, Dict[str, List[Tuple[int, str]]]]:
        """
        Extract all TranslationManager strings from all QML files
        Returns: Dict mapping string keys to dict of {filename: [(line_num, line_content), ...]}
        """
        all_strings = defaultdict(lambda: defaultdict(list))
        qml_files = self.find_qml_files()
        
        print_info(f"Scanning {len(qml_files)} QML files...")
        
        for qml_file in qml_files:
            file_strings = self.extract_strings_from_file(qml_file)
            
            for string_key, locations in file_strings.items():
                for location in locations:
                    all_strings[string_key][qml_file.name].append(location)
        
        # Convert defaultdict to regular dict for easier handling
        return {k: dict(v) for k, v in all_strings.items()}
    
    def load_en_json(self) -> Dict[str, str]:
        """Load the existing en.json file"""
        if not self.en_json.exists():
            print_warning(f"en.json not found at {self.en_json}")
            return {}
        
        try:
            with open(self.en_json, 'r', encoding='utf-8') as f:
                data = json.load(f)
            print_success(f"Loaded {len(data)} existing strings from en.json")
            return data
        except json.JSONDecodeError as e:
            print_error(f"Failed to parse en.json: {e}")
            return {}
    
    def save_en_json(self, data: Dict[str, str], backup: bool = True):
        """Save data to en.json with optional backup"""
        if backup and self.en_json.exists():
            backup_file = self.en_json.with_suffix('.json.bak')
            with open(self.en_json, 'r') as src:
                with open(backup_file, 'w') as dst:
                    dst.write(src.read())
            print_success(f"Backup created: {backup_file.name}")
        
        # Sort keys alphabetically for consistency
        sorted_data = dict(sorted(data.items()))
        
        with open(self.en_json, 'w', encoding='utf-8') as f:
            json.dump(sorted_data, f, indent=2, ensure_ascii=False)
            f.write('\n')  # Add trailing newline
        
        print_success(f"Saved {len(sorted_data)} strings to en.json")
    
    def suggest_translation_value(self, key: str) -> str:
        """
        Suggest a human-readable translation value based on the key name
        
        Examples:
            pressAnyKey -> "Press any key"
            username -> "Username"
            loginFailed -> "Login failed"
            noKeyboardLayoutsConfigured -> "No keyboard layouts configured"
        """
        # Insert spaces before capital letters
        spaced = re.sub(r'([a-z])([A-Z])', r'\1 \2', key)
        
        # Capitalize first letter
        result = spaced[0].upper() + spaced[1:] if spaced else ""
        
        return result
    
    def print_usage_locations(self, string_key: str, locations: Dict[str, List[Tuple[int, str]]]):
        """Print where a string is used in the codebase"""
        print(f"\n  Used in:")
        for filename, file_locations in sorted(locations.items()):
            for line_num, line_content in file_locations:
                # Truncate long lines
                if len(line_content) > 80:
                    line_content = line_content[:77] + "..."
                print(f"    {filename}:{line_num}")
                print_color(CYAN, f"      {line_content}")
    
    def run(self, dry_run: bool = False, auto: bool = False):
        """Main extraction and merge process"""
        print_color(GREEN, "=" * 60)
        print_color(GREEN, "QML String Extractor - Find new translation strings")
        print_color(GREEN, "=" * 60)
        print()
        
        # Extract all strings from QML files
        extracted_strings = self.extract_all_strings()
        
        if not extracted_strings:
            print_warning("No TranslationManager strings found in QML files")
            return True
        
        print_success(f"Found {len(extracted_strings)} unique string keys in QML files")
        print()
        
        # Load existing en.json
        existing_strings = self.load_en_json()
        
        # Find new strings
        new_keys = set(extracted_strings.keys()) - set(existing_strings.keys())
        
        # Find unused strings (in en.json but not in QML)
        unused_keys = set(existing_strings.keys()) - set(extracted_strings.keys())
        
        # Report findings
        print()
        print_color(BLUE, "=" * 60)
        print_color(BLUE, "Analysis Results")
        print_color(BLUE, "=" * 60)
        print()
        
        if new_keys:
            print_color(GREEN, f"Found {len(new_keys)} NEW strings to add:")
            for key in sorted(new_keys):
                suggested = self.suggest_translation_value(key)
                print(f"\n  {key}")
                print_color(YELLOW, f"    Suggested: \"{suggested}\"")
                self.print_usage_locations(key, extracted_strings[key])
        else:
            print_success("No new strings found - en.json is up to date!")
        
        if unused_keys:
            print()
            print_color(YELLOW, f"Found {len(unused_keys)} UNUSED strings (in en.json but not in QML):")
            for key in sorted(unused_keys):
                print(f"  - {key}: \"{existing_strings[key]}\"")
            print()
            print_warning("These strings might be obsolete or used in commented code")
        
        # If dry run, stop here
        if dry_run:
            print()
            print_info("Dry run complete - no changes made")
            return True
        
        # If no new strings, we're done
        if not new_keys:
            return True
        
        # Merge new strings
        print()
        print_color(BLUE, "=" * 60)
        print_color(BLUE, "Merging New Strings")
        print_color(BLUE, "=" * 60)
        print()
        
        updated_strings = existing_strings.copy()
        
        if auto:
            # Auto mode - use suggested values
            for key in sorted(new_keys):
                suggested = self.suggest_translation_value(key)
                updated_strings[key] = suggested
                print(f"  + {key}: \"{suggested}\"")
        else:
            # Interactive mode - ask for each string
            for i, key in enumerate(sorted(new_keys), 1):
                suggested = self.suggest_translation_value(key)
                print(f"\n[{i}/{len(new_keys)}] Key: {key}")
                print_color(YELLOW, f"Suggested: \"{suggested}\"")
                self.print_usage_locations(key, extracted_strings[key])
                
                while True:
                    response = input(f"\nEnter value (or press Enter to use suggestion): ").strip()
                    
                    if response == "":
                        updated_strings[key] = suggested
                        print_success(f"Using: \"{suggested}\"")
                        break
                    elif response:
                        updated_strings[key] = response
                        print_success(f"Using: \"{response}\"")
                        break
        
        # Save the updated en.json
        print()
        self.save_en_json(updated_strings, backup=True)
        
        print()
        print_success("String extraction and merge complete!")
        print()
        print_info("Next steps:")
        print("  1. Review the updated en.json file")
        print("  2. Push source to Transifex:")
        print("     tx push -s")
        print("  3. Update TranslationManager.qml:")
        print("     python3 translate-manager.py --no-pull")
        print("  4. Commit the changes")
        
        return True


def main():
    parser = argparse.ArgumentParser(
        description="Extract translation strings from QML files and merge into en.json",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  # Interactive mode - prompts for each new string
  python3 extract-strings.py
  
  # Dry run - show what would change without making changes
  python3 extract-strings.py --dry-run
  
  # Auto mode - automatically add all new strings with suggested values
  python3 extract-strings.py --auto
  
  # Custom project root
  python3 extract-strings.py --project-root /path/to/project
        """
    )
    parser.add_argument(
        '--dry-run',
        action='store_true',
        help="Show what would change without modifying en.json"
    )
    parser.add_argument(
        '--auto',
        action='store_true',
        help="Automatically add new strings with suggested values (no prompts)"
    )
    parser.add_argument(
        '--project-root',
        type=Path,
        default=Path(__file__).parent.parent,  # Parent of scripts/ directory
        help="Path to project root (default: parent of scripts directory)"
    )
    
    args = parser.parse_args()
    
    extractor = StringExtractor(args.project_root)
    success = extractor.run(dry_run=args.dry_run, auto=args.auto)
    
    sys.exit(0 if success else 1)


if __name__ == '__main__':
    main()
