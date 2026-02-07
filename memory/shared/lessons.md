# 技术教训 (Lessons Learned)

> 跨频道共享的技术教训，每次会话都应加载

## 工具调用

### 参数名
- `read`: 用 `file_path`（`path` 也行但不推荐）
- `write`: **必须用 `file_path`**（`path` 不行！）
- `edit`: 用 `file_path` + `old_string` + `new_string`

### 常见错误
- `write missing required args: file_path` → 用了 `path`，改成 `file_path`
- `old_string not found` → 复制原文，注意空格换行

## 大输出处理

- <100 行：直接输出
- 100-500 行：用 `head -N` 或 `tail -N`
- >500 行：落盘再读 `command > /tmp/result.txt`

## Token 节省

- 不说废话："Great question!" "Let me..."
- 工具调用不叙述，直接执行
- 长内容发文件，不贴文字
- Output 比 Input 贵 5 倍，精简回复 ROI 最高

## Skill 设计

- **Progressive Disclosure**：详细内容放 `references/`，按需加载
- SKILL.md 保持精简（<100 行）
- 用 channel ID 不用名称（名称可能改）

---

*最后更新: 2026-02-07*
