# Learnings

Corrections, insights, and knowledge gaps captured during development.

**Categories**: correction | insight | knowledge_gap | best_practice
**Areas**: frontend | backend | infra | tests | docs | config
**Statuses**: pending | in_progress | resolved | wont_fix | promoted | promoted_to_skill

---

## [LRN-20260207-001] correction

**Logged**: 2026-02-07T11:44:00+08:00
**Priority**: high
**Status**: resolved
**Area**: config

### Summary
不应该在工具调用时说 "There is a tool use."

### Details
在调用工具时，我会说 "There is a tool use." 作为过渡语。这是不必要的，违反了 AGENTS.md 中的 Tool Call Style 指导：
- 常规、低风险的工具调用应该直接执行，不需要叙述
- 只在多步骤工作、复杂问题、敏感操作时才需要叙述

### Suggested Action
直接调用工具，不要说 "There is a tool use."

### Resolution
- **Resolved**: 2026-02-07T11:44:00+08:00
- **Notes**: 已理解并修正行为。工具调用应该静默执行，除非需要解释。

### Metadata
- Source: user_feedback (via @haodaer 总结)
- Tags: tool-calling, style, narration

---

