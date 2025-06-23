# Prompt Orchestrator Security

## Security Improvements

Based on code review feedback, the following security enhancements have been implemented:

### 1. Path Traversal Protection

**Issue**: User-controlled input in file paths could allow access to files outside intended directories.

**Solution**:
- All file paths are normalized and resolved to absolute paths
- Parent directory references (`..`) and absolute paths are rejected
- Resolved paths are verified to be within allowed directories
- Both `INJECT:` and variable file resolution are protected

### 2. Command Injection Protection

**Issue**: Using `shell=True` in subprocess calls could allow command injection.

**Solution**:
- Changed to `shell=False` for subprocess execution
- Added validation to reject commands with shell metacharacters (`;`, `&`, `|`, `$`, etc.)
- Commands are split into arguments array instead of passed as strings
- Consider disabling `EXEC:` functionality entirely in production environments

### 3. Enhanced Exception Handling

**Issue**: Missing exception handling for function calls and broad exception catching.

**Solution**:
- Added try-except blocks around custom and built-in function execution
- Specific exception handling for JSON parsing (JSONDecodeError)
- Specific exception handling for file I/O operations (OSError, IOError)
- Error messages are returned in placeholder format for visibility

### 4. Safe File Operations

**Solution**:
- All file paths are resolved before operations
- File existence checks before attempting reads
- Proper error messages for missing or inaccessible files

## Security Best Practices

1. **Limit Search Paths**: Only add trusted directories as search paths
2. **Validate Input**: Always validate user-provided template content
3. **Disable EXEC**: Consider removing CommandResolver in production
4. **Audit Functions**: Review all custom functions for security
5. **Principle of Least Privilege**: Run with minimal permissions

## Testing

Run security tests with:
```bash
python test_prompt_security.py
```

This validates:
- Path traversal attempts are blocked
- Command injection is prevented
- Exceptions are handled gracefully
- Invalid JSON doesn't crash the system

Principle: systems-stewardship