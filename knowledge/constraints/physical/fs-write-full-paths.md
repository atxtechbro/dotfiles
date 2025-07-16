# fs_write Full Path Rule

Always use absolute paths in fs_write operations.

**Rule:** Use `/full/path` or `~/path` - never relative paths like `./file`

Prevents fs_write path resolution errors.

## Validation from Anthropic

Anthropic's engineering team had the same experience: "While building our agent for SWE-bench, we actually spent more time optimizing our tools than the overall prompt. For example, we found that the model would make mistakes with tools using relative filepaths after the agent had moved out of the root directory. To fix this, we changed the tool to always require absolute filepaths—and we found that the model used this method flawlessly."

Source: https://www.anthropic.com/engineering/building-effective-agents
