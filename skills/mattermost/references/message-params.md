# Message Tool Parameters (Mattermost)

## action: send

| Parameter | Required | Description |
|-----------|----------|-------------|
| `action` | ✅ | `"send"` |
| `channel` | ✅ | `"mattermost"` |
| `message` | ❌ | Text content |
| `filePath` | ❌ | Local file to upload |
| `target` | ❌ | Channel/user ID (auto if in chat) |
| `replyTo` | ❌ | Message ID to reply to |
| `silent` | ❌ | Suppress notifications |

**Note:** Either `message` or `filePath` required.

## action: broadcast

| Parameter | Required | Description |
|-----------|----------|-------------|
| `action` | ✅ | `"broadcast"` |
| `channel` | ✅ | `"mattermost"` |
| `message` | ✅ | Text content |
| `targets` | ✅ | Array of channel/user IDs |

## Target Resolution

```
channel_id          → channel:channel_id
channel:id          → channel:id
user:id             → DM to user
@username           → DM (resolved via API)
```

## File Types

Mattermost accepts most file types:
- Documents: `.md`, `.txt`, `.pdf`, `.docx`
- Code: `.py`, `.js`, `.ts`, `.json`, `.yaml`
- Images: `.png`, `.jpg`, `.gif`
- Archives: `.zip`, `.tar.gz`

## Response

```json
{
  "channel": "mattermost",
  "to": "channel:abc123",
  "result": {
    "messageId": "msg_id",
    "channelId": "abc123"
  }
}
```

## Common Errors

| Error | Cause | Fix |
|-------|-------|-----|
| `target required` | No target specified | Add `target` param |
| `file not found` | Invalid `filePath` | Check file exists |
| `permission denied` | Bot not in channel | Add bot to channel |
