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

class ClaudeCodeSetup(AIProviderSetup):
    """Claude Code specific setup"""
    
    def __init__(self):
        super().__init__("Claude Code")
        self.home_claude_file = Path.home() / "CLAUDE.local.md"
        self.dotfiles_claude_file = self.dotfiles_dir / "CLAUDE.local.md"
    
    def _setup_provider_specific(self):
        """Claude Code uses generated content files"""
        # Generate content that references all knowledge files
        claude_content = self._generate_claude_content()
        
        # Handle existing files
        self._backup_existing_file(self.home_claude_file)
        
        # Write new CLAUDE.local.md files
        self.home_claude_file.write_text(claude_content)
        print("✅ Claude Code global rules configured")
        
        # Also create in dotfiles directory for when working in that repo
        self.dotfiles_claude_file.write_text(claude_content)
        print("✅ Global context configuration installed")
        
        return True
    
    def _validate_setup(self):
        """Claude Code validation - section count assertion"""
        source_files = self._get_source_files()
        
        # Count embedded content sections in generated files
        claude_content = self.home_claude_file.read_text()
        generated_sections = claude_content.count("### ")  # Each file becomes a section
        
        print(f"\nValidation:")
        print(f"Source files: {len(source_files)}")
        print(f"Generated sections: {generated_sections}")
        
        if generated_sections == len(source_files) and self.home_claude_file.exists() and self.dotfiles_claude_file.exists():
            print("✅ File count assertion passed")
            print("✅ Claude Code global rules setup complete")
            return True
        else:
            print("❌ File count assertion failed!")
            print("Source files:")
            for f in source_files:
                print(f"  {f.relative_to(self.source_rules)}")
            print(f"Expected {len(source_files)} sections, got {generated_sections}")
            return False
    
    def _generate_claude_content(self):
        """Generate CLAUDE.local.md content that includes all knowledge files"""
        
        content = []
        content.append("# Global Development Context")
        content.append("")
        content.append("This file provides global context for Claude Code across all projects.")
        content.append("It references the centralized knowledge base from the dotfiles repository.")
        content.append("")
        
        # Add main knowledge README first
        main_readme = self.source_rules / "README.md"
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
        principles_dir = self.source_rules / "principles"
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
        procedures_dir = self.source_rules / "procedures"
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
        content.append(f"*Source: {self.source_rules}*")
        content.append(f"*Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}*")
        
        return "\n".join(content)

def main():
    """Main entry point - can setup individual providers or all"""
    import argparse
    
    parser = argparse.ArgumentParser(description="Setup AI provider rules")
    parser.add_argument("--provider", choices=["amazonq", "claude", "all"], 
                       default="all", help="Which provider to setup")
    
    args = parser.parse_args()
    
    success = True
    
    if args.provider in ["amazonq", "all"]:
        amazonq_setup = AmazonQSetup()
        success &= amazonq_setup.setup_rules()
        if args.provider == "all":
            print()  # Add spacing between providers
    
    if args.provider in ["claude", "all"]:
        claude_setup = ClaudeCodeSetup()
        success &= claude_setup.setup_rules()
    
    sys.exit(0 if success else 1)

if __name__ == "__main__":
    main()
