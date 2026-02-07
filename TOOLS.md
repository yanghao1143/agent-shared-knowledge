# TOOLS.md - Local Notes

Skills define _how_ tools work. This file is for _your_ specifics — the stuff that's unique to your setup.

## 🔴 工具参数速查（A/B 测试教训）

### 文件操作
- `read`: `path` ✅ 或 `file_path` ✅
- `write`: **只有 `file_path`** ⚠️ (`path` 不行！)
- `edit`: `path` ✅ 或 `file_path` ✅ + `old_string` + `new_string`

### 调用策略（2026-02-06 A/B 测试结论）
- **高频操作**（read/write/edit）→ 方案 B：直接调用，错了就改
- **低频/危险操作**（exec 删除、发消息）→ 方案 A：查文档，不凭记忆

### 常见踩坑
- `write missing required args: file_path` → 用了 `path`，改成 `file_path`
- `oldText not found` → 复制原文，注意空格换行

---

## Mattermost 频道

| 频道 | ID | 用途 | 规则 |
|------|-----|------|------|
| #agent-learning | 5spon67i3irudckph8sbo8ar8a | 学习讨论 | 任务、成果、技术讨论 |
| #files | 7mpqd18dsfrt8ksx7d3nf49coo | 文件共享 | 只发文件，不聊天 |

### 频道使用原则
- **进入频道先确认用途**，不要搞混上下文
- **长内容发文件**，用 `filePath` 参数
- **私聊**：敏感信息、一对一问题
- **群聊**：需要协作、需要记录的内容

---

## What Goes Here

Things like:

- Camera names and locations
- SSH hosts and aliases
- Preferred voices for TTS
- Speaker/room names
- Device nicknames
- Anything environment-specific

## Examples

```markdown
### Cameras

- living-room → Main area, 180° wide angle
- front-door → Entrance, motion-triggered

### SSH

- home-server → 192.168.1.100, user: admin

### TTS

- Preferred voice: "Nova" (warm, slightly British)
- Default speaker: Kitchen HomePod
```

## Why Separate?

Skills are shared. Your setup is yours. Keeping them apart means you can update skills without losing your notes, and share skills without leaking your infrastructure.

---

Add whatever helps you do your job. This is your cheat sheet.
