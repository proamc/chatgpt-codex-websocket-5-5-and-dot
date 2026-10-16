# 可选：让新的 Codex 聊天使用 HTTPS 模型传输

这与启动器分别配置。它适用于支持下述提供商字段的 Codex 版本，控制 **Responses 模型请求**，不是 ChatGPT 应用所有网络连接的统一开关。

## 操作顺序

1. 保存任务，`Command + Q` 完整退出桌面应用。
2. 备份 `~/.codex/config.toml`。若还没有，先安装、登录并打开应用一次，再退出。
3. 用纯文本编辑器打开配置。保留你自己的模型、项目、权限等其他内容。
4. 在**第一个 `[表名]` 之前**设置顶层键。已有 `model_provider` 时替换，不能重复添加：

```toml
model_provider = "openai_https"
```

5. 在文件末尾添加下面的表；已有同名表时更新它，不要重复添加：

```toml
[model_providers.openai_https]
name = "OpenAI HTTPS"
requires_openai_auth = true
wire_api = "responses"
supports_websockets = false
```

6. 从专用代理入口重启应用，**新建一个本地 Codex 聊天**并验证实际模型传输。

可以参考 [`examples/codex-https.toml`](../examples/codex-https.toml)。它只是片段，不能拿来覆盖整份配置。

## 这些字段改变了什么

`model_provider` 选择新定义的提供商。`requires_openai_auth` 保持 OpenAI 的登录认证方式，`wire_api` 使用 Responses，`supports_websockets = false` 关闭该提供商的 Responses WebSocket 支持。

此处没有第三方 `base_url`，也不要求另填 API Key。内置提供商 ID `openai` 是保留项，不要尝试通过 `[model_providers.openai]` 覆盖它。

旧聊天可能保留创建时的提供商。配置看起来正确，还需要核对新聊天的实际运行结果。可请本地助手只读检查它是否使用 `openai_https`，模型日志是否是 `responses_http`，以及是否发生重试。

## 它没有改变什么

dot 本机执行器和其他桌面云连接仍可能使用 WebSocket / WSS。这个配置不关闭它们，也不保证解决所有断线。它们的代理路径要通过启动器与实际本机执行另行验证。

本方案曾在 Codex CLI `0.163.0-alpha.10.2` 上完成新聊天的短时模型测试；不是对所有未来版本的兼容承诺。应用升级后重新检查官方配置参考和日志，不盲目覆盖新配置。

## 撤销

退出应用后恢复自己的备份。如果后来还改过其他设置，只还原这次的顶层 `model_provider` 与 `openai_https` 表，保留后续更改。重开并新建聊天验证。

依据：[OpenAI 官方配置参考](https://learn.chatgpt.com/docs/config-file/config-reference)。

