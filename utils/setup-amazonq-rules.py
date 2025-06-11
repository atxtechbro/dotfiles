#!/usr/bin/env python3
"""
Amazon Q Global Rules Setup
Symlinks global rules and validates installation
"""

import os
import sys
import glob
import shutil
from datetime import datetime
from pathlib import Path

def setup_amazonq_rules():
    """Set up Amazon Q global rules with symlinks and validation"""
    
    # Paths
    dotfiles_dir = Path.home() / "ppv" / "pillars" / "dotfiles"
    source_rules = dotfiles_dir / ".amazonq" / "rules"
    target_rules = Path.home() / ".amazonq" / "rules"
    
    print("Setting up Amazon Q global rules...")
    
    if not source_rules.exists():
        print(f"❌ No Amazon Q rules found in {source_rules}")
        return False
    
    # Handle existing target
    if target_rules.exists() and not target_rules.is_symlink():
        # Preserve existing rules as backup
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        backup_dir = Path.home() / f".amazonq/rules.backup.{timestamp}"
        
        print(f"Preserving existing global rules to {backup_dir}")
        shutil.move(str(target_rules), str(backup_dir))
        
        # List backup files for easy context addition
        print("Backup files (most recent first):")
        md_files = sorted(backup_dir.glob("**/*.md"), key=os.path.getmtime, reverse=True)
        for md_file in md_files[:5]:  # Show top 5 most recent
            print(f"  /context add {md_file}")
            
    elif target_rules.is_symlink():
        # Remove existing symlink
        target_rules.unlink()
    
    # Create parent directory if needed
    target_rules.parent.mkdir(parents=True, exist_ok=True)
    
    # Create symlink - single source of truth, no ghost copies
    target_rules.symlink_to(source_rules)
    print("✅ Amazon Q global rules symlinked")
    
    # Validation: Assert file counts match
    source_files = list(source_rules.glob("**/*.md"))
    target_files = list(Path.home().glob(".amazonq/**/*.md"))
    
    print(f"\nValidation:")
    print(f"Source files: {len(source_files)}")
    print(f"Target files: {len(target_files)}")
    
    if len(source_files) == len(target_files):
        print("✅ File count assertion passed")
        return True
    else:
        print("❌ File count assertion failed!")
        print("Source files:")
        for f in source_files:
            print(f"  {f.relative_to(source_rules)}")
        print("Target files:")
        for f in target_files:
            print(f"  {f.relative_to(Path.home())}")
        return False

if __name__ == "__main__":
    success = setup_amazonq_rules()
    sys.exit(0 if success else 1)
