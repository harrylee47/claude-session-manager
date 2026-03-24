# Telegram Channel 插件安装指南

## 前提条件

安装 [Bun](https://bun.sh) 运行时：

```bash
curl -fsSL https://bun.sh/install | bash
```

## 步骤

### 1. 在 Telegram 创建 Bot

1. 打开 Telegram，找到 [@BotFather](https://t.me/BotFather)，发送 `/newbot`
2. 设置 bot 的**显示名称**（任意，可含空格）
3. 设置 bot 的**用户名**（必须以 `bot` 结尾，如 `my_assistant_bot`）
4. 复制 BotFather 返回的 token（格式如 `123456789:AAHfiqksKZ8...`，包含前面的数字和冒号）

### 2. 安装插件

启动 Claude Code 会话后执行：

```
/plugin install telegram@claude-plugins-official
```

### 3. 配置 Bot Token

```
/telegram:configure 123456789:AAHfiqksKZ8...
```

Token 会写入 `~/.claude/channels/telegram/.env`，也可以手动编辑该文件或通过 shell 环境变量 `TELEGRAM_BOT_TOKEN` 设置（环境变量优先级更高）。

### 4. 带 Channel 标志启动 Claude Code

```bash
claude --channels plugin:telegram@claude-plugins-official
```

或使用自定义脚本 `claude-start`（已内置该参数）：

```bash
claude-start <session-name>
```

### 5. 配对用户

1. 在 Telegram 上给你的 bot 发一条消息
2. Bot 会回复一个 **6 位配对码**
3. 在 Claude Code 会话中执行：

```
/telegram:access pair <配对码>
```

配对成功后，后续消息会直接转发给 Claude。

### 6. 锁定访问（推荐）

配对完成后，切换到 allowlist 模式防止陌生人触发配对：

```
/telegram:access policy allowlist
```

## 常用管理命令

| 命令 | 说明 |
|------|------|
| `/telegram:configure` | 查看当前配置状态 |
| `/telegram:configure clear` | 清除 bot token |
| `/telegram:access` | 查看访问控制状态 |
| `/telegram:access allow <user_id>` | 手动添加用户到白名单 |
| `/telegram:access remove <user_id>` | 从白名单移除用户 |
| `/telegram:access policy <mode>` | 设置 DM 策略（pairing / allowlist / disabled） |
| `/telegram:access group add <group_id>` | 添加群组访问权限 |

## 注意事项

- Telegram Bot API **不支持历史消息和搜索**，bot 只能看到实时到达的消息
- 照片会自动下载到 `~/.claude/channels/telegram/inbox/`，Telegram 会压缩图片；需要原图请以「文件」方式发送
- 获取自己的数字用户 ID 可以找 [@userinfobot](https://t.me/userinfobot)
