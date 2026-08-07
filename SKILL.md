---
name: dws-skill
description: >
  钉钉全产品能力(AI表格/AI搜问/日历/通讯录/群聊与机器人/待办/审批/考勤/日志/
  DING消息/钉钉文档/钉钉云盘/原生Markdown文件/AI听记/邮箱/在线电子表格/知识库等)。
  当用户需要操作表格数据、管理日程会议、模糊找人、查询通讯录、管理群聊、机器人发消息、
  创建待办、提交审批、查看考勤、提交日报周报、读写钉钉文档、上传下载云盘文件、
  读取或修改原生.md文件、查询听记纪要、收发邮件、读写在线电子表格(axls)、
  管理钉钉知识库时使用。
metadata:
  openclaw:
    requires:
      anyBins:
        - "{baseDir}/dws"
    emoji: "📌"
---

# 钉钉全产品 Skill

通过 `{baseDir}/dws` 命令管理钉钉产品能力。本 skill 包**自带 dws 二进制**，无需联网下载任何组件。

---

## 环境准备（首次使用执行一次）

确保二进制有执行权限：

```bash
chmod +x {baseDir}/dws
```

验证可用：

```bash
{baseDir}/dws version
```

`{baseDir}/dws` 是纯静态编译的 Go 二进制，无运行时依赖（不需要 Go、Python、Node.js），直接在沙箱中运行。

Python 辅助脚本位于 `{baseDir}/scripts/`，仅在明确覆盖的复合任务时按需调用（批量导入导出、日程安排等），核心功能不需要 Python。

---

## 登录（仅支持设备流）

本 skill 环境没有本地浏览器和 GUI 密钥链，只支持设备流登录。

### 首次登录

```bash
{baseDir}/dws auth login --device --no-browser --format json
```

终端会输出:

```
┌──────────────────────────────────────────┐
│                                          │
│   请打开以下链接并输入验证码:              │
│                                          │
│   https://login.dingtalk.com/device       │
│                                          │
│   验证码: XXXX-XXXX                       │
│                                          │
│   有效期: 15 分钟                         │
│                                          │
└──────────────────────────────────────────┘
```

**将验证码和链接发送给用户**，用户在任意设备的浏览器中打开链接，输入验证码，钉钉 App 扫码确认授权。

CLI 会自动轮询等待授权完成（最长 10 分钟），完成后凭据自动持久化。

### ClientID 配置

如果尚未配置 ClientID，CLI 会自动从 MCP 网关获取（推荐）。也可以手动指定：

```bash
export DWS_CLIENT_ID="dingxxxxxxxxxxxxx"
```

### 验证登录状态

```bash
{baseDir}/dws profile list --format json
```

> **命令可用性以当前随包 dws 二进制为准**。如果 `{baseDir}/dws <cmd> --help` 不存在，说明当前版本未暴露该命令。实际调用前可用 `{baseDir}/dws <cmd> --help` 或 `--dry-run` 验证。

---

## 严格禁止 (NEVER DO)

- 不要使用 dws 命令以外的方式操作（禁止 curl、HTTP API、浏览器）
- 不要编造 UUID、ID 等标识符，必须从命令返回中提取
- 不要猜测字段名/参数值，操作前必须先查询确认

## 严格要求 (MUST DO)

- 所有命令必须加 `--format json` 以获取可解析输出
- 危险操作必须先向用户确认，用户同意后才加 `--yes` 执行
- 单次批量操作不超过 30 条记录
- 所有命令必须**严格遵循**对应产品参考文档里面规定的参数格式
- **脚本只用于明确覆盖的复合任务**：[{baseDir}/scripts/]({baseDir}/scripts/) 下的脚本封装了批量导入导出、会议日程安排、待办批处理等流程。当公开 `+` Shortcut 已提供目标唯一解析时，优先 Shortcut

## Shortcut 与原子命令的使用原则

`shortcut` 是对常用操作的高层封装，优先承担用户意图；产品参考文档负责判断意图和风险，CLI help 负责声明当前版本真正可调用的命令。

- 先按产品参考、意图表和 recipe 路由。用户意图可由可见 Shortcut 满足时，优先使用 `{baseDir}/dws <service> +<verb> ... --format json`
- 用 `{baseDir}/dws schema --cli-path "<service> +<verb>" --compact --format json` 读取参数、约束和安全确认语义
- 组装参数前用 `{baseDir}/dws <service> +<verb> --help` 核对当前接受的 flags
- shortcut catalog 中 `confirmation=user_required` 时，必须先获得用户确认，确认后才加 `--yes`
- 如果 shortcut 不在 help 中，改用产品参考里的原子命令或脚本；不要猜测未展示的命令
- shortcut 失败时先加 `--verbose` 复查

### Shortcut 总览

下面只统计当前公开 catalog 中的 shortcut，不展开完整明细。已知意图应先按产品 Skill、意图表或任务 reference 选择唯一命令；命令已选中时直接执行。

| 服务 | shortcut 数 |
|---|---:|
| `aitable` | 29 |
| `attendance` | 19 |
| `calendar` | 20 |
| `chat` | 98 |
| `contact` | 14 |
| `devapp` | 19 |
| `ding` | 4 |
| `doc` | 41 |
| `drive` | 7 |
| `mail` | 10 |
| `minutes` | 6 |
| `oa` | 7 |
| `report` | 2 |
| `sheet` | 2 |
| `todo` | 11 |
| `wiki` | 1 |

仅当现有路由和 reference 都无法定位低频能力时，才用 `{baseDir}/dws shortcut list --service <service> --format json` 做最后回退。

---

## 多组织 / 多账号

- `{baseDir}/dws profile list --format json` 默认返回全部账号。使用稳定的 `profile=corpId:userId` 标识
- 输入支持 `corpId:userId`、`corpId:userName`、`corpName:userId`、`corpName:userName`
- 不传 `--profile` 使用当前默认账号
- 多账号组织没有默认账号时必须让用户指定；禁止选择第一项或最近登录的账号
- 跨组织读/搜：按 `corpId` 去重
- 写/发/删/撤操作前先确认目标组织和账号

---

## 产品总览

| 产品 | 用途 | 参考文件 |
|---|---|---|
| `aisearch` | AI搜问（通用找人首选）：按姓名/部门/职位/职责/上级/下级/手机号/工号找人，"谁负责XX"统一走本产品 | [{baseDir}/references/products/aisearch.md]({baseDir}/references/products/aisearch.md) |
| `aitable` | AI表格：Base/数据表/字段/记录/视图/附件/图表/仪表盘/导入导出/模板搜索 | [{baseDir}/references/products/aitable.md]({baseDir}/references/products/aitable.md) |
| `attendance` | 考勤：打卡结果/打卡流水/考勤组/考勤规则/假期类型/假期余额 | [{baseDir}/references/products/attendance.md]({baseDir}/references/products/attendance.md) |
| `calendar` | 日历：日历列表/日程/参与者/附件/响应/会议室/闲忙查询/时间建议 | [{baseDir}/references/products/calendar.md]({baseDir}/references/products/calendar.md) |
| `chat` | 群聊与机器人：搜索群/建群/群成员管理/消息发送/拉取消息/@我/特别关注/机器人群发/单聊/撤回/Webhook | [{baseDir}/references/products/chat.md]({baseDir}/references/products/chat.md) |
| `contact` | 通讯录：用户查询/部门/角色/花名册/离职员工/特别关注 | [{baseDir}/references/products/contact.md]({baseDir}/references/products/contact.md) |
| `devdoc` | 开放平台文档：搜索开发文档 | [{baseDir}/references/products/devdoc.md]({baseDir}/references/products/devdoc.md) |
| `ding` | DING消息：发送/撤回（应用内/短信/电话） | [{baseDir}/references/products/ding.md]({baseDir}/references/products/ding.md) |
| `doc` | 钉钉文档：搜索/浏览/读写/块级编辑/评论/文件创建/复制/移动/删除/导出docx/权限管理 | [{baseDir}/references/products/doc.md]({baseDir}/references/products/doc.md) |
| `drive` | 钉钉云盘：文件列表/元数据/文件夹/上传/下载 | [{baseDir}/references/products/drive.md]({baseDir}/references/products/drive.md) |
| `hrbrain` | 组织大脑：人才池/员工档案/职业历程/绩效/结构化高级人才搜索 | [{baseDir}/references/products/hrbrain.md]({baseDir}/references/products/hrbrain.md) |
| `markdown` | 原生Markdown文件：读取/创建/覆盖/局部替换 | [{baseDir}/references/products/markdown.md]({baseDir}/references/products/markdown.md) |
| `minutes` | AI听记：听记列表/摘要/关键词/转写/待办/思维导图/发言人 | [{baseDir}/references/products/minutes.md]({baseDir}/references/products/minutes.md) |
| `oa` | OA审批：待处理/详情/同意/拒绝/撤销/记录/已发起/任务/转交/评论/抄送 | [{baseDir}/references/products/oa.md]({baseDir}/references/products/oa.md) |
| `report` | 日志：按模版创建/收件箱/已发送/模版查看/详情/已读统计 | [{baseDir}/references/products/report.md]({baseDir}/references/products/report.md) |
| `mail` | 邮箱：邮箱地址查询/邮件搜索(KQL)/邮件详情/发送邮件 | [{baseDir}/references/products/mail.md]({baseDir}/references/products/mail.md) |
| `sheet` | 在线电子表格(axls)：工作表CRUD/区域读写/批量写入/行列操作/筛选/导出xlsx | [{baseDir}/references/products/sheet.md]({baseDir}/references/products/sheet.md) |
| `todo` | 待办：创建(含优先级/截止时间/循环)/查询/修改/标记完成/删除 | [{baseDir}/references/products/todo.md]({baseDir}/references/products/todo.md) |
| `wiki` | 知识库：空间创建/详情/列表/搜索 + 成员管理 | [{baseDir}/references/products/wiki.md]({baseDir}/references/products/wiki.md) |
| `whiteboard` | 文档内嵌白板：读取OpenNodes/追加节点/整页重建 | [{baseDir}/references/products/whiteboard.md]({baseDir}/references/products/whiteboard.md) |

---

## 意图判断决策树

用户提到"表格/多维表/AI表格/记录/数据/视图/图表/仪表盘" → `aitable`
用户提到"日程/日历/会议室/约会/时间建议" → `calendar`
用户提到"群聊/建群/群成员/发消息/发图片/发文件/机器人/Webhook/通知" → `chat`
用户提到"通讯录/同事/部门/组织架构/找人/谁负责XX" → `aisearch`（通用找人）或 `contact`（通讯录档案）
用户提到"审批/请假/报销/出差/加班/同意/拒绝" → `oa`
用户提到"考勤/打卡/排班/假期" → `attendance`
用户提到"日志/日报/周报" → `report`
用户提到"待办/TODO/任务提醒" → `todo`
用户提到"文档/云文档/知识库/读写文档" → `doc`
用户提到"云盘/文件上传下载" → `drive`
用户提到"邮箱/邮件/发邮件/收邮件" → `mail`
用户提到"听记/会议纪要/转写/摘要" → `minutes`
用户提到"在线电子表格/axls/单元格" → `sheet`
用户提到"DING/紧急消息" → `ding`
用户提到"知识库/wiki/团队空间" → `wiki`
用户提到"白板/OpenNodes/画布" → `whiteboard`
用户提到"人才池/职业历程/绩效" → `hrbrain`

关键区分: aitable(数据表格) vs todo(待办任务)
关键区分: report(钉钉日志/日报周报) vs todo(待办任务)
关键区分: doc(在线富文本文档) vs markdown(原生.md纯文本文件) vs drive(通用文件存储)
关键区分: aisearch(通用语义找人) vs contact(基础通讯录档案) vs hrbrain(人才池/绩效)
关键区分: oa tasks(审批taskId) vs oa list-pending(收件箱processInstanceId)

> 更多易混淆场景见 [{baseDir}/references/intent-guide.md]({baseDir}/references/intent-guide.md)

---

## 危险操作确认

以下操作为不可逆或高影响操作，执行前**必须先向用户展示操作摘要并获得明确同意**：

| 产品 | 命令 | 说明 |
|---|---|---|
| `aitable` | `base delete` / `table delete` / `field delete` / `record delete` | 删除表格/字段/记录 |
| `calendar` | `event delete` / `participant delete` | 删除日程/移除参与者 |
| `chat` | `group members remove` / `message recall-by-bot` | 移除群成员/撤回消息 |
| `doc` | `delete` / `block delete` | 删除文档/块 |
| `oa` | `approval revoke` / `approval reject` | 撤销/拒绝审批 |
| `todo` | `task delete` | 删除待办 |

### 确认流程

```
Step 1 → 展示操作摘要（操作类型 + 目标对象 + 影响范围）
Step 2 → 用户明确回复确认（如 "确认" / "好的"）
Step 3 → 加 --yes 执行命令
```

非交互环境下写命令不带 `--yes` 时 CLI 直接失败。输出中 `error.reason == "confirmation_required"` 时必须：
1. 把命令和风险展示给用户
2. 用户同意后追加 `--yes` 重试
3. 用户拒绝 → 终止
4. 想先预览: `--dry-run`（不触发确认门禁）

**禁止**：未经用户同意自动追加 `--yes` 静默重试。

---

## 核心流程

0. **URL 预检**：输入含 `alidocs.dingtalk.com` URL 时，先读 [{baseDir}/references/url-patterns.md]({baseDir}/references/url-patterns.md) 识别 URL 类型
1. **意图分类**：判断用户指令的核心动词/动作
2. **歧义处理**：模糊或含多个产品关键字时，主动追问澄清
3. **精准产品映射**：意图清晰后，参考产品总览和决策树选择产品
4. **按任务最小化读取**：已知高频意图直接使用已给出的唯一命令，不预加载完整产品参考

## 命令发现（Schema 渐进查询）

```bash
# 第 1 层：产品概览
{baseDir}/dws schema

# 第 2 层：产品级
{baseDir}/dws schema calendar --compact

# 第 3 层：分组级
{baseDir}/dws schema "calendar event" --compact

# 第 4 层：Agent leaf（参数契约）
{baseDir}/dws schema "calendar event create" --compact
```

**`--compact` Agent 模式**保留: `cli_path`、`canonical_path`、`description`、`effect`、`risk`、`confirmation`、`parameters`（含 `type`/`required`/`description`/`default`/`enum`）、`constraints`、`examples`。

### Schema 字段速查

```jsonc
{
  "cli_path": "calendar event create",
  "description": "创建新的日程...",
  "effect": "write",                    // read | write | destructive
  "risk": "medium",                     // low | medium | high
  "confirmation": "not_required",       // not_required | user_required
  "availability": "available",          // available | unavailable
  "parameters": {
    "title": { "type": "string", "required": true }
  },
  "constraints": {},
  "examples": ["{baseDir}/dws calendar event create --title ..."]
}
```

- `confirmation=user_required` → 必须先确认再加 `--yes`
- `availability=unavailable` → 不执行该工具，说明原因
- `parameters.<flag>.required=true` → Agent 应提供该参数

---

## 错误处理

1. 先读取 JSON 错误的 `retryable`、`hint` 和 `actions`；只有 `retryable=true` 时才做一次有界重试
2. 仍然失败，报告完整错误信息给用户
3. 认证失败时，引导执行 `{baseDir}/dws auth login --device --no-browser --format json`
4. 各产品高频错误见 [{baseDir}/references/error-codes.md]({baseDir}/references/error-codes.md)
5. 遇到 [{baseDir}/references/capability-limits.md]({baseDir}/references/capability-limits.md) 中列出的「已知不支持操作」时，直接告知用户不支持

---

## 详细参考 (按需读取)

- [{baseDir}/references/products/]({baseDir}/references/products/) — 各产品命令详细参考
- [{baseDir}/references/intent-guide.md]({baseDir}/references/intent-guide.md) — 意图路由指南
- [{baseDir}/references/url-patterns.md]({baseDir}/references/url-patterns.md) — URL 格式规范
- [{baseDir}/references/global-reference.md]({baseDir}/references/global-reference.md) — 全局标志、认证、输出格式
- [{baseDir}/references/field-rules.md]({baseDir}/references/field-rules.md) — AI表格字段类型规则
- [{baseDir}/references/error-codes.md]({baseDir}/references/error-codes.md) — 错误码 + 调试流程
- [{baseDir}/scripts/]({baseDir}/scripts/) — 批量/复合操作脚本
- [{baseDir}/references/capability-limits.md]({baseDir}/references/capability-limits.md) — 已知能力限制
- [{baseDir}/references/best_practices/]({baseDir}/references/best_practices/) — 全场景 recipe 行动指南
  - [01-messaging.md]({baseDir}/references/best_practices/01-messaging.md) — 消息沟通
  - [02-task.md]({baseDir}/references/best_practices/02-task.md) — 任务管理
  - [03-meeting.md]({baseDir}/references/best_practices/03-meeting.md) — 会议日程
  - [04-document.md]({baseDir}/references/best_practices/04-document.md) — 文档场景
  - [05-reporting.md]({baseDir}/references/best_practices/05-reporting.md) — 工作汇报
  - [06-data-analytics.md]({baseDir}/references/best_practices/06-data-analytics.md) — 数据分析
  - [07-minutes.md]({baseDir}/references/best_practices/07-minutes.md) — 听记与会后
  - [08-directory.md]({baseDir}/references/best_practices/08-directory.md) — 通讯录
  - [09-mail.md]({baseDir}/references/best_practices/09-mail.md) — 邮件
  - [10-minutes-speaker-match.md]({baseDir}/references/best_practices/10-minutes-speaker-match.md) — 听记发言人匹配
  - [11-minutes-speaker-correct.md]({baseDir}/references/best_practices/11-minutes-speaker-correct.md) — 听记发言人校正
  - [lite-recipes.md]({baseDir}/references/best_practices/lite-recipes.md) — Lite Recipe 速查
  - [_common/conventions.md]({baseDir}/references/best_practices/_common/conventions.md) — 通用规范
  - [_common/recipe-conventions.md]({baseDir}/references/best_practices/_common/recipe-conventions.md) — recipe 元规范
