# Local setup brief / 新 Mac 本地配置指令

[中文指令](#中文指令) · [English instructions](#english-instructions) · [Shared parameters / 共享参数](#shared-parameters)

本文供用户明确要求本地助手执行配置时使用，具体操作遵循当前对话的授权和安全要求。  
Use this brief when the user explicitly asks a local assistant to perform the setup. It does not override the conversation's permissions or safety requirements.

## 中文指令

请帮我把这台 Mac 配置成以下使用方式：Clash 系统代理开启、TUN 关闭；原版 ChatGPT/Codex 从一个不弹终端的专用图标启动；新本地模型聊天使用 HTTPS；dot 能实际在这台 Mac 上执行任务。

请先完成环境核实、备份和准备，再集中应用改动，尽量只安排一次正常重开。下面的步骤有明确的进入条件；不要跳过失败的前置检查，也不要用配置文件存在代替实际可用。

### 1. 核实前置条件

先只读检查并记录：

- 当前 Mac 的系统、Clash、原版桌面应用及内置 Codex 版本。
- 原版 `.app` 的真实路径和 `Info.plist` 中的 `CFBundleExecutable`。可能是 ChatGPT.app、Codex.app 或其他实际安装名。
- Clash 的系统代理状态、TUN 状态、HTTP/Mixed 监听地址与端口。`7897` 只是参考值，不直接照抄。
- 基础网页连接，以及目标应用是否运行、已有实例是否获得期望代理。

只提取需要的字段，不输出完整进程环境、认证文件、订阅或无关日志。缺少应用、可用订阅、登录或本机权限时，直接提出具体缺项；继续不依赖它的准备工作，暂不执行依赖该项的步骤。

目标基线是规则模式、系统代理开、TUN 关。在我的授权范围内恢复这套基线，不顺手修改节点、DNS、路由、Tailscale 或其他 VPN。网页本身不通时，先定位节点和分流问题。

### 2. 一次准备好入口、备份与候选配置

请在本机制作 `.app` 专用入口，命名可为 `ChatGPT（Clash专用）`，安装在当前用户 `~/Applications`。可以采用 AppleScript 应用及内部脚本，或等效的原生方案。不需要下载预编译工具。

入口使用已核实的原版程序路径和混合端口，仅向本次启动的应用与子进程传入[共享参数](#shared-parameters)。不写入全局登录环境、`launchctl setenv`、全局 shell 配置或 LaunchAgent，不修改原版应用包，不安装证书或关闭证书验证。

| 情况 | 入口必须表现为 |
| --- | --- |
| 正常启动 | 打开原版应用，无终端、调试文字或等待回车 |
| 相同代理的实例已运行 | 激活现有窗口，不重启 |
| 已运行但参数不同 | 提示保存任务、完整退出后重开，不强退 |
| Clash 端口未响应 | 给出具体图形提示；不把端口响应当外网证明 |
| 应用路径错误或启动即退出 | 报告具体失败，不宣称已经可用 |

按实际可执行路径或应用身份识别运行实例，不仅依赖写死的进程名称。正确引用路径和参数；后台启动时完整重定向标准输入、输出和错误，不调用 Terminal 或等待输入。

备份 `~/.codex/config.toml`，记录权限和校验值。核对当前版本支持[模型配置](#model-configuration)，制作只包含必要改动的候选配置，保留原模型、项目、权限与其他设置。

**进入下一步前**：完成入口语法、资源、签名及适合该实现的行为检查，检查 TOML 结构和配置差异。已有同名入口先检查、复用或备份，不直接覆盖。

### 3. 集中应用，安排正常重开

在授权范围内合并已检查的配置，为入口创建桌面快捷方式并固定到程序坞，保留其他项目。不要迁移别人的整份配置、账号或认证文件。

准备完成后明确提醒我：保存任务，用 Command + Q 完整退出原版应用，从专用图标重新打开。不要突然关闭正在工作的应用；需要我操作时等待完成，不虚构重开结果。已获得安全重开的授权时按当前会话继续，不反复索要相同许可。

### 4. 分别验收模型和 dot

按[验收标准](#acceptance-criteria)记录结果和时间。新建本地 Codex 聊天，检查其提供商与模型传输；旧聊天可能保留创建时的提供商。

dot 需要本机授权，并保持这台 Mac 在线、应用打开。当前官方说明只能同时连接一台个人电脑；迁移时确认选中的是新 Mac。只按实际任务申请必要权限。

你可以让 dot 在本机只读查询 macOS 版本、构建号和 `uname -s`，但必须取得实际本机工具结果。普通聊天回复、云端电脑结果、在线标记或端口可达都不能代替。

**技术边界必须准确**：模型可以使用 HTTPS；dot 本机中继仍可能使用 WSS，这里通过显式代理处理路径，不把它强制改成 HTTPS。

### 5. 有失败就定位对应通道

- 网页也失败：先查 Clash 节点、订阅和分流。
- 模型仍用 WebSocket：查是否新聊天、实际提供商和当前版本配置支持。
- 已使用 HTTPS 仍超时：查代理路径、DNS、规则和出口，不能把切换传输当万能修复。
- 模型正常、dot 失败：查执行器代理继承、本机授权、WSS 中继和实际出口。
- 401/403：区别已认证应用请求与无认证探测；后者的 403 不单独证明账号异常。
- TUN 影响其他软件：回到系统代理开、TUN 关；路由与 DNS 根因另行处理。

检查实时日志或数据库时用安全的只读方式，只取相关字段和时段。不要输出无关聊天和凭据。

### 6. 简洁交付

告诉我两项独立改动、入口位置、程序坞状态、日常顺序，以及已通过、失败、未测的项目。把实际结果和下一步写清楚，不把短时成功写成长期保证。

说明撤销：完整退出后从原版图标打开，可停止由入口注入变量；入口与程序坞项目可移除；模型 HTTPS 需单独还原本次字段，保留之后新增设置。Clash 系统代理仍由它自身管理。

## English instructions

Configure this Mac with Clash's system proxy on and TUN off. Create a dedicated launcher that opens the official ChatGPT/Codex app without Terminal, configure HTTPS for new local Codex model conversations, and verify that dot can execute on this Mac.

Complete discovery, backups and preparation before applying changes together. Aim for one normal app restart. Do not proceed past an unmet prerequisite or equate configuration with successful execution.

### 1. Discover the actual environment

Read and record the macOS, Clash, desktop app and bundled Codex versions; the real application path and `CFBundleExecutable`; the actual HTTP/Mixed listener and system proxy/TUN state; browser connectivity; and existing app processes with their relevant proxy values.

Use only the fields needed for this task. Do not print the full process environment, credentials, subscription URLs or unrelated logs. Ask for the specific missing installation, connectivity, sign-in or local permission when required, while continuing independent preparation.

The intended baseline is rule mode, system proxy on, TUN off. Restore it within the user's authorization. Do not casually change DNS, routes, Tailscale, other VPNs or nodes. Resolve basic connectivity before dependent setup.

### 2. Prepare the launcher and candidate config

Create the `.app` locally in the current user's `~/Applications` using native macOS facilities. Use the verified official executable and HTTP/Mixed port, with the [shared environment](#shared-parameters) supplied only to that process and its children.

Do not change the original app bundle, global login environment, global shell profiles or LaunchAgents. Do not install certificates or disable verification. Quote inputs safely and fully redirect background standard input, output and error streams. Never open Terminal or wait for Terminal input.

Required behavior: activate an already-running instance with matching values; request a normal saved-work exit for a mismatched instance; give a graphical error for an unavailable listener, missing executable or immediate launch failure. Do not force-quit or infer external connectivity from a listening port. Identify the real process by executable path or app identity rather than one hard-coded display name.

Back up `~/.codex/config.toml`, recording permissions and a checksum. Check current version support and prepare the [model provider changes](#model-configuration), preserving the user's model and unrelated configuration. Inspect existing launchers before reusing or replacing them.

Before applying, validate launcher syntax, resources, signing and appropriate behavior checks, plus TOML structure and the exact config diff.

### 3. Apply together, then reopen normally

Within the user's authorization, merge the checked configuration, create the desktop shortcut and pin the launcher to the Dock without disturbing existing items. Do not migrate another computer's authentication files or complete user configuration.

Once preparation is complete, explain the single required action: save work, quit the original app normally and reopen it through the dedicated launcher. Do not interrupt active tasks or claim the restart occurred if the user still needs to perform it. Respect authorization already provided in the conversation.

### 4. Verify both channels

Follow the [acceptance criteria](#acceptance-criteria), recording time, evidence and failures. Use a new local Codex conversation because existing conversations may retain their provider. Check actual model transport rather than only file contents.

Connect the intended Mac to dot with the necessary local permission. The current official guide allows one connected personal computer per dot. Keep the Mac online with the desktop app open. Obtain an actual local read-only tool result; a chat answer, cloud result, online indicator or reachable port does not qualify.

Maintain the distinction: model transport can use HTTPS, while dot's local relay may still require WSS. The launcher provides proxy settings; it does not force dot onto HTTPS.

### 5. Diagnose the failing layer

If browser access fails, start with Clash connectivity and routing. If the model still uses WebSocket, check the new conversation, provider and version support. If HTTPS times out, inspect the proxy path, DNS, rules and exit node. If only dot fails, inspect executor inheritance, authorization and the WSS relay.

Distinguish authenticated application errors from unauthenticated probes before interpreting 401/403. Return to system proxy on/TUN off if TUN disrupts other applications. Read only relevant log fields and time ranges without exposing unrelated content.

### 6. Deliver a concise result

Report the two independent changes, launcher location, Dock status, daily opening sequence, and passed/failed/untested checks. Do not turn short validation into a long-term guarantee.

Explain rollback: a normal quit followed by opening the original app stops this launcher's environment injection; remove the launcher and Dock item if desired. Restore model settings separately while preserving unrelated later changes. Clash's system proxy remains managed by Clash.

## Shared parameters

### Process environment / 进程环境

Replace `<PORT>` with the verified local **HTTP/Mixed** port, not a SOCKS-only port. These values are passed to the target process and its children only.  
使用已核实的本机混合端口，仅传给目标进程及子进程。

```text
HTTP_PROXY=http://127.0.0.1:<PORT>
HTTPS_PROXY=http://127.0.0.1:<PORT>
ALL_PROXY=http://127.0.0.1:<PORT>
WS_PROXY=http://127.0.0.1:<PORT>
WSS_PROXY=http://127.0.0.1:<PORT>

http_proxy=http://127.0.0.1:<PORT>
https_proxy=http://127.0.0.1:<PORT>
all_proxy=http://127.0.0.1:<PORT>
ws_proxy=http://127.0.0.1:<PORT>
wss_proxy=http://127.0.0.1:<PORT>

NODE_USE_ENV_PROXY=1
NO_PROXY=localhost,127.0.0.1,::1,.local,.ts.net,10.0.0.0/8,172.16.0.0/12,192.168.0.0/16,100.64.0.0/10
no_proxy=localhost,127.0.0.1,::1,.local,.ts.net,10.0.0.0/8,172.16.0.0/12,192.168.0.0/16,100.64.0.0/10
```

Support for these variables, Node runtime behavior and `NO_PROXY`/CIDR matching varies by networking client. Verify inheritance and real connections.  
变量、Node 运行时及 CIDR 例外的支持取决于客户端，必须验证实际结果。

### Model configuration

Check current official documentation and installed behavior. The reference setup was validated with Codex CLI `0.163.0-alpha.10.2`. Keep the existing OpenAI sign-in method, model and unrelated settings; add no third-party `base_url` or API key.  
先检查版本兼容性，保留登录方式、模型和无关设置，不添加第三方地址或密钥。

Put this key at the root, **before the first TOML table**, replacing any existing value.  
顶层键放在第一个 TOML 表之前，已有键时替换。

```toml
model_provider = "openai_https"
```

Append or update this table. The built-in `openai` provider ID is reserved. Do not use obsolete feature flags as a substitute for verified transport.  
添加或更新下表，不覆盖内置 `openai`，不用已移除的开关替代实际验证。

```toml
[model_providers.openai_https]
name = "OpenAI HTTPS"
requires_openai_auth = true
wire_api = "responses"
supports_websockets = false
```

## Acceptance criteria

| Check / 检查 | Evidence / 通过证据 |
| --- | --- |
| Launcher / 入口 | Opens the official app without Terminal; safe handling of existing instances / 无终端启动，并妥善处理已有实例 |
| Inheritance / 代理继承 | App and dot executor receive the intended values; disclose only relevant keys / 核对实际继承，仅输出相关键 |
| New model conversation / 新模型聊天 | Six sequential completed short requests; `openai_https`, `responses_http`; record retries / 连续 6 次完成并核对传输，记录重试 |
| dot local execution / 本机执行 | Actual macOS version, build and `uname -s` from this Mac / 真实本机工具结果 |
| Interval checks / 间隔复测 | Repeat local queries after about 1 and 5 minutes; record interruptions / 约 1、5 分钟复测，记录中断 |
| Mac restart / 重启后 | Only when the user schedules it: wait for Clash, use the launcher and retest / 由用户安排重启后复测，不自行重启 Mac |

Mark unperformed checks as untested. Isolated fixture tests do not prove model service or dot connectivity.  
未做项目标记未测；隔离假应用测试不能代替真实模型与 dot 验收。

## References / 官方参考

- [Clash Verge: Quick start](https://www.clashverge.dev/guide/quickstart.html)
- [OpenAI: Configuration reference](https://learn.chatgpt.com/docs/config-file/config-reference)
- [OpenAI: Computers and dot](https://learn.chatgpt.com/docs/dots/computers-and-apps)
