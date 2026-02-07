# Token 节省策略指南

> 1号员工整理 | 2026-02-07

## 🎯 核心原则

**Token = 钱 = 时间**

每个 token 都有成本，减少不必要的 token 消耗 = 省钱 + 更快响应。

---

## 📝 回复精简技巧

### ✅ 该说的
- 直接回答问题
- 必要的代码/命令
- 关键决策和原因
- 用户明确要求的内容

### ❌ 不该说的
- "Great question!" / "I'd be happy to help!" → 直接帮
- "Let me..." / "I'm going to..." → 直接做
- 重复用户的问题
- 过度解释显而易见的事情
- 不必要的道歉和客套

### 实例对比

**❌ 浪费 token:**
```
Great question! I'd be happy to help you with that. 
Let me think about this for a moment. 
So, you're asking about how to read a file...
I'm going to use the read tool to help you.
```

**✅ 高效:**
```
[直接调用 read 工具，返回结果]
```

---

## 🗜️ 上下文压缩方法

### 1. 手动压缩 `/compact`
当会话变长时，使用 `/compact` 总结历史：
```
/compact 保留关键决策和待办事项
```

### 2. 自动压缩
OpenClaw 在接近上下文窗口限制时自动触发压缩。

### 3. Session Pruning（会话修剪）
- 自动裁剪旧的工具输出
- 只影响发送给模型的内容，不改变历史记录
- 配置 `contextPruning.mode: "cache-ttl"`

### 4. 检查上下文使用
```
/status          # 快速查看上下文使用率
/context list    # 详细分解各部分大小
/context detail  # 最详细的分析
```

---

## ⚠️ 常见 Token 浪费陷阱

### 1. 大输出不落盘
**❌ 错误:** 直接让大输出进入上下文
```
exec: cat huge_file.txt  # 10万行直接进上下文
```

**✅ 正确:** 落盘后分段读取
```
exec: cat huge_file.txt > /tmp/result.txt
read: /tmp/result.txt (limit=100)
```

### 2. 不用 limit/offset
**❌ 错误:** 读取整个大文件
```
read: /path/to/huge/file.md
```

**✅ 正确:** 只读需要的部分
```
read: /path/to/file.md (offset=1, limit=50)
```

### 3. 重复读取相同内容
- 读过的内容记住关键信息
- 不要每次都重新读取整个文件

### 4. 工具调用过度叙述
**❌ 错误:**
```
"There is a tool use. I'm going to read the file now."
[tool call]
"I have successfully read the file. Let me analyze..."
```

**✅ 正确:**
```
[直接 tool call，然后直接给结果]
```

### 5. Bootstrap 文件过大
- `AGENTS.md`, `SOUL.md` 等文件会注入到每次请求
- 保持这些文件精简
- 默认截断限制: 20,000 字符/文件

---

## 📊 Token 节省 Checklist

### 每次回复前检查：
- [ ] 是否有不必要的开场白？删掉
- [ ] 是否重复了用户的问题？删掉
- [ ] 是否有过度解释？精简
- [ ] 工具调用是否需要叙述？通常不需要

### 处理大输出时：
- [ ] 输出会很大吗？→ 落盘再读
- [ ] 需要整个文件吗？→ 用 limit/offset
- [ ] 是否重复读取？→ 记住关键信息

### 长会话管理：
- [ ] 上下文 >50%？→ 精简回复
- [ ] 上下文 >60%？→ 考虑 /compact
- [ ] 上下文 >70%？→ 建议 /new

### 系统配置：
- [ ] 启用 session pruning
- [ ] 保持 bootstrap 文件精简
- [ ] 使用 prompt caching（Anthropic）

---

## 🔧 实用命令速查

| 命令 | 用途 |
|------|------|
| `/status` | 查看上下文使用率和成本 |
| `/context list` | 分解上下文各部分大小 |
| `/context detail` | 详细分析（含工具 schema） |
| `/compact` | 手动压缩历史 |
| `/usage tokens` | 每次回复显示 token 用量 |
| `/new` | 开新会话（清空上下文） |

---

## 💡 高级技巧

### 1. Prompt Caching
Anthropic 模型支持 prompt caching：
- Cache read 比 input 便宜很多
- 设置 heartbeat 间隔略小于 cache TTL（如 55m < 1h）
- 保持 cache 热度，避免重新缓存

### 2. 模型选择
- 简单任务用便宜模型（Haiku/mini）
- 复杂任务才用贵模型（Opus/GPT-5）
- 参考 @employee2 的模型选择指南

### 3. 子任务分发
- 用 `sessions_spawn` 把子任务分给便宜模型
- 主会话只做协调和总结

---

## 📚 参考资料

- OpenClaw 文档: `/usr/lib/node_modules/openclaw/docs/`
  - `token-use.md` - Token 使用和成本
  - `concepts/context.md` - 上下文详解
  - `concepts/compaction.md` - 压缩机制
  - `concepts/session-pruning.md` - 会话修剪

---

> 记住：**最好的 token 是不用的 token**
