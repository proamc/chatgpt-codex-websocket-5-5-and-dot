#!/bin/zsh
# Local HTTP CONNECT proxy only. No global environment or app-bundle changes.
set -eu

valid_port() {
  [[ "$1" == <-> && ${#1} -le 5 ]] || return 1
  (( 10#$1 >= 1 && 10#$1 <= 65535 ))
}

if [[ "${1:-}" == '--validate-port' ]]; then
  valid_port "${2:-}"
  exit $?
fi

task_action="${1:-}"
task_port="${2:-}"
task_app="${3:-}"
if [[ "$task_action" != '--check' && "$task_action" != '--launch' ]]; then
  print -u2 'Usage: launch.zsh --check|--launch PORT /path/to/Application.app'
  exit 64
fi
if ! valid_port "$task_port"; then
  print -u2 '代理端口必须是 1-65535 之间的整数。'
  exit 64
fi
# Strip leading zeros so URL and TCP probe use the same decimal port.
task_port="$((10#$task_port))"
task_proxy="http://127.0.0.1:$task_port"
task_bypass='localhost,127.0.0.1,::1,.local,.ts.net,10.0.0.0/8,172.16.0.0/12,192.168.0.0/16,100.64.0.0/10'

if [[ ! -d "$task_app" ]]; then
  print 'missing-app'
  exit 0
fi
task_executable=$(/usr/libexec/PlistBuddy -c 'Print :CFBundleExecutable' "$task_app/Contents/Info.plist" 2>/dev/null) || task_executable=''
if [[ -z "$task_executable" || "$task_executable" == */* ]]; then
  print 'missing-app'
  exit 0
fi
task_binary="$task_app/Contents/MacOS/$task_executable"
if [[ ! -x "$task_binary" ]]; then
  print 'missing-app'
  exit 0
fi

if ! /usr/bin/nc -z -G 2 127.0.0.1 "$task_port" >/dev/null 2>&1; then
  print 'proxy-unavailable'
  exit 0
fi

task_pid=$(/bin/ps -axo pid=,comm= | /usr/bin/awk -v app="$task_binary" '{pid=$1; sub(/^[[:space:]]*[0-9]+[[:space:]]+/, ""); if ($0 == app) {print pid; exit}}')
if [[ -n "$task_pid" ]]; then
  # Never print the process environment: unrelated secrets may be present.
  task_environment=$(/bin/ps eww -p "$task_pid" -o command= 2>/dev/null) || task_environment=''
  task_ready=1
  for task_key in HTTP_PROXY HTTPS_PROXY ALL_PROXY WS_PROXY WSS_PROXY http_proxy https_proxy all_proxy ws_proxy wss_proxy; do
    if [[ " $task_environment " != *" $task_key=$task_proxy "* ]]; then task_ready=0; fi
  done
  for task_key in NO_PROXY no_proxy; do
    if [[ " $task_environment " != *" $task_key=$task_bypass "* ]]; then task_ready=0; fi
  done
  if [[ " $task_environment " != *' NODE_USE_ENV_PROXY=1 '* ]]; then task_ready=0; fi
  unset task_environment
  if (( task_ready )); then print 'already-ready'; else print 'needs-restart'; fi
  exit 0
fi

if [[ "$task_action" == '--check' ]]; then
  print 'ready-to-launch'
  exit 0
fi

/usr/bin/nohup /usr/bin/env \
  HTTP_PROXY="$task_proxy" HTTPS_PROXY="$task_proxy" \
  ALL_PROXY="$task_proxy" WS_PROXY="$task_proxy" WSS_PROXY="$task_proxy" \
  http_proxy="$task_proxy" https_proxy="$task_proxy" \
  all_proxy="$task_proxy" ws_proxy="$task_proxy" wss_proxy="$task_proxy" \
  NO_PROXY="$task_bypass" no_proxy="$task_bypass" NODE_USE_ENV_PROXY=1 \
  "$task_binary" </dev/null >/dev/null 2>&1 &
task_child=$!
/bin/sleep 1
if ! /bin/kill -0 "$task_child" 2>/dev/null; then
  print -u2 '应用启动后立即退出。请先确认原版应用能够正常打开。'
  exit 70
fi
print 'launched'

