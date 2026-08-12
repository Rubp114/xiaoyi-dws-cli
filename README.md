# DingTalk Workspace Skill

本 skill 包提供钉钉全产品 CLI 能力（AI表格/日历/群聊/文档/审批/考勤/待办/邮箱/云盘/听记等）。

## 包内容

| 文件/目录 | 说明 |
|---|---|
| `SKILL.md` | Skill 入口（OpenClaw 加载此文件） |
| `reference.json` | CLI 工具注册表（命令目录 + 安全规则 + 产品索引） |
| `references/` | 产品参考文档 |
| `scripts/` | Python 辅助脚本（批量/复合操作） |

## 快速开始

### 1. 安装 dws CLI

本 skill 不携带 dws 二进制，使用前需先安装。

**macOS / Linux:**

```bash
curl -fsSL https://raw.githubusercontent.com/DingTalk-Real-AI/dingtalk-workspace-cli/main/scripts/install.sh | sh
```

**Windows (PowerShell):**

```powershell
irm https://raw.githubusercontent.com/DingTalk-Real-AI/dingtalk-workspace-cli/main/scripts/install.ps1 | iex
```

中国大陆用户可使用 Gitee 镜像：

```bash
DWS_GITEE_REPO=DingTalk-Real-AI/dingtalk-workspace-cli curl -fsSL https://gitee.com/DingTalk-Real-AI/dingtalk-workspace-cli/raw/main/scripts/install.sh | sh
```

其他安装方式（npm、Homebrew、预编译二进制、源码编译）详见[上游 README](https://github.com/DingTalk-Real-AI/dingtalk-workspace-cli#installation)。

### 2. 验证安装

```bash
dws version
```

### 3. 登录

```bash
dws auth login --device --no-browser --format json
```

将验证码和链接发给用户完成钉钉扫码授权。

## 依赖说明

- **dws CLI**: 需通过官方安装脚本安装（纯静态编译，无运行时依赖）
- **Python 脚本**: 仅复杂复合任务时按需使用，核心功能不依赖
- **联网**: 运行时需访问 `*.dingtalk.com`（钉钉 API）
