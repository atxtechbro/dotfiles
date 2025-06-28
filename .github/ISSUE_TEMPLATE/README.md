# Issue Templates Philosophy

## From Compliance to Tools

This directory contains our unified issue template, born from the realization during PR #629's retro that templates should enable workflows, not constrain them.

## Intended Audience

**Primary**: AI agents searching for similar issues and patterns
**Secondary**: Humans who create issues frequently (especially via `/create-issue`)

## Design Principles

- **Natural language over form-filling**: Write like you'd search
- **Minimal viable metadata**: Every field must earn its token cost  
- **Discovery-optimized**: Keywords and exact errors for future searches
- **One flexible template**: Replaces 4-5 rigid templates that felt bureaucratic

## The Shift

We moved from "templates as compliance" (data collection) to "templates as tools" (workflow enablement). This reflects our broader pattern of making tools more lovable and human-centered while optimizing for AI discovery.

## Token Economics

Less is more - avoid false positives in search. The simpler the template, the more likely people will use it authentically rather than treating it as paperwork.

Principle: developer-experience