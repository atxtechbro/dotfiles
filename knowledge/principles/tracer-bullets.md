# Tracer Bullets Development

Like military tracer rounds that help soldiers adjust their aim in real-time, each iteration provides immediate feedback to guide the next action. But first, you need a target.

## Establishing the Target
Before firing any rounds, define what you're aiming at:
- **Clear success criteria**: What does "hitting the target" look like? (tests, expected outputs, acceptance criteria)
- **Negative space mapping**: Understanding what failure looks like helps define the target's boundaries
- **Measurable outcomes**: Targets must be observable - you need to know when you've hit or missed

## Iterative Targeting
Once you have a target, use tracer rounds to zero in:
- **Ground truth at each step**: Gain concrete feedback from the environment (tool results, code execution, system responses)
- **Progress assessment**: Each cycle/loop/iteration should feel like getting closer to the target
- **Adjust aim, not target**: Keep success criteria stable while refining your approach
- **Walk fire onto target**: Start with rough attempts, progressively refine precision

## Feedback Mechanisms
- **Pull requests as tracer rounds**: First shot establishes the feedback loop - not expected to hit target immediately
- **Subsequent adjustments via commits**: Once PR shows we're "close enough", fine-tune with commits to the same PR
- **Commit early and often**: Commits show trajectory, both initial attempt and adjustments after feedback
- **OSE perspective**: From "Outside and Slightly Elevated" we review complete changes, not micro-edits
- **Human checkpoint at PR level**: The human sees the full context and provides course correction
- **AI-human feedback loop**: Core to this approach - neither operates in isolation
- **The full sequence**:
  1. PR establishes initial feedback loop (first tracer)
  2. Human feedback indicates adjustments needed
  3. Commits to same PR refine based on feedback (subsequent tracers)
  4. Iterate until target is hit
- **Balance with other principles**: 
  - Start with "go slow to go fast" (proper orientation)
  - Build toward PR with multiple commits (trajectory)
  - Review and adjust at appropriate altitude

## Target-First Development
This principle naturally leads to test-driven behaviors:
1. Define the target (write the test/criteria)
2. Fire and miss (see it fail - confirms target detection works)
3. Adjust aim (modify implementation)
4. Fire again (run test)
5. Repeat until you hit (test passes)
6. Confirm stability (multiple hits = reliable solution)

This principle enables effective development in unfamiliar territory by providing constant course correction through environmental feedback - but it all starts with having a clear target to aim at.

## Relationship to Other Principles
- **Go slow to go fast**: Proper orientation prevents ghost commits in PRs
- **OSE (Outside and Slightly Elevated)**: Review at PR level, not edit-by-edit
- **Versioning mindset**: Each PR iteration improves on the last
- **Systems stewardship**: PRs become teachable units of change

The PR is where principles converge - it's the right altitude for meaningful feedback.