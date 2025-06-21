#!/usr/bin/env python3
"""
Claude Code Global Rules Setup
Creates CLAUDE.local.md files that reference global context from knowledge directory
"""

import os
import sys
from datetime import datetime
from pathlib import Path

def setup_claude_rules():
    """Set up Claude Code global rules with CLAUDE.local.md files"""
    
    # Paths
    dotfiles_dir = Path.home() / "ppv" / "pillars" / "dotfiles"
    source_rules = dotfiles_dir / "knowledge"
    
    print("Setting up Claude Code global rules...")
    
    if not source_rules.exists():
        print(f"❌ No Claude rules found in {source_rules}")
        return False
    
    # Create CLAUDE.local.md in home directory for global context
    home_claude_file = Path.home() / "CLAUDE.local.md"
    
    # Generate content that references all knowledge files
    claude_content = generate_claude_content(source_rules)
    
    # Handle existing file
    if home_claude_file.exists():
        # Backup existing file
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        backup_file = Path.home() / f"CLAUDE.local.md.backup.{timestamp}"
        
        print(f"Backing up existing CLAUDE.local.md to {backup_file}")
        home_claude_file.rename(backup_file)
    
    # Write new CLAUDE.local.md
    home_claude_file.write_text(claude_content)
    print("✅ Claude Code global rules configured")
    
    # Also create in dotfiles directory for when working in that repo
    dotfiles_claude_file = dotfiles_dir / "CLAUDE.local.md"
    dotfiles_claude_file.write_text(claude_content)
    print("✅ Global context configuration installed")
    
    # Validation: Assert file counts match (same confidence-inducing test as Amazon Q)
    source_files = list(source_rules.glob("**/*.md"))
    
    # Count embedded content sections in generated files
    generated_sections = claude_content.count("### ")  # Each principle/procedure becomes a section
    
    print(f"\nValidation:")
    print(f"Source files: {len(source_files)}")
    print(f"Generated sections: {generated_sections}")
    
    if generated_sections == len(source_files) and home_claude_file.exists() and dotfiles_claude_file.exists():
        print("✅ File count assertion passed")
        print("✅ Claude Code global rules setup complete")
        return True
    else:
        print("❌ File count assertion failed!")
        print("Source files:")
        for f in source_files:
            print(f"  {f.relative_to(source_rules)}")
        print(f"Expected {len(source_files)} sections, got {generated_sections}")
        return False

def generate_claude_content(source_rules):
    """Generate CLAUDE.local.md content that includes all knowledge files"""
    
    content = []
    content.append("# Global Development Context")
    content.append("")
    content.append("This file provides global context for Claude Code across all projects.")
    content.append("It references the centralized knowledge base from the dotfiles repository.")
    content.append("")
    
    # Add main knowledge README first
    main_readme = source_rules / "README.md"
    if main_readme.exists():
        try:
            readme_content = main_readme.read_text().strip()
            content.append("### Knowledge Base Overview")
            content.append("")
            content.append(readme_content)
            content.append("")
        except Exception as e:
            print(f"Warning: Could not read {main_readme}: {e}")
    
    # Add principles
    principles_dir = source_rules / "principles"
    if principles_dir.exists():
        content.append("## Core Principles")
        content.append("")
        
        # Add principles README first
        principles_readme = principles_dir / "README.md"
        if principles_readme.exists():
            try:
                readme_content = principles_readme.read_text().strip()
                content.append("### Principles Overview")
                content.append("")
                content.append(readme_content)
                content.append("")
            except Exception as e:
                print(f"Warning: Could not read {principles_readme}: {e}")
        
        # Read and include each principle file
        for principle_file in sorted(principles_dir.glob("*.md")):
            if principle_file.name == "README.md":
                continue
            
            try:
                principle_content = principle_file.read_text().strip()
                content.append(f"### {principle_file.stem.replace('-', ' ').title()}")
                content.append("")
                content.append(principle_content)
                content.append("")
            except Exception as e:
                print(f"Warning: Could not read {principle_file}: {e}")
    
    # Add procedures
    procedures_dir = source_rules / "procedures"
    if procedures_dir.exists():
        content.append("## Development Procedures")
        content.append("")
        
        # Add procedures README first
        procedures_readme = procedures_dir / "README.md"
        if procedures_readme.exists():
            try:
                readme_content = procedures_readme.read_text().strip()
                content.append("### Procedures Overview")
                content.append("")
                content.append(readme_content)
                content.append("")
            except Exception as e:
                print(f"Warning: Could not read {procedures_readme}: {e}")
        
        # Read and include each procedure file
        for procedure_file in sorted(procedures_dir.glob("*.md")):
            if procedure_file.name == "README.md":
                continue
            
            try:
                procedure_content = procedure_file.read_text().strip()
                content.append(f"### {procedure_file.stem.replace('-', ' ').title()}")
                content.append("")
                content.append(procedure_content)
                content.append("")
            except Exception as e:
                print(f"Warning: Could not read {procedure_file}: {e}")
    
    # Add footer with source information
    content.append("---")
    content.append("")
    content.append("*This file is automatically generated from the dotfiles knowledge base.*")
    content.append(f"*Source: {source_rules}*")
    content.append(f"*Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}*")
    
    return "\n".join(content)

if __name__ == "__main__":
    success = setup_claude_rules()
    sys.exit(0 if success else 1)
