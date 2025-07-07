# Principle of Failure-First Learning

Understand what failure looks like before attempting success. Confirm that your success criteria can actually detect failure.

## Core Concept
By understanding how to detect failure first, we ensure our verification methods are meaningful. A test that cannot fail is not a test at all.

## In Practice
- Verify detection methods work by confirming they identify failures
- Run verifications before implementation to see them fail
- Ensure success criteria can distinguish between working and broken states
- Learn from failure modes to build robust solutions

## Connection to Other Principles
- **Verifiable Intent**: Failure detection validates that criteria are meaningful
- **Tracer Bullets**: Red-green cycle provides immediate feedback
- **Selective Optimization**: Focus on high-value failure modes first

This principle leads to running tests before implementation naturally, ensuring that verification methods are trustworthy guides for development.