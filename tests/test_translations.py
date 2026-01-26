#!/usr/bin/env python3
"""
Translation Test Suite for slickSDDM Theme
Tests translation files for completeness, validity, and consistency.
"""

import json
import os
import sys
from pathlib import Path
from typing import Dict, List, Set

# Colors for terminal output
class Colors:
    GREEN = '\033[0;32m'
    YELLOW = '\033[1;33m'
    RED = '\033[0;31m'
    BLUE = '\033[0;34m'
    NC = '\033[0m'  # No Color

class TranslationTester:
    def __init__(self, translations_dir: Path):
        self.translations_dir = translations_dir
        self.source_file = translations_dir / "en.json"
        self.errors = []
        self.warnings = []
        
    def load_json(self, filepath: Path) -> Dict:
        """Load and parse a JSON file."""
        try:
            with open(filepath, 'r', encoding='utf-8') as f:
                return json.load(f)
        except json.JSONDecodeError as e:
            self.errors.append(f"{filepath.name}: Invalid JSON - {e}")
            return {}
        except Exception as e:
            self.errors.append(f"{filepath.name}: Failed to read - {e}")
            return {}
    
    def get_translation_files(self) -> List[Path]:
        """Get all translation JSON files except source."""
        files = []
        for file in self.translations_dir.glob("*.json"):
            if file != self.source_file:
                files.append(file)
        return sorted(files)
    
    def test_source_file_exists(self) -> bool:
        """Test that source translation file exists."""
        print(f"\n{Colors.BLUE}Test: Source file exists{Colors.NC}")
        if not self.source_file.exists():
            self.errors.append(f"Source file not found: {self.source_file}")
            print(f"  {Colors.RED}✗ FAILED{Colors.NC}")
            return False
        print(f"  {Colors.GREEN}✓ PASSED{Colors.NC}")
        return True
    
    def test_json_validity(self) -> bool:
        """Test that all JSON files are valid."""
        print(f"\n{Colors.BLUE}Test: JSON validity{Colors.NC}")
        all_valid = True
        
        for file in [self.source_file] + self.get_translation_files():
            data = self.load_json(file)
            if not data and file.stat().st_size > 0:
                all_valid = False
                print(f"  {Colors.RED}✗ {file.name}{Colors.NC}")
            else:
                print(f"  {Colors.GREEN}✓ {file.name}{Colors.NC}")
        
        if all_valid:
            print(f"  {Colors.GREEN}✓ PASSED{Colors.NC}")
        else:
            print(f"  {Colors.RED}✗ FAILED{Colors.NC}")
        return all_valid
    
    def test_key_completeness(self) -> bool:
        """Test that all translation files have all keys from source."""
        print(f"\n{Colors.BLUE}Test: Key completeness{Colors.NC}")
        source_data = self.load_json(self.source_file)
        if not source_data:
            print(f"  {Colors.RED}✗ FAILED - Cannot load source file{Colors.NC}")
            return False
        
        source_keys = set(source_data.keys())
        all_complete = True
        
        for file in self.get_translation_files():
            trans_data = self.load_json(file)
            if not trans_data:
                continue
            
            trans_keys = set(trans_data.keys())
            missing_keys = source_keys - trans_keys
            extra_keys = trans_keys - source_keys
            
            if missing_keys:
                all_complete = False
                self.warnings.append(
                    f"{file.name}: Missing keys: {', '.join(sorted(missing_keys))}"
                )
                print(f"  {Colors.YELLOW}⚠ {file.name} - Missing {len(missing_keys)} key(s){Colors.NC}")
            elif extra_keys:
                self.warnings.append(
                    f"{file.name}: Extra keys: {', '.join(sorted(extra_keys))}"
                )
                print(f"  {Colors.YELLOW}⚠ {file.name} - Has {len(extra_keys)} extra key(s){Colors.NC}")
            else:
                print(f"  {Colors.GREEN}✓ {file.name} - Complete{Colors.NC}")
        
        if all_complete:
            print(f"  {Colors.GREEN}✓ PASSED{Colors.NC}")
        else:
            print(f"  {Colors.YELLOW}⚠ PASSED with warnings{Colors.NC}")
        return True
    
    def test_placeholder_consistency(self) -> bool:
        """Test that placeholders like {name} are preserved in translations."""
        print(f"\n{Colors.BLUE}Test: Placeholder consistency{Colors.NC}")
        source_data = self.load_json(self.source_file)
        if not source_data:
            print(f"  {Colors.RED}✗ FAILED - Cannot load source file{Colors.NC}")
            return False
        
        # Find all placeholders in source
        import re
        placeholder_pattern = re.compile(r'\{(\w+)\}')
        
        all_consistent = True
        for file in self.get_translation_files():
            trans_data = self.load_json(file)
            if not trans_data:
                continue
            
            for key, source_value in source_data.items():
                if key not in trans_data:
                    continue
                
                source_placeholders = set(placeholder_pattern.findall(source_value))
                trans_placeholders = set(placeholder_pattern.findall(trans_data[key]))
                
                if source_placeholders != trans_placeholders:
                    all_consistent = False
                    self.errors.append(
                        f"{file.name}: Key '{key}' has mismatched placeholders. "
                        f"Expected: {source_placeholders}, Got: {trans_placeholders}"
                    )
                    print(f"  {Colors.RED}✗ {file.name} - Key '{key}'{Colors.NC}")
        
        if all_consistent:
            print(f"  {Colors.GREEN}✓ PASSED{Colors.NC}")
        else:
            print(f"  {Colors.RED}✗ FAILED{Colors.NC}")
        return all_consistent
    
    def test_no_empty_values(self) -> bool:
        """Test that no translation has empty values."""
        print(f"\n{Colors.BLUE}Test: No empty values{Colors.NC}")
        all_valid = True
        
        for file in self.get_translation_files():
            trans_data = self.load_json(file)
            if not trans_data:
                continue
            
            empty_keys = [k for k, v in trans_data.items() if not v or not v.strip()]
            if empty_keys:
                all_valid = False
                self.warnings.append(
                    f"{file.name}: Empty values for keys: {', '.join(empty_keys)}"
                )
                print(f"  {Colors.YELLOW}⚠ {file.name} - {len(empty_keys)} empty value(s){Colors.NC}")
            else:
                print(f"  {Colors.GREEN}✓ {file.name}{Colors.NC}")
        
        if all_valid:
            print(f"  {Colors.GREEN}✓ PASSED{Colors.NC}")
        else:
            print(f"  {Colors.YELLOW}⚠ PASSED with warnings{Colors.NC}")
        return True
    
    def test_translation_coverage(self) -> bool:
        """Test translation coverage percentage."""
        print(f"\n{Colors.BLUE}Test: Translation coverage{Colors.NC}")
        source_data = self.load_json(self.source_file)
        if not source_data:
            print(f"  {Colors.RED}✗ FAILED - Cannot load source file{Colors.NC}")
            return False
        
        total_keys = len(source_data)
        
        for file in self.get_translation_files():
            trans_data = self.load_json(file)
            if not trans_data:
                print(f"  {Colors.YELLOW}⚠ {file.name} - 0%{Colors.NC}")
                continue
            
            translated_keys = sum(
                1 for k, v in trans_data.items() 
                if k in source_data and v and v.strip()
            )
            coverage = (translated_keys / total_keys) * 100
            
            if coverage >= 90:
                color = Colors.GREEN
                symbol = "✓"
            elif coverage >= 70:
                color = Colors.YELLOW
                symbol = "⚠"
            else:
                color = Colors.RED
                symbol = "✗"
            
            print(f"  {color}{symbol} {file.name} - {coverage:.1f}%{Colors.NC}")
        
        print(f"  {Colors.GREEN}✓ PASSED{Colors.NC}")
        return True
    
    def run_all_tests(self) -> bool:
        """Run all translation tests."""
        print(f"{Colors.GREEN}Ubuntu Budgie SDDM Theme - Translation Tests{Colors.NC}")
        print("=" * 50)
        
        tests = [
            self.test_source_file_exists,
            self.test_json_validity,
            self.test_key_completeness,
            self.test_placeholder_consistency,
            self.test_no_empty_values,
            self.test_translation_coverage,
        ]
        
        results = [test() for test in tests]
        
        # Print summary
        print(f"\n{Colors.BLUE}{'=' * 50}{Colors.NC}")
        print(f"{Colors.BLUE}Summary{Colors.NC}")
        print(f"{Colors.BLUE}{'=' * 50}{Colors.NC}")
        
        if self.errors:
            print(f"\n{Colors.RED}Errors ({len(self.errors)}):${Colors.NC}")
            for error in self.errors:
                print(f"  • {error}")
        
        if self.warnings:
            print(f"\n{Colors.YELLOW}Warnings ({len(self.warnings)}):${Colors.NC}")
            for warning in self.warnings:
                print(f"  • {warning}")
        
        passed_tests = sum(results)
        total_tests = len(results)
        
        print(f"\n{Colors.BLUE}Tests passed: {passed_tests}/{total_tests}{Colors.NC}")
        
        if all(results) and not self.errors:
            print(f"\n{Colors.GREEN}✓ All tests passed!{Colors.NC}")
            return True
        elif self.errors:
            print(f"\n{Colors.RED}✗ Tests failed with errors{Colors.NC}")
            return False
        else:
            print(f"\n{Colors.YELLOW}⚠ Tests passed with warnings{Colors.NC}")
            return True

def main():
    script_dir = Path(__file__).parent
    project_root = script_dir.parent
    translations_dir = project_root / "sddm-theme" / "translations"
    
    if not translations_dir.exists():
        print(f"{Colors.RED}Error: Translations directory not found: {translations_dir}{Colors.NC}")
        sys.exit(1)
    
    tester = TranslationTester(translations_dir)
    success = tester.run_all_tests()
    
    sys.exit(0 if success else 1)

if __name__ == "__main__":
    main()
