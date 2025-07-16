#!/usr/bin/env python3
"""
AI Provider Agnostic Rules Setup
Consolidated setup for multiple AI coding assistants from single source of truth
"""

import os
import sys
import shutil
from abc import ABC, abstractmethod
from datetime import datetime
from pathlib import Path

class AIProviderSetup(ABC):
    """Base class for AI provider rule setup"""
    
    def __init__(self, provider_name):
        self.provider_name = provider_name
        self.dotfiles_dir = Path.home() / "ppv" / "pillars" / "dotfiles"
        self.source_rules = self.dotfiles_dir / "knowledge"
    
    def setup_rules(self):
        """Main setup method - template pattern"""
        print(f"Setting up {self.provider_name} global rules...")
        
        if not self.source_rules.exists():
            print(f"❌ No {self.provider_name} rules found in {self.source_rules}")
            return False
        
        # Provider-specific setup
        success = self._setup_provider_specific()
        
        if success:
            # Validation
            return self._validate_setup()
        
        return False
    
    @abstractmethod
    def _setup_provider_specific(self):
        """Provider-specific setup logic"""
        pass
    
    @abstractmethod
    def _validate_setup(self):
        """Provider-specific validation"""
        pass
    
    def _get_source_files(self):
        """Get all source markdown files"""
        return list(self.source_rules.glob("**/*.md"))
    
    def _backup_existing_file(self, file_path):
        """Create timestamped backup of existing file"""
        if file_path.exists():
            timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
            backup_file = file_path.with_suffix(f".backup.{timestamp}")
            print(f"Backing up existing {file_path.name} to {backup_file}")
            file_path.rename(backup_file)

class AmazonQSetup(AIProviderSetup):
    """Amazon Q specific setup"""
    
    def __init__(self):
        super().__init__("Amazon Q")
        self.target_rules = Path.home() / ".amazonq" / "rules"
        self.source_global_config = self.dotfiles_dir / ".amazonq" / "global_context.json"
        self.target_global_config = Path.home() / ".aws" / "amazonq" / "global_context.json"
    
    def _setup_provider_specific(self):
        """Amazon Q uses symlinks"""
        if not self.source_global_config.exists():
            print(f"❌ No global context config found in {self.source_global_config}")
            return False
        
        # Handle existing target rules
        if self.target_rules.exists() and not self.target_rules.is_symlink():
            # Preserve existing rules as backup outside auto-discovery path
            timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
            backup_dir = Path.home() / f".amazonq/experimental-rules.backup.{timestamp}"
            
            print(f"Preserving existing experimental rules to {backup_dir}")
            shutil.move(str(self.target_rules), str(backup_dir))
            
            # List backup files for easy context addition
            print("Experimental rules preserved (most recent first):")
            md_files = sorted(backup_dir.glob("**/*.md"), key=os.path.getmtime, reverse=True)
            for md_file in md_files[:5]:  # Show top 5 most recent
                print(f"  /context add {md_file}")
            print("Consider making a PR to add useful rules officially to dotfiles repo")
                
        elif self.target_rules.is_symlink():
            # Remove existing symlink
            self.target_rules.unlink()
        
        # Create parent directory if needed
        self.target_rules.parent.mkdir(parents=True, exist_ok=True)
        
        # Create symlink - single source of truth, no ghost copies
        self.target_rules.symlink_to(self.source_rules)
        print("✅ Amazon Q global rules symlinked")
        
        # Set up global context configuration
        self.target_global_config.parent.mkdir(parents=True, exist_ok=True)
        
        # Copy the global context configuration file
        shutil.copy2(str(self.source_global_config), str(self.target_global_config))
        print("✅ Global context configuration installed")
        print("   This fixes Amazon Q's counter-intuitive default of using relative paths for 'global' context")
        
        return True
    
    def _validate_setup(self):
        """Amazon Q validation - file count assertion"""
        source_files = self._get_source_files()
        target_files = list(self.target_rules.glob("**/*.md"))
        
        print(f"\nValidation:")
        print(f"Source files: {len(source_files)}")
        print(f"Target files: {len(target_files)}")
        
        if len(source_files) == len(target_files):
            print("✅ File count assertion passed")
            print("✅ Amazon Q global rules setup complete")
            return True
        else:
            print("❌ File count assertion failed!")
            print("Source files:")
            for f in source_files:
                print(f"  {f.relative_to(self.source_rules)}")
            print("Target files:")
            for f in target_files:
                print(f"  {f.relative_to(self.target_rules)}")
            return False

def main():
    """Main entry point - can setup individual providers or all"""
    import argparse
    
    parser = argparse.ArgumentParser(description="Setup AI provider rules")
    parser.add_argument("--provider", choices=["amazonq"], 
                       default="amazonq", help="Which provider to setup")
    
    args = parser.parse_args()
    
    success = True
    
    if args.provider == "amazonq":
        amazonq_setup = AmazonQSetup()
        success = amazonq_setup.setup_rules()
    
    sys.exit(0 if success else 1)

if __name__ == "__main__":
    main()
