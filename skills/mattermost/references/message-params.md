# Message Tool Parameters (Mattermost)

## Core Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `action` | string | ✅ | `send` or `broadcast` |
| `channel` | string | ✅ | `mattermost` |
| `target` | string | ✅ | Channel ID, `user:<id>`, or `@username` |
| `message` | string | ⚠️ | Text content (optional if filePath) |
| `filePath` | string | ❌ | Local file path to send |

## File Sending

```
message action=send channel=mattermost target=<id> filePath=/path/to/file.md
```

- Supports any file type
- Caption via `message` parameter (optional)
- File is uploaded as attachment

## Target Resolution

1. **Bare ID** → treated as channel
2. **`channel:<id>`** → explicit channel
3. **`user:<id>`** → DM to user by ID
4. **`@username`** → DM resolved via API

## Broadcast

Send to multiple targets:
```
message action=broadcast channel=mattermost targets=["id1","id2"] message="Hello all"
```

## Reply to Message

```
message action=send channel=mattermost target=<id> message="Reply" replyTo=<messageId>
```

## Reactions

```
message action=send channel=mattermost target=<id> messageId=<id> emoji=👍
```

## Notes

- Mattermost supports Markdown tables (Discord/WhatsApp don't)
- No inline buttons unless `mattermost.capabilities.inlineButtons` is set
- Rate limits apply per bot token
