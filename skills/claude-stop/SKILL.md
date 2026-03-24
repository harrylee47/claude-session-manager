---
name: claude-stop
description: Stop/kill a tmux session. Use when the user wants to stop or kill a session.
user-invocable: true
disable-model-invocation: true
allowed-tools:
  - Bash(tmux *)
argument-hint: [session-name]
---

# /claude-stop — Stop a tmux session

Arguments passed: `$ARGUMENTS`

If a session name is provided, kill that session:

```bash
tmux kill-session -t <session-name>
```

If no arguments, list all sessions first and ask which one to stop.

**Never kill the session the user is currently in without warning them it will disconnect.**
