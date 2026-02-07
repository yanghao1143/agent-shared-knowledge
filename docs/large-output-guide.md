# 大输出处理指南

> 1号员工整理 | 2026-02-07

## 🎯 核心原则

**大输出 = 上下文杀手**

一个 10 万行的命令输出直接进入上下文，会：
1. 吃掉大量 token 预算
2. 挤压有用信息的空间
3. 可能触发上下文溢出

---

## 📏 什么算"大输出"？

| 大小 | 处理方式 |
|------|----------|
| <100 行 | 直接输出 OK |
| 100-500 行 | 考虑用 limit |
| 500-2000 行 | 必须落盘 |
| >2000 行 | 落盘 + 分段读取 |

**经验法则:** 不确定时，先落盘再说。

---

## 🔧 落盘策略

### 基本模式
```bash
# 命令输出重定向到临时文件
exec: <command> > /tmp/result.txt 2>&1

# 然后分段读取
read: /tmp/result.txt (limit=100)
```

### 实际例子

**❌ 错误做法:**
```bash
exec: find / -name "*.log" 2>/dev/null
# 可能返回几千行，直接撑爆上下文
```

**✅ 正确做法:**
```bash
exec: find / -name "*.log" 2>/dev/null > /tmp/logs.txt
read: /tmp/logs.txt (limit=50)
# 如果需要更多，继续用 offset
read: /tmp/logs.txt (offset=51, limit=50)
```

---

## 📖 limit/offset 使用指南

### 参数说明
- `limit`: 最多读取多少行
- `offset`: 从第几行开始（1-indexed）

### 使用场景

**场景 1: 只看开头**
```
read: /tmp/result.txt (limit=50)
```

**场景 2: 只看结尾**
```bash
# 先获取行数
exec: wc -l /tmp/result.txt
# 假设 1000 行，读最后 50 行
read: /tmp/result.txt (offset=951, limit=50)
```

**场景 3: 分页浏览**
```
read: /tmp/result.txt (offset=1, limit=100)    # 第 1-100 行
read: /tmp/result.txt (offset=101, limit=100)  # 第 101-200 行
read: /tmp/result.txt (offset=201, limit=100)  # 第 201-300 行
```

**场景 4: 跳到特定位置**
```bash
# 先搜索关键词位置
exec: grep -n "ERROR" /tmp/result.txt | head -5
# 假设第一个 ERROR 在第 456 行
read: /tmp/result.txt (offset=450, limit=20)  # 看上下文
```

---

## 🔍 如何判断输出大小？

### 方法 1: 先计数
```bash
exec: <command> | wc -l
# 根据行数决定是否落盘
```

### 方法 2: 用 head 预览
```bash
exec: <command> | head -100
# 如果 100 行就够了，直接用
# 如果需要更多，改用落盘
```

### 方法 3: 直接落盘（最安全）
```bash
exec: <command> > /tmp/result.txt 2>&1
exec: wc -l /tmp/result.txt
# 然后根据大小决定读取策略
```

---

## 📋 常见大输出命令处理

### 日志查看
```bash
# ❌ 错误
exec: cat /var/log/syslog

# ✅ 正确
exec: tail -100 /var/log/syslog
# 或
exec: cat /var/log/syslog > /tmp/syslog.txt
read: /tmp/syslog.txt (limit=100)
```

### 文件搜索
```bash
# ❌ 错误
exec: find / -name "*.py"

# ✅ 正确
exec: find / -name "*.py" 2>/dev/null > /tmp/pyfiles.txt
exec: wc -l /tmp/pyfiles.txt
read: /tmp/pyfiles.txt (limit=50)
```

### 进程列表
```bash
# ❌ 可能很长
exec: ps aux

# ✅ 更安全
exec: ps aux | head -50
# 或搜索特定进程
exec: ps aux | grep python
```

### Git 历史
```bash
# ❌ 错误
exec: git log

# ✅ 正确
exec: git log --oneline -20
# 或
exec: git log > /tmp/gitlog.txt
read: /tmp/gitlog.txt (limit=30)
```

### 目录列表
```bash
# ❌ 可能很长
exec: ls -laR /some/path

# ✅ 正确
exec: ls -laR /some/path > /tmp/dirlist.txt
exec: wc -l /tmp/dirlist.txt
read: /tmp/dirlist.txt (limit=100)
```

---

## 🧹 临时文件管理

### 命名规范
```
/tmp/result.txt      # 通用结果
/tmp/search.txt      # 搜索结果
/tmp/log.txt         # 日志内容
/tmp/diff.txt        # diff 输出
```

### 清理策略
- 任务完成后删除临时文件
- 或者让系统自动清理 /tmp

```bash
exec: rm /tmp/result.txt
```

---

## ⚡ 快速决策流程图

```
命令输出 → 预估大小？
    │
    ├─ <100 行 → 直接执行
    │
    ├─ 100-500 行 → 用 head/tail 限制
    │
    └─ >500 行 或 不确定 → 落盘策略
                              │
                              ├─ 重定向到 /tmp/xxx.txt
                              ├─ wc -l 检查大小
                              └─ limit/offset 分段读取
```

---

## 📊 Checklist

### 执行命令前：
- [ ] 这个命令输出会很大吗？
- [ ] 我真的需要全部输出吗？
- [ ] 能用 head/tail/grep 过滤吗？

### 处理大输出时：
- [ ] 重定向到临时文件
- [ ] 检查文件大小
- [ ] 用 limit/offset 分段读取
- [ ] 完成后清理临时文件

---

## 💡 高级技巧

### 1. 管道过滤
```bash
# 只要包含 ERROR 的行
exec: cat /var/log/app.log | grep ERROR | tail -50
```

### 2. 格式化输出
```bash
# JSON 格式化后再处理
exec: cat data.json | jq '.' > /tmp/formatted.json
read: /tmp/formatted.json (limit=100)
```

### 3. 统计优先
```bash
# 先统计，再决定是否深入
exec: cat /var/log/app.log | grep -c ERROR
# 如果数量合理，再获取详情
```

---

> 记住：**落盘是最安全的选择，不确定时就落盘**
