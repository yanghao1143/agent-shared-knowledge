#!/bin/bash
# session-compress.sh - 会话压缩和摘要管理（v2 - 支持频道分离）
# 用法:
#   ./session-compress.sh compress <session> <summary> [context_pct] [tokens]
#   ./session-compress.sh get <session>
#   ./session-compress.sh get-all <session>  # 获取 shared + channel 摘要
#   ./session-compress.sh history <session>
#   ./session-compress.sh set-shared <summary>  # 设置共享知识
#   ./session-compress.sh get-shared            # 获取共享知识
#
# session 格式:
#   main                    → 私聊
#   channel:<id>            → 特定频道
#   mattermost:<channel_id> → Mattermost 频道（别名）

set -e

ACTION="${1:-help}"
SESSION="${2:-main}"
SUMMARY="$3"
CONTEXT_PCT="${4:-0}"
TOKENS="${5:-0}"

# 解析 session 为 Redis key
parse_session_key() {
    local session="$1"
    case "$session" in
        main)
            echo "openclaw:session:main:summary"
            ;;
        channel:*)
            echo "openclaw:session:${session}:summary"
            ;;
        mattermost:*)
            # mattermost:xxx → channel:xxx
            local id="${session#mattermost:}"
            echo "openclaw:session:channel:${id}:summary"
            ;;
        *)
            echo "openclaw:session:${session}:summary"
            ;;
    esac
}

REDIS_KEY=$(parse_session_key "$SESSION")
REDIS_SHARED_KEY="openclaw:session:shared:summary"
PG_TABLE="session_summaries"

# 颜色
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log() { echo -e "${GREEN}[compress]${NC} $1"; }
warn() { echo -e "${YELLOW}[compress]${NC} $1"; }

case "$ACTION" in
    compress)
        if [ -z "$SUMMARY" ]; then
            echo "用法: $0 compress <session> <summary> [context_pct] [tokens]"
            exit 1
        fi
        
        TIMESTAMP=$(date -Iseconds)
        
        # 存储到 Redis（热数据，7天过期）
        if command -v redis-cli &> /dev/null; then
            redis-cli SET "$REDIS_KEY" "$SUMMARY" EX 604800 > /dev/null 2>&1 || true
            log "已存储到 Redis: $REDIS_KEY"
        fi
        
        # 存储到 PostgreSQL（持久化）
        if command -v psql &> /dev/null; then
            psql -h localhost -U openclaw -d openclaw -c "
                INSERT INTO $PG_TABLE (session_id, summary, context_pct, tokens, created_at)
                VALUES ('$SESSION', '$SUMMARY', $CONTEXT_PCT, $TOKENS, '$TIMESTAMP')
                ON CONFLICT DO NOTHING;
            " > /dev/null 2>&1 || warn "PostgreSQL 存储失败（表可能不存在）"
            log "已存储到 PostgreSQL"
        fi
        
        # 写入 MEMORY.md 开头
        WORKSPACE_DIR="${OPENCLAW_DIR:-$HOME/.openclaw}/workspace"
        MEMORY_FILE="$WORKSPACE_DIR/MEMORY.md"
        
        if [ -f "$MEMORY_FILE" ]; then
            SUMMARY_BLOCK="<!-- LAST_SESSION_START -->
## 🔄 上次会话摘要

**更新时间**: $(date '+%Y-%m-%d %H:%M:%S')
**会话**: $SESSION
**上下文**: ${CONTEXT_PCT}%

$SUMMARY

<!-- LAST_SESSION_END -->

"
            if grep -q "<!-- LAST_SESSION_START -->" "$MEMORY_FILE"; then
                python3 -c "
import re
with open('$MEMORY_FILE', 'r') as f:
    content = f.read()
pattern = r'<!-- LAST_SESSION_START -->.*?<!-- LAST_SESSION_END -->\n*'
new_block = '''$SUMMARY_BLOCK'''
content = re.sub(pattern, new_block, content, flags=re.DOTALL)
with open('$MEMORY_FILE', 'w') as f:
    f.write(content)
"
                log "已更新 MEMORY.md 中的摘要块"
            else
                TEMP_FILE=$(mktemp)
                echo "$SUMMARY_BLOCK" > "$TEMP_FILE"
                cat "$MEMORY_FILE" >> "$TEMP_FILE"
                mv "$TEMP_FILE" "$MEMORY_FILE"
                log "已在 MEMORY.md 开头插入摘要块"
            fi
        else
            warn "MEMORY.md 不存在: $MEMORY_FILE"
        fi
        
        log "✅ 压缩完成: $SESSION"
        ;;
        
    get)
        # 从 Redis 获取指定 session 摘要
        if command -v redis-cli &> /dev/null; then
            SUMMARY=$(redis-cli GET "$REDIS_KEY" 2>/dev/null || echo "")
            if [ -n "$SUMMARY" ]; then
                echo "$SUMMARY"
                exit 0
            fi
        fi
        
        # 从 PostgreSQL 获取
        if command -v psql &> /dev/null; then
            SUMMARY=$(psql -h localhost -U openclaw -d openclaw -t -c "
                SELECT summary FROM $PG_TABLE 
                WHERE session_id = '$SESSION' 
                ORDER BY created_at DESC LIMIT 1;
            " 2>/dev/null | xargs || echo "")
            if [ -n "$SUMMARY" ]; then
                echo "$SUMMARY"
                exit 0
            fi
        fi
        
        echo "无上次摘要"
        ;;
    
    get-all)
        # 获取 shared + channel 摘要（完整恢复）
        echo "=== 共享知识 ==="
        if command -v redis-cli &> /dev/null; then
            SHARED=$(redis-cli GET "$REDIS_SHARED_KEY" 2>/dev/null || echo "")
            if [ -n "$SHARED" ]; then
                echo "$SHARED"
            else
                echo "(无共享知识)"
            fi
        fi
        
        echo ""
        echo "=== 频道上下文: $SESSION ==="
        if command -v redis-cli &> /dev/null; then
            CHANNEL=$(redis-cli GET "$REDIS_KEY" 2>/dev/null || echo "")
            if [ -n "$CHANNEL" ]; then
                echo "$CHANNEL"
            else
                echo "(无频道上下文)"
            fi
        fi
        ;;
    
    set-shared)
        # 设置共享知识
        if [ -z "$SESSION" ] || [ "$SESSION" = "main" ]; then
            echo "用法: $0 set-shared <summary>"
            exit 1
        fi
        SHARED_SUMMARY="$SESSION"  # 在这种情况下 $SESSION 实际上是 summary
        
        if command -v redis-cli &> /dev/null; then
            redis-cli SET "$REDIS_SHARED_KEY" "$SHARED_SUMMARY" EX 2592000 > /dev/null 2>&1 || true
            log "已存储共享知识到 Redis (30天过期)"
        fi
        ;;
    
    get-shared)
        # 获取共享知识
        if command -v redis-cli &> /dev/null; then
            SHARED=$(redis-cli GET "$REDIS_SHARED_KEY" 2>/dev/null || echo "")
            if [ -n "$SHARED" ]; then
                echo "$SHARED"
                exit 0
            fi
        fi
        echo "无共享知识"
        ;;
        
    history)
        if command -v psql &> /dev/null; then
            psql -h localhost -U openclaw -d openclaw -c "
                SELECT created_at, context_pct, tokens, LEFT(summary, 50) as summary_preview
                FROM $PG_TABLE 
                WHERE session_id = '$SESSION' 
                ORDER BY created_at DESC LIMIT 10;
            " 2>/dev/null || warn "无法获取历史"
        else
            warn "PostgreSQL 不可用"
        fi
        ;;
        
    help|*)
        echo "用法:"
        echo "  $0 compress <session> <summary> [context_pct] [tokens]  # 压缩并存储摘要"
        echo "  $0 get <session>                                        # 获取指定 session 摘要"
        echo "  $0 get-all <session>                                    # 获取 shared + channel 摘要"
        echo "  $0 set-shared <summary>                                 # 设置共享知识"
        echo "  $0 get-shared                                           # 获取共享知识"
        echo "  $0 history <session>                                    # 查看压缩历史"
        echo ""
        echo "session 格式:"
        echo "  main                    → 私聊"
        echo "  channel:<id>            → 特定频道"
        echo "  mattermost:<channel_id> → Mattermost 频道"
        echo ""
        echo "示例:"
        echo "  $0 compress main '今天讨论了A/B测试' 65 50000"
        echo "  $0 compress channel:5spon67i '学习任务完成' 40 30000"
        echo "  $0 get-all channel:5spon67i"
        echo "  $0 set-shared '工具参数：file_path 不是 path'"
        ;;
esac
