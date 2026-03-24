---
name: claude-ls
description: List all running tmux sessions. Use when the user wants to see active sessions.
user-invocable: true
disable-model-invocation: true
allowed-tools:
  - Bash(tmux *)
---

# /claude-ls — List tmux sessions

Run this command and show the output:

```bash
tmux list-sessions -F "#{session_name}  (#{session_windows} windows, created #{session_created_string})" 2>/dev/null || echo "No tmux sessions running."
```
