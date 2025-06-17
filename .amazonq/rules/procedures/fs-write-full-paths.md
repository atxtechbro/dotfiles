# fs_write Full Path Rule

Always use absolute paths in fs_write operations.

**Rule:** Use `/full/path` or `~/path` - never relative paths like `./file`

Prevents fs_write path resolution errors.
