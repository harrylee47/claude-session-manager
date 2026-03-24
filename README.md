# Claude Code 多会话管理系统

基于 tmux 的 Claude Code 后台会话管理方案，支持多会话并行、后台运行、随时切换。

## 设计思路

### 要解决的问题

Claude Code 默认运行在前台终端，关闭终端窗口会话就没了。当需要同时处理多个项目、或者希望 Claude 在后台持续运行（比如通过 Telegram 远程对话），就需要一套会话管理机制。

### 方案选择

选用 **tmux** 作为会话容器：

- 会话与终端窗口解耦，关闭窗口不影响运行
- 原生支持多会话并行
- 可以随时 attach/detach，在不同终端间切换
- macOS 自带或通过 Homebrew 安装

### 整体架构

```
终端 / SSH ──attach──► tmux session "coding" ──► claude (项目A)
                       tmux session "chat"   ──► claude (聊天)
                       tmux session "debug"  ──► claude (调试)
                         ▲
Telegram Bot ────────────┘ (通过 --channels 接收消息)
```

每个 tmux session 运行一个独立的 Claude Code 实例，互不干扰。

## 实现

### 文件结构

```
~/.local/bin/
├── claude-start      # 创建并启动会话
├── claude-attach     # 连接到已有会话
├── claude-detach     # 从外部让会话转入后台
├── claude-stop       # 停止会话
├── claude-ls         # 列出所有会话
└── claude-help       # 显示帮助

~/.claude/skills/
├── claude-start/SKILL.md    # 会话内启动新会话
├── claude-switch/SKILL.md   # 会话内切换会话
├── claude-hide/SKILL.md     # 会话内转入后台
├── claude-ls/SKILL.md       # 会话内列出会话
└── claude-stop/SKILL.md     # 会话内停止会话
```

两套工具配合使用：
- **终端命令**（`~/.local/bin/claude-*`）：在普通 shell 中管理会话
- **Skill 斜杠命令**（`~/.claude/skills/claude-*/`）：在 Claude Code 会话内部管理会话

### 核心脚本详解

#### claude-start — 启动会话

```bash
#!/bin/zsh
# Usage: claude-start [-y] [session-name]
#   -y   跳过权限确认（dangerously-skip-permissions）

SKIP_PERMS=false
SESSION="claude"

for arg in "$@"; do
  case "$arg" in
    -y) SKIP_PERMS=true ;;
    *)  SESSION="$arg" ;;
  esac
done

# 如果会话已存在，直接连接
if tmux has-session -t "$SESSION" 2>/dev/null; then
  echo "Session '$SESSION' already running, attaching..."
  tmux attach -t "$SESSION"
  exit 0
fi

# 构建启动命令，--name 让 Claude Code 对话名与 tmux session 名一致
CMD="claude --remote-control --channels plugin:telegram@claude-plugins-official --name $SESSION"
if $SKIP_PERMS; then
  CMD="$CMD --dangerously-skip-permissions"
fi

# 后台创建 tmux session
tmux new-session -d -s "$SESSION" -c "$PWD" "$CMD"

# 自动确认 workspace trust 弹窗
sleep 2
tmux send-keys -t "$SESSION" Enter

# 连接到会话
tmux attach -t "$SESSION"
```

关键设计点：
- **`--remote-control`**：启用远程控制，允许外部通过 channel 发送消息
- **`--channels plugin:telegram@claude-plugins-official`**：连接 Telegram channel
- **`--name $SESSION`**：让 Claude Code 对话名与 tmux session 名保持一致，方便识别
- **`-c "$PWD"`**：在当前目录下启动，Claude Code 会以该目录为工作目录
- **自动确认**：`sleep 2 && send-keys Enter` 自动跳过 workspace trust 确认

#### claude-attach — 连接会话

```bash
#!/bin/zsh
# Usage: claude-attach [session-name]

SESSION="${1:-claude}"

if tmux has-session -t "$SESSION" 2>/dev/null; then
  tmux attach -t "$SESSION"
else
  echo "No session '$SESSION' running. Use 'claude-start $SESSION' to start one."
fi
```

#### claude-detach — 外部分离会话

```bash
#!/bin/zsh
# Usage: claude-detach [session-name]

SESSION="${1:-claude}"

if tmux has-session -t "$SESSION" 2>/dev/null; then
  tmux detach-client -t "$SESSION"
  echo "Detached from session '$SESSION'."
else
  echo "No session '$SESSION' running."
fi
```

与 `/claude-hide` 的区别：`claude-detach` 从另一个终端窗口运行，`/claude-hide` 在 Claude Code 会话内部执行。

#### claude-stop — 停止会话

```bash
#!/bin/zsh
# Usage: claude-stop [session-name]

SESSION="${1:-claude}"

if tmux has-session -t "$SESSION" 2>/dev/null; then
  tmux kill-session -t "$SESSION"
  echo "Session '$SESSION' stopped."
else
  echo "No session '$SESSION' running."
fi
```

#### claude-ls — 列出会话

```bash
#!/bin/zsh
tmux ls 2>/dev/null || echo "No tmux sessions running."
```

### Skill 斜杠命令详解

Skill 让 Claude Code 自己通过 tmux 命令管理会话。每个 Skill 是一个 `SKILL.md` 文件，定义了名称、描述、允许的工具和执行逻辑。

#### /claude-hide — 转入后台

在会话内执行 `tmux detach-client`，会话继续后台运行。适合 Telegram 远程场景——隐藏后 Claude 仍然能通过 Telegram 接收和回复消息。

#### /claude-switch — 切换会话

执行 `tmux switch-client -t <name>` 跳转到另一个会话。不需要退出当前会话。

#### /claude-start — 会话内启动新会话

在当前会话中创建新的 tmux session 并切换过去。用 `tmux new-session -d` + `tmux switch-client` 实现，不需要回到终端。

#### /claude-ls — 列出会话

显示所有运行中的 tmux session 名称、窗口数和创建时间。

#### /claude-stop — 停止会话

终止指定的 tmux session。如果是当前所在的 session 会先警告。

## 使用场景

### 场景一：多项目并行开发

```bash
cd ~/projects/CLIProxyAPI
claude-start proxy          # 启动 proxy 项目会话

cd ~/projects/cortex
claude-start cortex         # 启动 cortex 项目会话

claude-ls                   # 查看所有会话
claude-attach proxy         # 切回 proxy 会话
```

### 场景二：后台运行 + Telegram 远程控制

```bash
claude-start assistant      # 启动会话
# 在 Claude Code 内执行 /claude-hide 转入后台
# 现在可以通过 Telegram 继续和 Claude 对话
# 需要时随时 claude-attach assistant 重新连接
```

### 场景三：会话内切换

在 Claude Code 会话中直接操作：

```
/claude-ls                  # 看看有哪些会话
/claude-switch cortex       # 切到 cortex
/claude-start newproject    # 开一个新会话并跳过去
/claude-hide                # 把当前会话藏到后台
```

## 安装

1. 确保已安装 tmux：

```bash
brew install tmux
```

2. 将脚本放入 `~/.local/bin/` 并添加执行权限：

```bash
chmod +x ~/.local/bin/claude-*
```

3. 确保 `~/.local/bin` 在 PATH 中（zsh）：

```bash
# ~/.zshrc
export PATH="$HOME/.local/bin:$PATH"
```

4. Skill 文件放入 `~/.claude/skills/` 对应目录，Claude Code 会自动识别。

## 快速参考

| 场景 | 终端命令 | 会话内命令 |
|------|----------|-----------|
| 启动新会话 | `claude-start [name]` | `/claude-start [name]` |
| 连接会话 | `claude-attach [name]` | `/claude-switch <name>` |
| 转入后台 | `claude-detach [name]` | `/claude-hide` |
| 停止会话 | `claude-stop [name]` | `/claude-stop [name]` |
| 列出会话 | `claude-ls` | `/claude-ls` |
| 查看帮助 | `claude-help` | — |

所有命令的 `[name]` 参数默认值为 `claude`。
