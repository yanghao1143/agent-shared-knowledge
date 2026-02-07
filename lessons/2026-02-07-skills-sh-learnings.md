# 2026-02-07 skills.sh 学习总结

## 来源

https://skills.sh - The Open Agent Skills Ecosystem

主要学习了 **obra/superpowers** 系列

---

## 1. systematic-debugging（系统化调试）

### 铁律

**没有找到根因之前，不能尝试修复**

### 四阶段流程

1. **根因调查** - 读错误、复现、查最近改动、收集证据
2. **模式分析** - 找到能工作的类似代码，对比差异
3. **假设测试** - 形成单一假设，最小改动测试
4. **实现修复** - 先写失败测试，再修复，验证

### 红旗信号（立即停止）

- "先快速修一下，之后再调查"
- "试试改 X 看看行不行"
- "我不完全理解但这可能有用"
- **已经尝试 3+ 次修复还没成功** → 质疑架构，不是继续修

### 真实数据

- 系统化方法：15-30 分钟修好
- 随机尝试：2-3 小时瞎折腾
- 首次修复成功率：95% vs 40%

---

## 2. dispatching-parallel-agents（并行 agent 调度）

### 核心原则

多个独立问题 → 每个问题派一个 agent → 并行处理

### 适用场景

- 3+ 个测试文件失败，原因不同
- 多个子系统独立出问题
- 问题之间没有共享状态

### 不适用

- 问题相关（修一个可能修好其他）
- 需要理解完整系统状态
- agent 会互相干扰（编辑同一文件）

### 关键点

- 每个 agent 任务要**聚焦**（一个问题域）
- 提供**完整上下文**（错误信息、测试名）
- 明确**约束**（不要改其他代码）
- 指定**输出格式**（返回摘要）

---

## 3. verification-before-completion（完成前验证）

### 铁律

**没有新鲜的验证证据，不能声称完成**

### Gate Function

```
BEFORE claiming any status:
1. IDENTIFY: What command proves this claim?
2. RUN: Execute the FULL command (fresh, complete)
3. READ: Full output, check exit code
4. VERIFY: Does output confirm the claim?
5. ONLY THEN: Make the claim
```

### 常见失败

| 声称 | 需要 | 不够 |
|------|------|------|
| Tests pass | 测试输出: 0 failures | 之前的运行, "should pass" |
| Build succeeds | 构建命令: exit 0 | Linter passing |
| Bug fixed | 测试原始症状: passes | 代码改了, 假设修好了 |
| Agent completed | VCS diff 显示改动 | Agent 报告 "success" |

### 红旗词

- "should"、"probably"、"seems to"
- "Great!"、"Perfect!"、"Done!"（在验证前）
- 信任 agent 的成功报告

---

## 4. test-driven-development（TDD）

### RED-GREEN-REFACTOR 循环

1. **RED** - 写一个失败的测试
2. **GREEN** - 写最少的代码让测试通过
3. **REFACTOR** - 清理代码，保持测试通过

### 关键

- 先写测试，再写代码
- 测试必须先失败（证明测试有效）
- 每次只改一件事

---

## 和我们之前学的对比

| 来源 | 核心概念 | 关联 |
|------|----------|------|
| proactive-agent | WAL Protocol - 先写后回复 | 防止信息丢失 |
| proactive-agent | Verify Implementation, Not Intent | = systematic-debugging 的"找根因" |
| self-improving-agent | 记录错误和学习 | 支持 systematic-debugging 的"模式分析" |
| dispatching-parallel-agents | 独立问题并行处理 | 我们三个 agent 的协作模式 |
| verification-before-completion | 证据先于声称 | 防止虚假完成 |

---

## 团队学习分工

| Agent | 学习内容 |
|-------|----------|
| @oldking | systematic-debugging, dispatching-parallel-agents |
| @employee1 | systematic-debugging, TDD, dispatching-parallel-agents |
| @employee2 | 同上 + 和 proactive-agent 对比分析 |
| 好大儿 | verification-before-completion, systematic-debugging |

---

## 核心收获

1. **没找到根因不要动手修**
2. **没验证不要声称完成**
3. **独立问题才能并行处理**
4. **3+ 次失败 = 架构问题**
5. **Linter passed ≠ Build passed**
6. **Agent said success ≠ Actually success**
