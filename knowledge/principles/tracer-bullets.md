# Tracer Bullets Development

Like military tracer rounds that help soldiers adjust their aim in real-time, each iteration provides immediate feedback to guide the next action. But first, you need a target.

This approach acknowledges that even experts often discover what they want through seeing attempts - "I'll know it when I see it" is valid. Rather than spending extensive time specifying exact requirements upfront, tracer bullets allow the vision to emerge through rapid iterations of "a little to the left, a little to the right."

## Establishing the Target
Before firing any rounds, define what you're aiming at:
- **Clear success criteria**: What does "hitting the target" look like? (tests, expected outputs, acceptance criteria)
- **Negative space mapping**: Understanding what failure looks like helps define the target's boundaries
- **Measurable outcomes**: Targets must be observable - you need to know when you've hit or missed
- **Emergent clarity**: The target itself may become clearer through iterations - expert intuition often needs concrete attempts to crystallize

## Iterative Targeting
Once you have a target, use tracer rounds to zero in:
- **Ground truth at each step**: Gain concrete feedback from the environment (tool results, code execution, system responses)
- **Progress assessment**: Each cycle/loop/iteration should feel like getting closer to the target
- **Adjust aim, not target**: Keep success criteria stable while refining your approach
- **Walk fire onto target**: Start with rough attempts, progressively refine precision

## Feedback Mechanisms
- **Observable units of change**: Feedback happens at the level where changes become meaningful - typically PRs
- **Trajectory over perfection**: Early attempts show direction; subsequent adjustments refine the aim
- **Appropriate altitude**: Review at the level that balances completeness with comprehension
- **AI-human feedback loop**: Core to this approach - neither operates in isolation
- **Natural rhythm emerges**: Not prescriptive steps, but a pattern of attempt → feedback → adjustment

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