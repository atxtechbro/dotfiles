#!/usr/bin/env python3
"""
Provider-specific pattern configurations for AI session parsing.

This module defines patterns for different AI providers to enable
provider-agnostic MLflow tracking.
"""

PROVIDER_PATTERNS = {
    'claude': {
        'name': 'Claude Code',
        'tool_use': r'● (\w+)\([^)]*\)',
        'bash_command': r'● Bash\([^)]+\)',
        'git_command': r'● Bash\([^)]*\bgit\b[^)]*\)',
        'user_input': r'^> .+',
        'tool_pattern': r'● (?:Bash|Read|Task|Update|Write|Edit|MultiEdit|Grep|Glob)\([^)]*\)',
        'ansi_escape': r'\x1B(?:[@-Z\\-_]|\[[0-?]*[ -/]*[@-~])',
        'control_chars': r'[\x00-\x08\x0B-\x0C\x0E-\x1F\x7F]',
    },
    'codex': {
        'name': 'OpenAI Codex',
        'tool_use': r'>>> (\w+): .+',
        'bash_command': r'>>> bash: .+',
        'git_command': r'>>> bash: git .+',
        'user_input': r'^User: .+',
        'tool_pattern': r'>>> (?:bash|read|write|edit|search): .+',
        'ansi_escape': r'\x1B(?:[@-Z\\-_]|\[[0-?]*[ -/]*[@-~])',
        'control_chars': r'[\x00-\x08\x0B-\x0C\x0E-\x1F\x7F]',
    },
    'gpt': {
        'name': 'GPT Models',
        'tool_use': r'Function: (\w+)\(.+\)',
        'bash_command': r'Function: bash\(.+\)',
        'git_command': r'Function: bash\(.*git.*\)',
        'user_input': r'^Human: .+',
        'tool_pattern': r'Function: (?:bash|read|write|edit|search)\(.+\)',
        'ansi_escape': r'\x1B(?:[@-Z\\-_]|\[[0-?]*[ -/]*[@-~])',
        'control_chars': r'[\x00-\x08\x0B-\x0C\x0E-\x1F\x7F]',
    },
    'generic': {
        'name': 'Generic AI Provider',
        'tool_use': r'(?:●|>>>|Function:?) (\w+)[:\(].+',
        'bash_command': r'(?:●|>>>|Function:?) (?:Bash|bash)[:\(].+',
        'git_command': r'(?:●|>>>|Function:?) (?:Bash|bash)[:\(].*git.*',
        'user_input': r'^(?:>|User:|Human:) .+',
        'tool_pattern': r'(?:●|>>>|Function:?) (?:Bash|bash|Read|read|Write|write|Edit|edit)[:\(].+',
        'ansi_escape': r'\x1B(?:[@-Z\\-_]|\[[0-?]*[ -/]*[@-~])',
        'control_chars': r'[\x00-\x08\x0B-\x0C\x0E-\x1F\x7F]',
    },
}


def detect_provider(content):
    """
    Auto-detect the AI provider from session content.

    Returns the provider key or 'generic' if uncertain.
    """
    # Look for provider-specific patterns
    if '● Bash(' in content or '● Read(' in content or '● Write(' in content:
        return 'claude'
    elif '>>> bash:' in content or '>>> read:' in content:
        return 'codex'
    elif 'Function: bash(' in content or 'Function: read(' in content:
        return 'gpt'

    # Check for user input patterns
    if content.startswith('>'):
        return 'claude'
    elif 'User:' in content[:100]:
        return 'codex'
    elif 'Human:' in content[:100]:
        return 'gpt'

    # Default to generic patterns
    return 'generic'


def get_provider_patterns(provider=None, content=None):
    """
    Get pattern configuration for the specified provider.

    If provider is not specified, attempts auto-detection from content.
    Falls back to 'generic' patterns if provider is unknown.
    """
    if provider is None and content:
        provider = detect_provider(content)

    if provider not in PROVIDER_PATTERNS:
        provider = 'generic'

    return PROVIDER_PATTERNS[provider]