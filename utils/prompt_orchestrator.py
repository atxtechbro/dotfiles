#!/usr/bin/env python3
"""
Unified Prompt Orchestration System

A flexible prompt template processing system that supports:
- Variable substitution: {{ VARIABLE_NAME }}
- File injection: {{ INJECT:path/to/file.md }}
- Dynamic functions: {{ FUNCTION_NAME() }}
- Environment variables: {{ ENV:VARIABLE }}
- Command execution: {{ EXEC:command }}
- JSON data extraction: Automatic flattening and mapping

Design Patterns:
- Template Method Pattern: Core template processing algorithm
- Strategy Pattern: Different resolution strategies for placeholders
- Chain of Responsibility: Sequential resolver attempts

Principle: systems-stewardship
Principle: versioning-mindset
"""

import argparse
import json
import os
import re
import subprocess
import sys
from abc import ABC, abstractmethod
from datetime import datetime, date
from pathlib import Path
from typing import Any, Callable, Dict, List, Optional


class PlaceholderResolver(ABC):
    """Abstract base class for placeholder resolution strategies"""
    
    @abstractmethod
    def can_resolve(self, placeholder: str) -> bool:
        """Check if this resolver can handle the placeholder"""
        pass
    
    @abstractmethod
    def resolve(self, placeholder: str, context: Dict[str, Any]) -> Optional[str]:
        """Resolve the placeholder to its value"""
        pass


class VariableResolver(PlaceholderResolver):
    """Resolves simple variable placeholders"""
    
    def can_resolve(self, placeholder: str) -> bool:
        return not any(placeholder.startswith(prefix) for prefix in ['INJECT:', 'ENV:', 'EXEC:']) and '(' not in placeholder
    
    def resolve(self, placeholder: str, context: Dict[str, Any]) -> Optional[str]:
        # Check command line variables first
        if placeholder in context.get('variables', {}):
            return context['variables'][placeholder]
        
        # Check data sources (from JSON, files, etc.)
        if placeholder in context.get('data_sources', {}):
            return context['data_sources'][placeholder]
        
        # Check for variable files in search paths
        for search_path in context.get('search_paths', []):
            search_path = Path(search_path).resolve()
            var_file = search_path / f"{placeholder.lower()}.md"
            
            # Ensure the resolved path is within the search path
            try:
                var_file = var_file.resolve()
                if search_path in var_file.parents and var_file.exists():
                    return var_file.read_text().strip()
            except (OSError, RuntimeError):
                # Skip if path resolution fails
                continue
        
        return None


class FileInjectionResolver(PlaceholderResolver):
    """Resolves INJECT:path/to/file placeholders"""
    
    def can_resolve(self, placeholder: str) -> bool:
        return placeholder.startswith('INJECT:')
    
    def resolve(self, placeholder: str, context: Dict[str, Any]) -> Optional[str]:
        file_path = placeholder[7:]  # Remove 'INJECT:' prefix
        
        # Normalize and check for path traversal attempts
        file_path = os.path.normpath(file_path)
        if '..' in file_path or file_path.startswith('/'):
            return None  # Reject absolute paths and parent directory references
        
        # Try relative to knowledge base first
        knowledge_base = Path(context.get('knowledge_base', Path.cwd() / 'knowledge')).resolve()
        
        try:
            full_path = (knowledge_base / file_path).resolve()
            # Ensure the resolved path is within the knowledge base
            if knowledge_base in full_path.parents or full_path == knowledge_base:
                if full_path.exists():
                    return full_path.read_text()
        except (OSError, RuntimeError):
            # Skip if path resolution fails
            pass
        
        return None


class FunctionResolver(PlaceholderResolver):
    """Resolves function calls like FUNCTION_NAME()"""
    
    def __init__(self):
        self.functions = {}
        self._register_default_functions()
    
    def _register_default_functions(self):
        """Register built-in functions"""
        self.register('CURRENT_DATE', lambda: datetime.now().strftime('%Y-%m-%d'))
        self.register('CURRENT_TIMESTAMP', lambda: datetime.now().isoformat())
        self.register('CURRENT_YEAR', lambda: str(datetime.now().year))
        self.register('CURRENT_MONTH', lambda: datetime.now().strftime('%B'))
    
    def register(self, name: str, func: Callable):
        """Register a custom function"""
        self.functions[name] = func
    
    def can_resolve(self, placeholder: str) -> bool:
        return '(' in placeholder and ')' in placeholder
    
    def resolve(self, placeholder: str, context: Dict[str, Any]) -> Optional[str]:
        match = re.match(r'(\w+)\((.*?)\)', placeholder)
        if not match:
            return None
        
        func_name = match.group(1)
        params = match.group(2)
        
        try:
            # Check for custom functions in context
            custom_functions = context.get('custom_functions', {})
            if func_name in custom_functions:
                return str(custom_functions[func_name](params))
            
            # Check built-in functions
            if func_name in self.functions:
                return str(self.functions[func_name]())
        except Exception as e:
            return f"[ERROR in function {func_name}: {e}]"
        
        return None


class EnvironmentResolver(PlaceholderResolver):
    """Resolves ENV:VARIABLE_NAME placeholders"""
    
    def can_resolve(self, placeholder: str) -> bool:
        return placeholder.startswith('ENV:')
    
    def resolve(self, placeholder: str, context: Dict[str, Any]) -> Optional[str]:
        env_var = placeholder[4:]  # Remove 'ENV:' prefix
        return os.environ.get(env_var)


class CommandResolver(PlaceholderResolver):
    """Resolves EXEC:command placeholders"""
    
    def can_resolve(self, placeholder: str) -> bool:
        return placeholder.startswith('EXEC:')
    
    def resolve(self, placeholder: str, context: Dict[str, Any]) -> Optional[str]:
        command = placeholder[5:]  # Remove 'EXEC:' prefix
        
        # Only allow simple, safe commands (no shell injection)
        # For production use, consider removing this resolver entirely
        # or implementing a whitelist of allowed commands
        if any(char in command for char in [';', '&', '|', '$', '`', '\n', '\r']):
            return "[ERROR: Command contains unsafe characters]"
        
        try:
            # Use shell=False and split command properly
            # This is still potentially dangerous - consider removing EXEC support
            cmd_parts = command.split()
            result = subprocess.run(
                cmd_parts, 
                shell=False, 
                capture_output=True, 
                text=True,
                timeout=10  # 10 second timeout
            )
            return result.stdout.strip()
        except Exception as e:
            return f"[ERROR executing command: {e}]"


class PromptOrchestrator:
    """Main orchestrator for prompt template processing"""
    
    def __init__(self, knowledge_base: Optional[Path] = None):
        self.knowledge_base = knowledge_base or Path.cwd() / 'knowledge'
        self.resolvers: List[PlaceholderResolver] = [
            VariableResolver(),
            FileInjectionResolver(),
            FunctionResolver(),
            EnvironmentResolver(),
            CommandResolver(),
        ]
        self.context: Dict[str, Any] = {
            'knowledge_base': self.knowledge_base,
            'variables': {},
            'data_sources': {},
            'search_paths': [],
            'custom_functions': {},
        }
    
    def add_variable(self, name: str, value: str):
        """Add a variable to the context"""
        self.context['variables'][name] = value
    
    def add_search_path(self, path: Path):
        """Add a search path for variable files"""
        self.context['search_paths'].append(path)
    
    def add_json_file(self, json_path: Path):
        """Load and flatten JSON data into data sources"""
        try:
            json_path = json_path.resolve()
            # Basic path safety check
            if not json_path.exists():
                print(f"Warning: JSON file not found: {json_path}")
                return
                
            content = json_path.read_text()
            data = json.loads(content)
            self._flatten_json(data)
            
            # Also store the entire content
            key = json_path.stem.upper().replace('-', '_').replace(' ', '_')
            self.context['data_sources'][key] = content
        except json.JSONDecodeError as e:
            print(f"Warning: Invalid JSON in {json_path}: {e}")
        except (OSError, IOError) as e:
            print(f"Warning: Failed to read {json_path}: {e}")
        except Exception as e:
            print(f"Warning: Unexpected error loading {json_path}: {e}")
    
    def _flatten_json(self, obj: Dict[str, Any], prefix: str = ""):
        """Flatten nested JSON into data sources"""
        for key, value in obj.items():
            full_key = f"{prefix}_{key}".upper() if prefix else key.upper()
            if isinstance(value, dict):
                self._flatten_json(value, full_key)
            else:
                self.context['data_sources'][full_key] = str(value)
    
    def add_custom_function(self, name: str, func: Callable):
        """Register a custom function"""
        self.context['custom_functions'][name] = func
    
    def find_placeholders(self, template: str) -> List[str]:
        """Find all {{ placeholder }} patterns in template"""
        pattern = r'\{\{\s*([^}]+?)\s*\}\}'
        matches = re.findall(pattern, template)
        return list(set(matches))  # Remove duplicates
    
    def process_template(self, template_content: str) -> tuple[str, List[str]]:
        """
        Process template and return (processed_content, missing_placeholders)
        """
        placeholders = self.find_placeholders(template_content)
        processed = template_content
        missing = []
        
        for placeholder in placeholders:
            resolved = False
            
            # Try each resolver in order
            for resolver in self.resolvers:
                if resolver.can_resolve(placeholder):
                    value = resolver.resolve(placeholder, self.context)
                    if value is not None:
                        # Replace all occurrences of this placeholder
                        pattern = r'\{\{\s*' + re.escape(placeholder) + r'\s*\}\}'
                        processed = re.sub(pattern, value, processed)
                        resolved = True
                        break
            
            if not resolved:
                missing.append(placeholder)
        
        return processed, missing
    
    def process_file(self, template_path: Path, output_path: Optional[Path] = None) -> bool:
        """Process a template file"""
        if not template_path.exists():
            print(f"Error: Template file not found: {template_path}")
            return False
        
        # Auto-detect context from path
        if 'fitness' in str(template_path):
            self.add_search_path(Path('fitness/variables'))
        elif 'fashion' in str(template_path):
            self.add_search_path(Path('fashion/variables'))
        
        try:
            template_content = template_path.read_text()
        except (OSError, IOError) as e:
            print(f"Error: Failed to read template file: {e}")
            return False
        processed, missing = self.process_template(template_content)
        
        if missing:
            print(f"Error: Unresolved placeholders: {missing}")
            print("\nAvailable variables:")
            for key in sorted(self.context['variables'].keys()):
                print(f"  - {key}")
            print("\nAvailable data sources:")
            for key in sorted(self.context['data_sources'].keys()):
                print(f"  - {key}")
            return False
        
        if output_path:
            output_path.write_text(processed)
            print(f"Processed prompt written to {output_path}")
        else:
            print(processed)
        
        return True


def main():
    """Command line interface"""
    parser = argparse.ArgumentParser(
        description='Process prompt templates with advanced orchestration',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  # Basic variable substitution
  prompt_orchestrator.py template.md -v ISSUE_NUMBER=123

  # With output file
  prompt_orchestrator.py template.md -o output.md

  # With JSON data source
  prompt_orchestrator.py template.md -j data.json

  # With custom knowledge base
  prompt_orchestrator.py template.md -k ~/my-knowledge

  # Multiple variables
  prompt_orchestrator.py template.md -v NAME=John -v AGE=30
        """
    )
    
    parser.add_argument('template', type=Path, help='Path to template file')
    parser.add_argument('-o', '--output', type=Path, help='Output file path')
    parser.add_argument('-v', '--var', action='append', default=[],
                       help='Variables in format NAME=value')
    parser.add_argument('-j', '--json', type=Path, action='append', default=[],
                       help='JSON files to load as data sources')
    parser.add_argument('-k', '--knowledge', type=Path,
                       help='Knowledge base directory')
    parser.add_argument('--search-path', type=Path, action='append', default=[],
                       help='Additional search paths for variables')
    
    args = parser.parse_args()
    
    # Initialize orchestrator
    orchestrator = PromptOrchestrator(knowledge_base=args.knowledge)
    
    # Add variables
    for var in args.var:
        if '=' in var:
            name, value = var.split('=', 1)
            orchestrator.add_variable(name, value)
        else:
            print(f"Warning: Invalid variable format: {var}")
    
    # Add JSON files
    for json_file in args.json:
        orchestrator.add_json_file(json_file)
    
    # Add search paths
    for path in args.search_path:
        orchestrator.add_search_path(path)
    
    # Process template
    success = orchestrator.process_file(args.template, args.output)
    sys.exit(0 if success else 1)


if __name__ == "__main__":
    main()