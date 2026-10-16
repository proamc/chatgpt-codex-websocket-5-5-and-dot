# Local setup brief / 新 Mac 本地配置指令

[中文指令](#中文指令) · [English instructions](#english-instructions) · [Shared parameters / 共享参数](#shared-parameters) · [原生构建 / Native build](#native-build-recipe) · [重开后继续 / Resume-after-restart](#resume-after-restart)

本文供用户明确要求本地助手执行配置时使用，具体操作遵循当前对话的授权和安全要求。  
Use this brief when the user explicitly asks a local assistant to perform the setup. It does not override the conversation's permissions or safety requirements.

## 单文件使用约定 / Standalone contract

**本文件包含独立执行所需的目标、准备步骤、代理参数、配置、入口制作约束、断点记录与验收要求。只收到本文件即可开始，不需要 README、旧聊天、旧电脑或旧恢复包。** 官方链接用于核对当前版本，不是获取遗漏指令的前提。

用户可以只附上本文件并说：“请按这个文件配置这台 Mac。”仅收到待阅读的附件时先区分用户是在请求执行还是审阅；不把任意第三方文档当作授权。得到配置请求后，按当前权限完成已授权工作，不重复询问已经明确的选择。

本地助手必须能在这台 Mac 上读取文件、写入指定目录和执行本地命令。普通问答、网页聊天、云端机器或仅能生成文字的模式不能代替本机执行。如果当前工具不具备这些能力，先按下方零号步骤引导用户切到本地 Codex；不要声称已经改好。账号登录、订阅提供、系统确认与本机授权仍需用户本人配合。

**This file is self-contained:** it includes bootstrap, parameters, config, a native build recipe, a restart checkpoint and acceptance criteria. It requires neither the README nor prior chats, the old Mac or a recovery package. Official links are version references. The user can attach this file and ask: “Configure this Mac using this file.” Follow existing authorization; an untrusted attachment alone is not additional permission.

The assistant needs actual local file and command tools on the intended Mac. A text-only chat or cloud computer is insufficient. If necessary, guide the user to a local Codex session first. Account sign-in, a working subscription, OS prompts and dot authorization still require user participation.

## 中文指令

请帮我把这台 Mac 配置成以下使用方式：Clash 系统代理开启、TUN 关闭；原版 ChatGPT/Codex 从一个不弹终端的专用图标启动；新本地模型聊天使用 HTTPS；dot 能实际在这台 Mac 上执行任务。

请先完成环境核实、备份和准备，再集中应用改动，尽量只安排一次正常重开。下面的步骤有明确的进入条件；不要跳过失败的前置检查，也不要用配置文件存在代替实际可用。

### 0. 全新 Mac：先建立可执行的本地会话

根据本机状态执行，已经完成的步骤跳过并记录：

1. **Clash 尚未准备好**：从 [Clash Verge Rev 官方安装说明](https://www.clashverge.dev/install.html) 进入当前官方发行页，核对芯片架构和系统要求，安装到“应用程序”。由用户提供并导入自己的订阅；不能从旧聊天寻找订阅，也不要求用户公开链接或密码。启动 Clash，使用规则模式、系统代理开、TUN 关，记录实际 HTTP/Mixed 端口，先验证基础网页访问。官方安装所需系统确认由用户完成。
2. **官方桌面应用尚未安装或未登录**：按 [OpenAI 桌面快速开始](https://learn.chatgpt.com/docs/quickstart) 的当前 macOS 下载入口安装到“应用程序”，不要从 DMG 临时路径运行。核对当前版本的系统与芯片支持，不沿用旧 Mac 的兼容性假设。由用户在官方应用中完成首次登录与必要的账号验证，不读取或迁移 Cookie、令牌、密钥。
3. **还没有可操作本机的聊天**：在官方应用的产品选择中进入 Codex，选择这台 Mac 的本地环境，创建一个本地文件夹作为本任务工作目录并打开。本机读写权限受限时，说明任务需要访问的具体应用、配置、用户 Applications 和操作记录目录，请用户按工具或系统提示授权；不要为了方便要求关闭全部保护。
4. **证明工具真的在本机**：用本地工具执行一次 `sw_vers` 和 `uname -s`，并在用户选定的工作目录创建、读回一个小的任务记录。记下实际工作位置。只生成命令文本不算执行，不能用云端工具结果代替。
5. **助手根本无法联网或发送第一条请求**：这是进入主路径前的引导阻塞。先让用户确认 Clash 节点、系统代理和官方登录能用；若仍不能发起本地任务，明确缺少“一个可响应且具备本机工具的助手”，给出最小的恢复动作或切换可用的本地执行入口。文档不能在完全无法运行的助手中自行执行，不要反复启动任务或把 dot 当成启动配置的必要条件。当前已有可执行本地会话时不走此支路。
6. **dot 功能尚未出现**：先完成本地 Codex 和入口部分，到验收时再检查账号界面、当前支持范围和组织策略。没有入口或管理员限制时标为待用户/管理员处理，不安装来历不明的执行器或通过隐藏开关强行启用。

这一步不要求 Homebrew、Git、Python、Node.js 或完整 Xcode。构建优先采用后文列出的 macOS 原生工具。用户暂时没有订阅、账号或必要权限时，把具体缺项集中列出，完成其余独立准备后保存进度。

### 1. 核实前置条件

先只读检查并记录：

- 当前 Mac 的系统、Clash、原版桌面应用及内置 Codex 版本。
- 原版 `.app` 的真实路径和 `Info.plist` 中的 `CFBundleExecutable`。可能是 ChatGPT.app、Codex.app 或其他实际安装名。
- Clash 的系统代理状态、TUN 状态、HTTP/Mixed 监听地址与端口。`7897` 只是参考值，不直接照抄。
- 基础网页连接，以及目标应用是否运行、已有实例是否获得期望代理。
- 桌面应用实际使用的用户级配置根目录。默认是 `~/.codex`；若目标进程已使用 `CODEX_HOME` 或配置 profile，记录实际值和覆盖关系，不把当前 shell 的值当成桌面应用的事实。不要更改现有自定义根目录；必要时让专用入口保留已核实的 `CODEX_HOME`。

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

定位**实际生效的用户级** `config.toml`，默认 `~/.codex/config.toml`，不要把提供商设置写入项目目录的 `.codex/config.toml`。核对当前版本的 profile、命令行或组织管理覆盖；不要绕过强制策略。此处配置针对本地 Codex 模型，不承诺改变 Work Cloud、普通 Chat 或 dot 云端模型。

- 文件已存在：先逐字备份，记录路径、权限和 SHA-256，再生成候选配置，保留原模型、项目、权限与其他设置。
- 全新环境文件不存在：先记录“原文件不存在”。确认实际配置目录后，必要时创建目录和最小文件；新建私有配置目录建议权限 700、新建文件 600。不要伪造旧备份，也不要把缺少配置文件误判为安装失败。
- 本文的提供商字段不受支持，或被组织策略覆盖：停止这一项修改并说明证据；仍可完成独立的代理入口。不要随意降级应用、切到第三方网关或修改安全策略。

保存前校验 TOML 结构和改动范围。优先使用应用自带 CLI 支持的无模型请求配置读取能力（先看该版本帮助，如确有只读 `features list` 可用）或已经安装的解析器；不要依赖新 Mac 必然拥有 Python 3.11 的 `tomllib`，也不要为了一个配置检查安装整套开发环境。权限或解析检查未通过，不覆盖原文件。原子替换时保留原权限。 若用 CLI 校验，确认它确实读取候选内容；可在帮助确认支持后，仅为验证子进程使用一个已存在的临时 `CODEX_HOME` 并放入候选文件，不复制认证文件、不启动模型请求、不修改全局环境。不要把读取旧配置成功当作候选配置通过。

**进入下一步前**：按[原生构建配方](#native-build-recipe)完成入口语法、资源、签名及适合该实现的行为检查，检查 TOML 结构和配置差异。已有同名入口先检查、复用或备份，不直接覆盖。按[断点记录](#resume-after-restart)保存本机进度，再进入重开阶段。

### 3. 集中应用，安排正常重开

在授权范围内合并已检查的配置，为入口创建桌面快捷方式并固定到程序坞，保留其他项目。不要迁移别人的整份配置、账号或认证文件。

准备完成后，先将本文件的本地副本、实际路径和未完成检查写入断点记录，再明确提醒我：保存任务，用 Command + Q 完整退出原版应用，从专用图标重新打开。不要突然关闭正在工作的应用；需要我操作时等待完成，不虚构重开结果。已获得安全重开的授权时按当前会话继续，不反复索要相同许可。

### 4. 分别验收模型和 dot

按[验收标准](#acceptance-criteria)记录结果和时间。新建本地 Codex 聊天，检查其提供商与模型传输；旧聊天可能保留创建时的提供商。

dot 需要本机授权：在 ChatGPT 的 dot 资料页找到 Computers / 电脑 → Your computer / 本机 → Allow access / 允许访问，阅读确认后由用户完成授权。界面命名变化时按当前官方说明定位，不虚构已经点过。保持这台 Mac 在线、应用打开。当前官方说明只能同时连接一台个人电脑；迁移时确认选中的是新 Mac。只按实际任务申请必要权限。

请让用户在 dot 的对话中发送下方现成指令，或在当前会话确有获授权的 dot 测试工具时执行同等测试：

> 请在我刚连接的这台 Mac 上只读查询 macOS 版本和构建号，并执行 uname -s。报告实际本机工具结果，不读写我的个人文件，不使用云端电脑代替。

把实际执行位置与零号步骤的本机基线对照，不写死任何旧机器版本。必须取得实际本机工具结果。普通聊天回复、云端电脑结果、在线标记或端口可达都不能代替。

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

### 0. Bootstrap a fresh Mac

Skip completed items and record their state. If Clash is absent, use its [official installation page](https://www.clashverge.dev/install.html), select the current supported architecture and OS, install it in Applications and have the user import their own subscription. Start in rule mode with system proxy on/TUN off, identify the HTTP/Mixed port and establish browser connectivity.

If the desktop app is absent or unsigned-in, follow the current macOS download link in the [OpenAI quickstart](https://learn.chatgpt.com/docs/quickstart), install in Applications instead of running from the DMG, and let the user complete official sign-in and any verification. Recheck current system/chip support; do not migrate credentials or assume every account exposes dot.

In the app's product selector, enter Codex, select the local Mac environment and open a task folder. Verify actual local execution with `sw_vers`, `uname -s` and a small record written and read back in that folder. Request only the specific paths or OS confirmations needed by the task. A normal chat, a cloud environment or generated command text does not prove local tools are available.

If no local assistant can send its first request, resolve Clash connectivity/sign-in or establish a usable local execution session first. This is a bootstrap blocker, not a completed setup; do not depend on dot to configure dot. If dot is absent or organization-restricted, complete the independent local pieces and identify the missing entitlement/approval without inventing a hidden installer.

Do not require Homebrew, Git, Python, Node.js or full Xcode for the native build. Collect missing user-supplied subscription, sign-in and permissions in one concise list, continue independent preparation and save the checkpoint.

### 1. Discover the actual environment

Read and record the macOS, Clash, desktop app and bundled Codex versions; the real application path and `CFBundleExecutable`; the actual HTTP/Mixed listener and system proxy/TUN state; browser connectivity; and existing app processes with their relevant proxy values.

Use only the fields needed for this task. Do not print the full process environment, credentials, subscription URLs or unrelated logs. Ask for the specific missing installation, connectivity, sign-in or local permission when required, while continuing independent preparation.

Resolve the actual desktop configuration root, including any existing `CODEX_HOME`, selected profile and effective overrides. Do not assume the shell environment matches the GUI app; preserve a verified custom root in the dedicated launcher where necessary.

The intended baseline is rule mode, system proxy on, TUN off. Restore it within the user's authorization. Do not casually change DNS, routes, Tailscale, other VPNs or nodes. Resolve basic connectivity before dependent setup.

### 2. Prepare the launcher and candidate config

Create the `.app` locally in the current user's `~/Applications` using native macOS facilities. Use the verified official executable and HTTP/Mixed port, with the [shared environment](#shared-parameters) supplied only to that process and its children.

Do not change the original app bundle, global login environment, global shell profiles or LaunchAgents. Do not install certificates or disable verification. Quote inputs safely and fully redirect background standard input, output and error streams. Never open Terminal or wait for Terminal input.

Required behavior: activate an already-running instance with matching values; request a normal saved-work exit for a mismatched instance; give a graphical error for an unavailable listener, missing executable or immediate launch failure. Do not force-quit or infer external connectivity from a listening port. Identify the real process by executable path or app identity rather than one hard-coded display name.

Use the effective **user-level** config, normally `~/.codex/config.toml`, not a project-local provider table. Check selected profiles, explicit overrides and managed policy. The provider setting applies to local Codex model requests, not every Chat/Work Cloud/dot model.

If the file exists, back it up byte-for-byte with permissions and SHA-256. If absent, record its absence, verify the root and create only the needed directory/file, using 700/600 for newly created private config directory/file. Preserve existing choices, permissions and unrelated settings. If the provider fields are unsupported or policy-enforced, stop that change and report it while continuing independent launcher work.

Validate the candidate with a supported bundled CLI configuration-read operation, checked against that version's help, or an already available parser. Do not assume Python/tomllib or install a development toolchain just to check TOML. Preserve permissions on replacement; do not overwrite a file after failed validation. Ensure a CLI check actually reads the candidate; where supported, use an existing temporary config root only for that child process, without copying credentials, sending a model request or changing the global environment. Successfully reading the old config does not validate the candidate. Inspect existing launchers before reusing or replacing them.

Before applying, follow the [native build recipe](#native-build-recipe), validate syntax/resources/signing and appropriate behavior checks, inspect the TOML structure/diff and write the [restart checkpoint](#resume-after-restart).

### 3. Apply together, then reopen normally

Within the user's authorization, merge the checked configuration, create the desktop shortcut and pin the launcher to the Dock without disturbing existing items. Do not migrate another computer's authentication files or complete user configuration.

Save a local copy of this brief, resolved paths and remaining checks in the checkpoint. Once preparation is complete, explain the single required action: save work, quit the original app normally and reopen it through the dedicated launcher. Do not interrupt active tasks or claim the restart occurred if the user still needs to perform it. Respect authorization already provided in the conversation.

### 4. Verify both channels

Follow the [acceptance criteria](#acceptance-criteria), recording time, evidence and failures. Use a new local Codex conversation because existing conversations may retain their provider. Check actual model transport rather than only file contents.

In the ChatGPT app, open the dot profile, then Computers → Your computer → Allow access. Have the user review and confirm local access; use current official labels if they change. Do not claim this confirmation happened before it does. The current official guide allows one connected personal computer per dot. Keep the Mac online with the desktop app open. Ask dot: “On the Mac I just connected, read the macOS version, build number and uname -s. Report the actual local tool result; do not read/write my personal files or substitute a cloud computer.” Compare the execution target with the bootstrap baseline. A chat answer, cloud result, online indicator or reachable port does not qualify.

Maintain the distinction: model transport can use HTTPS, while dot's local relay may still require WSS. The launcher provides proxy settings; it does not force dot onto HTTPS.

### 5. Diagnose the failing layer

If browser access fails, start with Clash connectivity and routing. If the model still uses WebSocket, check the new conversation, provider and version support. If HTTPS times out, inspect the proxy path, DNS, rules and exit node. If only dot fails, inspect executor inheritance, authorization and the WSS relay.

Distinguish authenticated application errors from unauthenticated probes before interpreting 401/403. Return to system proxy on/TUN off if TUN disrupts other applications. Read only relevant log fields and time ranges without exposing unrelated content.

### 6. Deliver a concise result

Report the two independent changes, launcher location, Dock status, daily opening sequence, and passed/failed/untested checks. Do not turn short validation into a long-term guarantee.

Explain rollback: a normal quit followed by opening the original app stops this launcher's environment injection; remove the launcher and Dock item if desired. Restore model settings separately while preserving unrelated later changes. Clash's system proxy remains managed by Clash.

## Native build recipe

本配方是独立实现约定，不依赖仓库源码。由本地助手生成所需小文件，仓库仍只有两份说明。

This is an implementation recipe; no repository source files are required. Generate the small files locally.

1. **原生工具 / Native tools**：先检查 `/bin/zsh`、`/usr/bin/osacompile`、`/usr/libexec/PlistBuddy`、`/usr/bin/plutil`、`/usr/bin/codesign`、`/usr/bin/nc` 和 `/usr/bin/open`。缺项时具体报告，不默默安装 Homebrew/Xcode。Use the existing system tools; do not introduce a package-manager dependency.
2. **本机生成 / Generate locally**：在用户任务目录的独立子目录生成 `launcher.applescript` 与 `launch.zsh`。AppleScript 的 `on run` 通过 `POSIX path of (path to me)` 定位自己包内 `Contents/Resources/launch.zsh`，用 `do shell script` 在后台执行；用 `display alert` 显示需要用户处理的错误。不要硬编码旧用户名、仓库绝对路径或当前聊天标识。Locate resources relative to the launcher itself and use native alerts, not Terminal.
3. **启动逻辑 / Launch logic**：校验端口为 1–65535 的整数、目标 `.app` 不是启动器自身、主可执行文件存在，检查回环端口及已有实例。新启动用 `/usr/bin/nohup /usr/bin/env` 携带后文全部变量直接执行已核实的原版主程序，标准流全部重定向后后台运行。**不要仅在 `open -a` 前设环境变量就声称注入成功**；Launch Services 的环境继承需要实际验证。已有正确实例可用 `open -a` 激活。Check the actual app remains running and inherits values; guard repeated clicks from creating duplicate launches.
4. **封装 / Package**：用 `osacompile -o <临时应用路径> <脚本路径>` 编译应用，将脚本放入 `Contents/Resources` 并设为当前用户可执行。用原生 plist 工具设置独立 `CFBundleIdentifier`、显示名、版本和布尔 `LSUIElement=true`；字段存在时更新、不存在时添加。图标可在本机引用/复制原版图标或用系统模板，不需要图像生成工具。Compile an applet and add/update plist keys correctly; do not assume every key exists in the template.
5. **检查再安装 / Validate then install**：`zsh -n` 检查脚本，`plutil -lint` 检查 plist；完成资源修改后 `codesign --force --sign - <应用>`，再 `codesign --verify --strict <应用>`。这只是本地临时签名，不等于 Apple 公证。不要为打开入口关闭系统安全保护。Stage and validate before placing it at its final user-owned location.
6. **固定与维护 / Install and maintain**：创建 `~/Applications`（如不存在），安装完成的应用，再创建桌面入口、添加程序坞项目；先核对重复项，保留其他内容。记录实际端口和目标应用路径，端口或官方应用位置变更时能在本机更新入口。验证重新登录后，从持久位置点图标仍可使用，不依赖工作目录、终端会话或旧临时文件。启动器本身不负责自动开启 Clash；可按用户偏好开启 Clash 登录启动，重开后仍检查端口。

首次配置可以通过本地工具完成；“无终端”指日常双击体验，不禁止助手为制作与检查执行命令。现有官方应用退出会终止当前本地助手时，必须先完成下方记录。

The no-Terminal requirement concerns daily launching, not the assistant's local build commands. Save the checkpoint before a restart can interrupt the assistant itself.

## Resume after restart

重开桌面应用会中断当前助手，旧聊天还可能绑定旧提供商，因此必须留下不依赖聊天历史的本机记录。

An app restart can interrupt the agent; an old chat may also retain the old provider. Persist a local checkpoint before it happens.

- 默认记录目录：`~/Library/Application Support/ChatGPT-Clash-Setup/`，按当前用户名展开；受工具权限限制时放在用户已授权的持久任务目录，并把**实际绝对路径**交给用户。这不是 LaunchAgent 或登录代理。Use a persistent user-authorized directory, never a temporary folder as the only copy.
- 保存本文件副本，以及 `setup-state.md`：实际系统/应用/CLI版本，目标应用和主程序、Clash 端口、实际用户配置根目录、原文件是否存在、备份与校验值、已改字段、入口/桌面/程序坞位置、上次更新时间、待完成项和安全撤销方法。排除认证、订阅、完整进程环境和无关日志。Record prepared/applied state separately from verified results; include no secrets.
- 状态依次记录为 `prepared`、`pending-restart`、`verifying`、`verified` 或 `blocked`，只在所有必需项实际通过后写 `verified`。可选 Mac 重启项另记未测，不用它冒充主路径失败或完成。Do not mark completion before required real checks pass.
- 在用户退出前给出可复制的恢复指令，替换成记录的真实路径：**“请读取「实际绝对目录」/forchatgpt.md 和「实际绝对目录」/setup-state.md，从未完成项继续，只读核对已完成项，不重复覆盖备份或创建入口。”** Give this resume message before the current app quits.
- 重开后用户新建本地 Codex 聊天并发送恢复指令。新助手先核对本机记录与现状，再完成新聊天模型测试和 dot 验收；原聊天仍能继续也不能替代新聊天传输验证。A new agent can resume using these local files alone.
- 撤销时：原配置存在则按原值和校验记录还原本次字段，后来发生其他修改时不整份覆盖；原配置不存在则仅在文件仍与本次生成版本相同时移除本次文件，存在后续更改时保留其他内容。自建目录仅在空且确为本次创建时清理；保留用户之前的入口与程序坞项。Restore only this task's changes and preserve newer user changes.

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
| New model conversation / 新模型聊天 | Create one local Codex chat; send “Reply only MODEL_HTTPS_01_OK”, then 02–06 sequentially, waiting for each completion / 新建一条本地聊天，依次发 01–06 并等待完整回复 |
| Transport proof / 传输证据 | Correlate that new chat ID and test times with `openai_https` and `responses_http`; record retries / 按新聊天标识和时间核对提供商、实际传输与重试 |
| dot local execution / 本机执行 | Actual macOS version, build and `uname -s` from this Mac / 真实本机工具结果 |
| Interval checks / 间隔复测 | Repeat local queries after about 1 and 5 minutes; record interruptions / 约 1、5 分钟复测，记录中断 |
| Mac restart / 重启后 | Only when the user schedules it: wait for Clash, use the launcher and retest / 由用户安排重启后复测，不自行重启 Mac |

如助手有获授权的聊天管理工具，可创建一个专用本地测试聊天并依次发送 6 条；没有该工具时给用户一个完整的小清单，由用户新建并依次发送，不循环索要确认。日志定位应根据当前 `CODEX_HOME`、应用身份、当前会话文件和时间戳识别，不能依赖旧机器的数据库名、字段或私有聊天 ID。只有 TLS/443、网页 200 或低延迟不能区分模型 HTTP 与 WebSocket；看不到当前版本的传输证据时写“传输未验证”，不要猜测通过。

Use authorized chat-management tools when available; otherwise give the user one complete checklist for the new local test conversation. Resolve logs by the current config root, application identity, conversation and time, not old machine schemas or IDs. If transport evidence is unavailable, record it as unverified rather than inferring it from TLS/443 or web reachability.

Mark unperformed checks as untested. Isolated fixture tests do not prove model service or dot connectivity.  
未做项目标记未测；隔离假应用测试不能代替真实模型与 dot 验收。

## References / 官方参考

- [Clash Verge: Official installation](https://www.clashverge.dev/install.html)
- [OpenAI: Desktop quickstart](https://learn.chatgpt.com/docs/quickstart)
- [OpenAI: Config/state locations and environment](https://learn.chatgpt.com/docs/config-file/environment-variables)
- [Clash Verge: Quick start](https://www.clashverge.dev/guide/quickstart.html)
- [OpenAI: Configuration reference](https://learn.chatgpt.com/docs/config-file/config-reference)
- [OpenAI: Computers and dot](https://learn.chatgpt.com/docs/dots/computers-and-apps)
