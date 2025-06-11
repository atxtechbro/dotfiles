#!/usr/bin/env python3
"""
Amazon Q Global Rules Setup
Symlinks global rules and sets up proper global context configuration
"""

import os
import sys
import shutil
from datetime import datetime
from pathlib import Path

def setup_amazonq_rules():
    """Set up Amazon Q global rules with symlinks and proper global configuration"""
    
    # Paths
    dotfiles_dir = Path.home() / "ppv" / "pillars" / "dotfiles"
    source_rules = dotfiles_dir / ".amazonq" / "rules"
    target_rules = Path.home() / ".amazonq" / "rules"
    source_global_config = dotfiles_dir / ".amazonq" / "global_context.json"
    target_global_config = Path.home() / ".aws" / "amazonq" / "global_context.json"
    
    print("Setting up Amazon Q global rules...")
    
    if not source_rules.exists():
        print(f"❌ No Amazon Q rules found in {source_rules}")
        return False
    
    if not source_global_config.exists():
        print(f"❌ No global context config found in {source_global_config}")
        return False
    
    # Handle existing target rules
    if target_rules.exists() and not target_rules.is_symlink():
        # Preserve existing rules as backup outside auto-discovery path
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        backup_dir = Path.home() / f".amazonq/experimental-rules.backup.{timestamp}"
        
        print(f"Preserving existing experimental rules to {backup_dir}")
        shutil.move(str(target_rules), str(backup_dir))
        
        # List backup files for easy context addition
        print("Experimental rules preserved (most recent first):")
        md_files = sorted(backup_dir.glob("**/*.md"), key=os.path.getmtime, reverse=True)
        for md_file in md_files[:5]:  # Show top 5 most recent
            print(f"  /context add {md_file}")
        print("Consider making a PR to add useful rules officially to dotfiles repo")
            
    elif target_rules.is_symlink():
        # Remove existing symlink
        target_rules.unlink()
    
    # Create parent directory if needed
    target_rules.parent.mkdir(parents=True, exist_ok=True)
    
    # Create symlink - single source of truth, no ghost copies
    target_rules.symlink_to(source_rules)
    print("✅ Amazon Q global rules symlinked")
    
    # Set up global context configuration
    target_global_config.parent.mkdir(parents=True, exist_ok=True)
    
    # Copy the global context configuration file
    shutil.copy2(str(source_global_config), str(target_global_config))
    print("✅ Global context configuration installed")
    print("   This fixes Amazon Q's counter-intuitive default of using relative paths for 'global' context")
    
    # Validation: Assert file counts match
    source_files = list(source_rules.glob("**/*.md"))
    target_files = list(target_rules.glob("**/*.md"))
    
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
            print(f"  {f.relative_to(source_rules)}")
        print("Target files:")
        for f in target_files:
            print(f"  {f.relative_to(target_rules)}")
        return False

if __name__ == "__main__":
    success = setup_amazonq_rules()
    sys.exit(0 if success else 1)
