---
name: claude-hide
description: Detach from the current tmux session, sending it to background. Use when the user wants to hide, minimize, detach, or background the current session.
user-invocable: true
disable-model-invocation: true
allowed-tools:
  - Bash(tmux *)
---

# /claude-hide — Detach current tmux session

Detach the current client from this tmux session so it keeps running in the background.

Run this command:

```bash
tmux detach-client
```

After running, tell the user:
- Session is now running in background
- Use `claude-attach [name]` or `/claude-ls` to reconnect later
