---
name: tool-calling
description: Correct tool parameter names and best practices for OpenClaw tool calls. Use when calling read/write/edit/exec tools, debugging "missing required args" errors, or learning tool calling patterns.
---

# Tool Calling Guide

## Quick Reference

| Tool | Required Parameters | Common Mistake |
|------|---------------------|----------------|
| `read` | `file_path` | ❌ `path` |
| `write` | `file_path`, `content` | ❌ `path` |
| `edit` | `file_path`, `old_string`, `new_string` | ❌ `oldText`/`newText` |
| `exec` | `command` | - |

**Golden Rule: Always use `file_path`, never `path`.**

## Tool Details

### read

```
file_path: string (required) - Path to file
limit: number (optional) - Max lines to read
offset: number (optional) - Start line (1-indexed)
```

For large files, use `limit` and `offset`:
```
read file_path="/path/to/large.log" limit=100 offset=1
```

### write

```
file_path: string (required) - Path to file
content: string (required) - Content to write
```

Creates parent directories automatically. Overwrites if exists.

### edit

```
file_path: string (required) - Path to file
old_string: string (required) - Exact text to find
new_string: string (required) - Replacement text
```

`old_string` must match exactly (including whitespace).

### exec

```
command: string (required) - Shell command
workdir: string (optional) - Working directory
timeout: number (optional) - Timeout in seconds
```

Truncate long output: `command | head -50`

## Common Errors

| Error | Cause | Fix |
|-------|-------|-----|
| `read missing required args: file_path` | Used `path` | Use `file_path` |
| `write missing required args: file_path` | Used `path` | Use `file_path` |
| `edit missing required args: file_path` | Used `path` | Use `file_path` |
| `old_string not found` | Whitespace mismatch | Copy exact text |

## Best Practices

1. **Use `file_path`** - Never `path`
2. **Large files** - Use `limit`/`offset`, don't read entire file
3. **Long output** - Pipe to `head`/`tail` or redirect to file
4. **Edit carefully** - Copy exact text for `old_string`
5. **Don't narrate** - Just call the tool, skip "Let me read..."

## Checklist Before Tool Call

- [ ] Parameter name correct? (`file_path` not `path`)
- [ ] File might be large? (use `limit`)
- [ ] Output might be long? (use `head`/`tail`)
- [ ] Edit: `old_string` exact match?
