---
name: xiaoyi-dws-cli
description: 管理钉钉核心能力：AI表格、AI搜问、日历、通讯录、群聊机器人、待办、审批、考勤、日志、DING消息、开放平台文档、钉钉文档、云盘、原生Markdown、AI听记、邮箱、在线表格、知识库。支持表格操作、日程会议、找人查责、通讯录管理、群聊管理、机器人消息、待办创建、审批提交、考勤查看、日志提交、文档读写、云盘上传下载、Markdown读写、听记纪要查询、邮件收发、知识库管理，以及IM和OA审批事件实时监听。
---

# 钉钉全产品 Skill

通过 `dws` 命令管理钉钉产品能力，所有命令通过bash工具执行，禁止使用exec工具。

## 使用前安装

本skill依赖静态编译的二进制文件——dws，**使用前必须先安装dws**，并验证。

### 安装 dws

```bash
curl -fsSL https://gitee.com/DingTalk-Real-AI/dingtalk-workspace-cli/raw/main/scripts/install.sh | DWS_NO_SKILLS=1 sh
```

### dws 环境验证
每次使用`dws`时，需要在当前会话中**声明dws二进制文件path路径**：
```bash
export PATH="/home/sandbox/.local/bin:$PATH"
```

声明后进行验证：
```bash
dws version
```
## 登录（仅支持设备流）

**只支持设备流登录方式**，禁止使用其他登录方式。

### 首次登录

```bash
dws auth login --device --no-browser --format json
```

终端会输出:

```
● Step 1: Requesting device authorization code...

  ╭────────────────────────────────────────────────────────────────────────────────────╮
  │  Please open the following link in your browser and enter the authorization code:  │
  │                                                                                    │
  │    link: https://login.dingtalk.com/oauth2/device/verify.htm                       │
  │    authorization code: BNVS-XKNG                                                   │
  │                                                                                    │
  │  Or open the following link:                                                       │
  │    https://login.dingtalk.com/oauth2/device/verify.htm?user_code=BNVS-XKNG         │
  │                                                                                    │
  │  Authorization code will expire in 900 seconds.                                    │
  ╰────────────────────────────────────────────────────────────────────────────────────╯

● Step 2: Waiting for user authorization...
```
不需要在沙箱环境内拉取浏览器进行登录，只要把带有验证码的链接发给用户即可！
禁止询问用户是否需要打开钉钉APP!所有操作在钉钉CLI内完成，禁止拉起钉钉APP！

**将带有验证码的链接以markdown格式发送给用户**。
（例如：https://login.dingtalk.com/oauth2/device/verify.htm?user_code=BNVS-XKNG）

CLI 会自动轮询等待授权完成（最长 10 分钟），完成后凭据自动持久化。

### 验证登录状态

```bash
dws profile list --format json
```
---

## 严格禁止 (NEVER DO)
- 不要使用 dws 命令以外的方式操作（禁止 curl、HTTP API、浏览器）
- 不要编造 UUID、ID 等标识符，必须从命令返回中提取
- 不要猜测字段名/参数值，操作前必须先查询确认

## 严格要求 (MUST DO)
- 所有命令必须加 `--format json` 以获取可解析输出
- 危险操作必须先向用户确认，用户同意后才加 `--yes` 执行
- 单次批量操作不超过 30 条记录
- 所有命令必须**严格遵循**对应产品参考文档里面规定的参数格式（如：如果有参数值，则参数和参数值之间至少用一个空格隔开）
- **脚本只用于明确覆盖的复合任务**：[scripts/](./scripts/) 下的脚本可封装 AI 表格批量导入导出、AI 应用创建轮询、文档创建后写内容、钉盘目录树等流程；当公开 `+` Shortcut 已提供目标唯一解析、分页/部分失败 ledger 和确认语义时，优先 Shortcut。Chat 历史导出与机器人广播已完全下沉 Runtime，不再发布兼容脚本
- **实时个人事件例外**：普通 IM 消息、reaction、已读和撤回默认走 `dws event +listen-im ...`；OA 审批、群生命周期、明确的原始 EventKey、Filter DSL、subscribe_id 或原始 envelope 使用 `dws event consume ... --flatten`。不要写脚本轮询消息历史或审批列表
- 只允许使用**设备流**登录方式，严禁使用其他登录方式
- 所有发送给用户的内容必须是**markdown格式**

## 产品总览

| 产品                | 用途                                                   | 参考文件                                                           |
|-------------------|------------------------------------------------------|----------------------------------------------------------------|
| `aisearch`        | AI搜问（通用找人首选）：按姓名/部门/职位/职责/上级/下级/手机号/工号维度找人，"谁负责 XX/XX 的负责人/某事项/某项目的人"统一走本产品；不含人才池/绩效/职业历程等专项 HR 场景（那些去 `hrbrain`） | [aisearch.md](./references/products/aisearch.md)               |
| `aitable`         | AI表格：Base/数据表/字段/记录/视图/附件/图表/仪表盘/导入导出/模板搜索            | [aitable.md](./references/products/aitable.md)                 |
| `attendance`      | 考勤：打卡结果/打卡流水/考勤组查询/考勤规则/汇总统计/假期类型/假期余额（P0 已落地，部分管理类命令仍属 P1） | [attendance.md](./references/products/attendance.md)           |
| `calendar`        | 日历：日历列表/日程/参与者/附件/响应/会议室/闲忙查询/时间建议                  | [calendar.md](./references/products/calendar.md)               |
| `chat`            | 群聊与机器人：搜索群/建群/群成员管理/改群名/消息发送(文本/Markdown/图片/文件)/拉取消息/消息收藏/@我/特别关注/机器人群发/单聊/撤回/转发/引用回复/Webhook/机器人搜索 | [chat.md](./references/products/chat.md)                       |
| `contact`         | 通讯录：用户查询/部门/角色/花名册（学历/家庭/银行卡/紧急联系人/合同等基础字段）/离职员工/特别关注，以及创建企业、企业账号和邀请员工；不含职业历程/绩效/人才池（那些去 `hrbrain`） | [contact.md](./references/products/contact.md)                 |
| `devdoc`          | 开放平台文档：搜索开发文档                                        | [devdoc.md](./references/products/devdoc.md)                   |
| `ding`            | DING消息：发送/撤回（应用内/短信/电话）                              | [ding.md](./references/products/ding.md)                       |
| `doc`             | 钉钉文档：搜索/浏览/读写/块级编辑/评论/文件创建/复制/移动/重命名/**删除/导出 docx/权限管理/媒体上传下载**       | [doc.md](./references/products/doc.md)                         |
| `drive`           | 钉钉云盘：文件列表/元数据/文件夹/上传(两步)/下载                        | [drive.md](./references/products/drive.md)                     |
| `hrbrain`         | 组织大脑：人才池管理/员工档案专项模块查询（元数据/批量数据/标签/职业历程/绩效）/结构化高级人才搜索（原始条件表达式）；区别于 `contact` 的基础通讯录档案与 `aisearch` 的通用语义找人 | [hrbrain.md](./references/products/hrbrain.md)                 |
| `markdown`        | 原生 Markdown 文件：读取/创建/全量覆盖/字面量或 RE2 局部替换              | [markdown.md](./references/products/markdown.md)               |
| `minutes`         | AI听记：听记列表/摘要/关键词/转写/待办/思维导图/发言人/发言人段落总结/热词/录音控制/成员权限/上传 | [minutes.md](./references/products/minutes.md)                 |
| `oa`              | OA审批：待处理/详情/同意/拒绝/撤销/记录/已发起/任务/转交/评论/抄送              | [oa.md](./references/products/oa.md)                           |
| `pat`             | PAT 行为授权：浏览器策略/scope 预览/一次性、会话或永久授权                    | [pat.md](./references/products/pat.md)                         |
| `report`          | 日志：按模版创建/收件箱/已发送/模版查看/详情/已读统计                         | [report.md](./references/products/report.md)                   |
| `mail`            | 邮箱：邮箱地址查询/邮件搜索(KQL)/邮件详情/发送邮件                        | [mail.md](./references/products/mail.md)                       |
| `sheet`           | 在线电子表格(axls)：工作表 CRUD/区域读写/CSV 批量写入/行列增删/合并/查找替换/筛选视图/全局筛选/排序/下拉列表/条件格式/浮动图片/浮动图表/模板/导出 xlsx(单命令一站式) | [sheet.md](./references/products/sheet.md)                     |
| `todo`            | 待办：创建(含优先级/截止时间/循环)/查询/修改/标记完成/删除                   | [todo.md](./references/products/todo.md)                       |
| `wiki`            | 知识库：空间创建/详情/列表/搜索 + 成员管理 + 知识库动态查询                | [wiki.md](./references/products/wiki.md)                       |
| `whiteboard`      | 文档内嵌白板：读取 OpenNodes、追加节点、整页重建                           | [whiteboard.md](./references/products/whiteboard.md)           |
| `event`           | 个人 IM/OA 事件：监听消息、群生命周期、审批任务与审批实例事件，NDJSON 输出（实时驱动 Agent）| [event.md](./references/products/event.md)                     |

## 意图判断决策树
用户意图判断详细内容参考 [intent-tree.md](./references/intent-tree.md)

## 危险操作确认

以下操作为不可逆或高影响操作，执行前**必须先向用户展示操作摘要并获得明确同意**，同意后才加 `--yes` 执行。

| 产品 | 命令 | 说明 |
|------|------|------|
| `aitable` | `base delete` | 删除整个 AI 表格，含全部数据表和记录 |
| `aitable` | `table delete` | 删除数据表（含全部字段/视图/记录） |
| `aitable` | `field delete` | 删除字段（该列所有值同步清空） |
| `aitable` | `view delete` | 删除视图 |
| `aitable` | `record delete` | 删除记录（支持批量） |
| `aitable` | `chart delete` / `dashboard delete` | 删除图表/仪表盘 |
| `calendar` | `event delete` | 删除日程，所有参与者同步取消 |
| `calendar` | `participant delete` | 移除日程参与者 |
| `calendar` | `room delete` | 取消会议室预定 |
| `chat` | `group members remove` | 移除群成员 |
| `chat` | `message recall-by-bot` | 撤回机器人已发消息 |
| `doc` | `delete` | **删除整篇文档/文件**到回收站（与 `block delete` 不同，本命令删除整个 node） |
| `doc` | `block delete` | 删除文档单个块（不可恢复） |
| `doc` | `permission update` | 修改协作者权限（降权可能影响他人访问） |
| `ding` | `message recall` | 撤回已发 DING 消息 |
| `oa` | `approval revoke` | 撤销自己发起的审批实例 |
| `oa` | `approval reject` | 拒绝待审批（需加明确理由） |
| `todo` | `task delete` | 删除待办 |
| `minutes` | `replace-text` | 全文批量替换转写与摘要 |

### 确认流程
```
Step 1 → 展示操作摘要（操作类型 + 目标对象 + 影响范围）
Step 2 → 用户明确回复确认（如 "确认" / "好的"）
Step 3 → 加 --yes 执行命令
```

### 确认门禁的识别与重试协议

非交互环境（Agent/CI，stdin 非 TTY）下，写命令不带 `--yes` 时 CLI **不打印交互提示语**，直接失败并输出结构化错误。识别方式：

- `--format json` 输出（或 stderr）中 `error.reason == "confirmation_required"`，错误信息含「当前环境无法交互确认」

遇到 `confirmation_required` 时按以下协议处理：

1. **不要当普通错误放弃**：把命令、风险等级（`write` / `high-risk-write`）和关键参数展示给用户，明确告知这是写/高风险操作
2. 用户显式同意 → 在**原始命令**末尾追加 `--yes` 重试（不改动任何业务参数）
3. 用户拒绝 → 终止，不得改写参数绕过门禁
4. 想先让用户 review 具体请求：加 `--dry-run` 重试——它**不触发确认门禁**，会输出完整调用预览（`invocation.params`），用户确认预览后再换 `--yes` 执行

**禁止**：

- 看到 `confirmation_required` 就未经用户同意自动追加 `--yes` 静默重试（等于禁用门禁）
- 把 `confirmation_required` 当网络/权限错误处理或重试
- 用 `echo yes | dws ...` 等管道方式喂答案代替 `--yes`（管道答案技术上会被接受，但违背了让用户显式知悉的设计意图）

## 核心流程
作为一个智能助手，你的首要任务是**理解用户的真实、完整的意图**，而不是简单地执行命令。在选择 `dws` 的产品命令前，必须严格遵循以下四步流程：

0. **URL 预检**：输入含 `alidocs.dingtalk.com` URL 时，该域名下存在多种路径格式（`/i/nodes/...`、`/i/p/...`、`/spreadsheetv2/...`、`/document/edit|preview?dentryKey=...` 等），每种的处理流程不同。**必须先读取 [url-patterns.md](./references/url-patterns.md) 中的「alidocs URL 分流决策」**，按其中规则识别 URL 类型后再选择对应产品。含 `shanji.dingtalk.com` URL 时直接路由到 `minutes`。URL 已识别后直接进入对应产品流程，无需后续步骤。
1. 意图分类：首先，判断用户指令的核心 动词/动作 属于哪一类。这比关注名词更重要。
2. 歧义处理与信息追问：如果用户指令模糊或包含多个产品的关键字，严禁猜测。必须主动向用户追问以澄清意图。这是你作为智能助手而非命令执行器的核心价值。
3. 精准产品映射：在完成前两步，意图已经清晰后，参考产品总览和意图判断决策树 来选择产品。
4. 按任务最小化读取：已知高频意图直接使用本 Skill 或产品 reference 已给出的唯一命令，不预加载完整产品参考文件；只有路由、参数或异常恢复确实需要时，才读取对应产品或任务 reference。

## 命令发现

### Schema 渐进查询

```bash
dws schema
```

详细内容参考 [progressive-loading-schema.md](./references/progressive-loading-schema.md)

## 错误处理
1. 先读取 JSON 错误的 `retryable`、`retry_after_seconds`、`next_retry_at`、`hint` 和 `actions`；只有明确 `retryable=true` 时才按服务端节奏做一次有界重试。缺少重试语义时加 `--verbose` 收集诊断后停止
2. 仍然失败，报告完整错误信息给用户，禁止自行尝试替代方案
3. 认证失败时，参考 [global-reference.md](./references/global-reference.md) 中的认证章节处理
4. 各产品高频错误及排查流程见 [error-codes.md](./references/error-codes.md)
5. 遇到 [capability-limits.md](./references/capability-limits.md) 中列出的「已知不支持操作」时，**直接告知用户不支持并建议在钉钉客户端操作**，不要重试或变通
