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
- **Commit early and often**: Each commit is a tracer round showing trajectory
- **Short feedback loops over long planning**: Rapid iteration beats extensive upfront design
- **Human checkpoint pauses**: Stop for feedback when encountering blockers or at natural decision points
- **AI-human feedback loop**: Core to this approach - neither operates in isolation
- **Stopping conditions**: Maintain control with maximum iterations or clear completion criteria

## Target-First Development
This principle naturally leads to test-driven behaviors:
1. Define the target (write the test/criteria)
2. Fire and miss (see it fail - confirms target detection works)
3. Adjust aim (modify implementation)
4. Fire again (run test)
5. Repeat until you hit (test passes)
6. Confirm stability (multiple hits = reliable solution)

This principle enables effective development in unfamiliar territory by providing constant course correction through environmental feedback - but it all starts with having a clear target to aim at.
