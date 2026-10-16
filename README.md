# ChatGPT · Clash Launcher

给 macOS 上的 ChatGPT / Codex 和 dot 本机执行器，一个单独的代理启动入口。

**Clash 系统代理开、TUN 关。点一下图标打开原版应用，没有终端窗口。**

> 先说清楚：这个启动器负责传递代理地址。可选的 Codex 配置负责让模型请求改走 HTTPS。**dot 的本机连接仍可能使用 WebSocket / WSS**；本项目让它获得显式代理，不能把它强制改成 HTTPS。

[像朋友一样读完这段经历](docs/my-setup-story.zh-CN.md) · [从新 Mac 开始](docs/new-mac.zh-CN.md) · [可选：模型 HTTPS](docs/model-https.zh-CN.md) · [排错与卸载](docs/troubleshooting.zh-CN.md)

## 为什么做这个

我原本以为，Clash 的“系统代理”已经打开，电脑里所有软件就会自动走代理。后来发现，浏览器可以访问网页，ChatGPT/Codex 仍可能反复重连，dot 也可能显示连接异常。

这里其实有两件事：应用有没有采用代理，以及模型请求使用哪种传输。系统代理需要程序主动遵循；部分网络客户端更依赖启动时收到的代理变量。另一方面，当模型 WebSocket 请求频繁超时时，可以单独验证 HTTPS 传输是否更适合当前网络。

这个项目把这两件事分开处理：

| 部分 | 做什么 | 边界 |
| --- | --- | --- |
| 无终端启动器 | 给原版应用和它启动的子进程传入本机代理地址 | 不修改系统代理、TUN、原版安装包或全局登录环境 |
| 可选模型配置 | 为 Codex 提供商关闭 Responses WebSocket 支持 | 不关闭 dot 或其他桌面云连接的 WebSocket |
| 迁移与验收说明 | 在新电脑重新登录、重新连接并执行本机查询 | 不把“网页能开”或“电脑在线”当作实际执行成功 |

## 下载安装

1. 在 [Releases](https://github.com/proamc/chatgpt-codex-websocket-5-5-and-dot/releases) 下载 `ChatGPT-Clash-Launcher-macOS.zip`，解压。
2. 把 `ChatGPT Clash Launcher.app` 放进个人“应用程序”文件夹 `~/Applications`，再拖到程序坞的应用区。
3. 打开 Clash Verge：导入自己的订阅，开启系统代理、关闭 TUN，确认 HTTP / Mixed 混合端口。常见值为 `7897`，以你的设置为准。
4. 保存任务，用 `Command + Q` 完整退出已运行的 ChatGPT / Codex。
5. 点击新图标。首次填写 Clash 端口和原版应用路径，然后保存并启动。以后直接点图标。

常见原版路径是 `/Applications/ChatGPT.app` 或 `/Applications/Codex.app`，填写你实际安装的那个。**不要选择启动器自身。**

按住 **Option** 再点击图标，可以重新设置端口和应用路径。设置仅保存在 `~/Library/Application Support/ChatGPT Clash Launcher/config.plist`。

这是本地临时签名、未经过 Apple 公证的独立工具。如果 macOS 提示开发者无法验证，核实下载来源和校验值后，按系统“隐私与安全”界面的提示处理这个应用。不要关闭 Gatekeeper 或证书验证。参见 [Apple 说明](https://support.apple.com/guide/mac-help/mh40616/mac)。

## 日常使用

先开 Clash，再点这个入口。Clash 节点照常在 Clash 里选择。

- 原版应用已带着相同代理运行：激活现有窗口。
- 原版应用正在运行，但参数不一致：提示你先保存任务并退出，不会强退。
- Clash 端口没有响应：给出提示，不会继续假装启动成功。
- 正常打开：没有终端、没有“按回车关闭”，也没有成功弹窗。

首次连接 dot 时，在它的电脑列表里允许访问这台 Mac，然后让它**实际查询本机系统版本**。模型普通聊天和 dot 本机连接是不同的验证项目。详见 [新电脑验收表](docs/new-mac.zh-CN.md#验收表)。

## 想让模型从第一条请求走 HTTPS？

按 [模型 HTTPS 配置说明](docs/model-https.zh-CN.md) 备份并合并 `~/.codex/config.toml`，重启后**新建本地 Codex 聊天**验证。

启动器不会自动修改你的模型配置。不要用配置片段覆盖整份文件，也不要把模型配置当作 dot 的 WebSocket 开关。

## 实现方式

网络路径由各请求命中的 Clash 规则决定。启动器只向原版应用及其子进程传递这些变量：

```text
HTTP_PROXY HTTPS_PROXY ALL_PROXY WS_PROXY WSS_PROXY
http_proxy https_proxy all_proxy ws_proxy wss_proxy
  = http://127.0.0.1:<你的 HTTP / Mixed 端口>

NODE_USE_ENV_PROXY=1
```

同时设置 `NO_PROXY` / `no_proxy`，包含回环、本地域名、私有 IPv4 和 Tailscale CGNAT 地址段。具体列表见 [`src/launch.zsh`](src/launch.zsh)。不同网络库对这些变量、CIDR 例外和 WebSocket 代理的支持不同，最终以实际连接为准。

本项目没有 VPN/TUN 接管能力，也不会让 Telegram 等其他独立启动的软件自动采用这些变量。不要填 SOCKS-only 端口；此入口使用的是 HTTP 代理 URL，兼容 Clash 的 HTTP / Mixed 端口。

## 自己构建与测试

需要 macOS 的 `osacompile`、`zsh`、`codesign`。集成测试额外需要 Python 3 和 Xcode Command Line Tools 的 C 编译器。

```sh
zsh scripts/build.sh
python3 -m unittest discover -s tests -v
```

输出在 `dist/`。生成应用使用 macOS 的通用 AppleScript 模板，未复制 OpenAI 或 Clash 的图标、程序或账号文件。构建脚本不覆盖已有同名应用；重建前先移走旧构建。

测试使用临时目录中的原生假应用和本机测试端口，检查真实进程变量继承、重复启动状态、端口验证和缺失应用处理。不会启动或关闭你的 ChatGPT，不会连接模型服务。通过这些测试不代表真实模型或 dot 服务在所有网络上都可用。

## 适用范围

这是社区工具，与 OpenAI、ChatGPT、Codex、Clash Verge 官方没有从属关系。需要自行安装原版应用、Clash，并拥有可用的代理配置和账号。

本机开发验证环境为 macOS；生成的模板二进制同时包含 Apple Silicon 和 Intel 架构。最低系统版本写为 macOS 11，**未对所有系统、芯片和桌面应用版本完成实机验证**。Windows 不适用。

HTTPS 配置依据 [OpenAI 配置参考](https://learn.chatgpt.com/docs/config-file/config-reference)，dot 连接步骤依据 [OpenAI 本机连接说明](https://learn.chatgpt.com/docs/dots/computers-and-apps)。应用更新后，应重新验证配置是否仍生效。

MIT License。欢迎提交不含订阅、令牌和个人日志的 Issue / PR。

