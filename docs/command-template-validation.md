# Command Template Validation

## The System

This codebase enforces **Generation-Time Validation** - a pattern where all validation happens at command generation time (zero tokens) rather than runtime (wastes tokens).

## Key Components

### 1. Template Creator (`utils/create-command-template.sh`)
The **ONLY** blessed way to create new slash commands. This tool:
- Creates properly structured templates
- Adds validation stubs to the generator
- Makes the right path the only obvious path

### 2. Validation Checker (`utils/check-template-validation.sh`)
Detects anti-patterns in templates:
- Validation logic in templates (should be in generator)
- Conditional checks that waste tokens
- Error handling that belongs at generation time

### 3. Pre-commit Hook (`.git-hooks/pre-commit`)
Prevents committing templates with validation anti-patterns.

### 4. Generator Comments
Clear injection point in `generate-commands.sh` with examples.

## The Principle

> "If it can be validated at generation time, it must be validated at generation time"

## Quick Reference

**Creating a command:**
```bash
./utils/create-command-template.sh my-command PARAM1 PARAM2
```

**Checking for violations:**
```bash
./utils/check-template-validation.sh
```

**Where validation goes:**
- ❌ NOT in `commands/templates/*.md`
- ✅ ONLY in `utils/generate-commands.sh` case statement

## Why This Matters

Every validation in a template costs tokens on EVERY failure. Moving validation to generation time means failures cost zero tokens - they fail before the AI even sees them.

This is the difference between:
- Heroic efforts to optimize after the fact
- Systems that guide you to the right choice by default