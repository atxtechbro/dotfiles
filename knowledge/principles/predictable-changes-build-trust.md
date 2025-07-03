# Predictable Changes Build Trust

The expectation that system outputs match mental models, especially in collaborative AI-human workflows where visual review is essential.

## Core Tenets
1. **PR diffs show only intended changes** - No phantom whitespace, no unexpected files
2. **Changes match their description** - What you say you're changing is what changes
3. **Clean start, clean finish** - PRs begin and end in predictable states
4. **Noise kills productivity** - Even one unexplained line derails review flow

## In Practice
- Run `git diff --cached` before every commit to verify changes
- Use `git add -p` for surgical staging when needed
- Configure editors to respect existing formatting
- Test that PR descriptions match actual diffs
- Treat unexpected changes as bugs, not annoyances

## Why This Matters
- GitHub visual diff is part of the essential AI-human feedback loop
- Trust requires predictability
- Cognitive buffer is limited - don't waste it on surprises
- Clean PRs = faster reviews = higher throughput

## Red Flags
- "Why is this file in the diff?"
- "I didn't change that line"
- "This should be a one-line change but shows 50"
- Whitespace or formatting changes in unrelated files
- Binary files appearing unexpectedly

## Connection to Other Principles
- Supports **Throughput Definition** - removes friction from the review cycle
- Enables **Transparency in Agent Work** - clear diffs show clear intent
- Upholds **Systems Stewardship** - predictable systems are maintainable systems