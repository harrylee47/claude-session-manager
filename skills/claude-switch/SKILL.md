---
name: claude-switch
description: Switch to another tmux session. Use when the user wants to switch, jump, or go to a different session.
user-invocable: true
disable-model-invocation: true
allowed-tools:
  - Bash(tmux *)
argument-hint: <session-name>
---

# /claude-switch — Switch to another tmux session

Arguments passed: `$ARGUMENTS`

If a session name is provided, switch to it:

```bash
tmux switch-client -t <session-name>
```

If no arguments or the target session doesn't exist, list available sessions first:

```bash
tmux list-sessions -F "#{session_name}  (#{session_windows} windows)" 2>/dev/null
```

Then ask which session to switch to.
