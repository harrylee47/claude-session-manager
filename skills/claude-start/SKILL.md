---
name: claude-start
description: Start a new Claude Code session in tmux and switch to it. Use when the user wants to start, create, or open a new session.
user-invocable: true
disable-model-invocation: true
allowed-tools:
  - Bash(tmux *)
  - Bash(sleep *)
argument-hint: [-y] [session-name]
---

# /claude-start — Start a new session and switch to it

Arguments passed: `$ARGUMENTS`

Parse arguments: `-y` means skip permissions, anything else is the session name (default: `claude`).

1. Check if the session already exists:

```bash
tmux has-session -t <session-name> 2>/dev/null
```

2. If it exists, just switch to it:

```bash
tmux switch-client -t <session-name>
```

3. If it doesn't exist, create it, auto-confirm the workspace trust prompt, then switch:

```bash
tmux new-session -d -s <session-name> "claude --remote-control --channels plugin:telegram@claude-plugins-official"
sleep 2
tmux send-keys -t <session-name> Enter
tmux switch-client -t <session-name>
```

If `-y` is passed, add `--dangerously-skip-permissions` to the claude command.

Tell the user the session is started and switched. Remind them they can use `/claude-switch` to come back.
