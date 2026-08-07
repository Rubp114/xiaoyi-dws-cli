# DingTalk Workspace Skill

本 skill 包提供钉钉全产品 CLI 能力（AI表格/日历/群聊/文档/审批/考勤/待办/邮箱/云盘/听记等）。

## 包内容

| 文件/目录 | 说明 |
|---|---|
| `SKILL.md` | Skill 入口（OpenClaw 加载此文件） |
| `reference.json` | CLI 工具注册表（命令目录 + 安全规则 + 产品索引） |
| `dws` | ★ 钉钉 CLI 二进制（纯静态，需编译） |
| `references/` | 产品参考文档（124 个 .md，覆盖 20+ 产品） |
| `scripts/` | Python 辅助脚本（34 个，批量/复合操作） |

## 快速开始

### 1. 编译 dws 二进制

在装有 Go 1.25+ 的 Linux 机器上：

```bash
bash scripts/build-dws.sh
```

产物为 `dws`（纯静态 Linux amd64 二进制，约 15-20 MB）。

### 2. 部署到 OpenClaw

将整个 `dingtalk/` 目录复制到 OpenClaw 的 skills 目录：

```bash
cp -r dingtalk/ ~/.openclaw/workspace/skills/
```

### 3. 初始化

```bash
chmod +x ~/.openclaw/workspace/skills/dingtalk/dws
~/.openclaw/workspace/skills/dingtalk/dws version
```

### 4. 登录

```bash
~/.openclaw/workspace/skills/dingtalk/dws auth login --device --no-browser --format json
```

将验证码和链接发给用户完成钉钉扫码授权。

## 依赖说明

- **dws 二进制**: 纯静态编译（CGO_ENABLED=0），无运行时依赖
- **Python 脚本**: 仅复杂复合任务时按需使用，核心功能不依赖
- **联网**: 运行时需访问 `*.dingtalk.com`（钉钉 API）
