use framework "AppKit"
use scripting additions

on run
    set taskTitle to "ChatGPT · Clash"
    set taskWorker to (POSIX path of (path to me)) & "Contents/Resources/launch.zsh"
    set taskConfigDirectory to (POSIX path of (path to home folder)) & "Library/Application Support/ChatGPT Clash Launcher"
    set taskConfig to taskConfigDirectory & "/config.plist"
    set taskPort to "7897"
    set taskApp to "/Applications/ChatGPT.app"
    set needsSettings to false

    try
        try
            set taskPort to do shell script "/usr/libexec/PlistBuddy -c 'Print :port' " & quoted form of taskConfig
            set taskApp to do shell script "/usr/libexec/PlistBuddy -c 'Print :app' " & quoted form of taskConfig
        on error
            set needsSettings to true
            try
                do shell script "/usr/bin/test -d " & quoted form of taskApp
            on error
                set taskApp to "/Applications/Codex.app"
            end try
        end try

        set taskFlags to (current application's NSEvent's modifierFlags()) as integer
        if ((taskFlags div 524288) mod 2) is 1 then set needsSettings to true

        if needsSettings then
            set taskPort to my configurePort(taskTitle, taskWorker, taskPort)
            set taskApp to my configureApp(taskTitle, taskApp)
            do shell script "/bin/mkdir -p " & quoted form of taskConfigDirectory & " && /usr/bin/defaults write " & quoted form of taskConfig & " port -int " & quoted form of taskPort & " && /usr/bin/defaults write " & quoted form of taskConfig & " app -string " & quoted form of taskApp
        end if

        set taskState to do shell script "/bin/zsh " & quoted form of taskWorker & " --launch " & quoted form of taskPort & " " & quoted form of taskApp
        if taskState is "already-ready" then
            do shell script "/usr/bin/open -a " & quoted form of taskApp
        else if taskState is "needs-restart" then
            display alert taskTitle message "应用已经在运行，但代理参数与这个入口不同。请先保存任务，用 Command + Q 完整退出，然后再点这个图标。当前应用没有被关闭。" as warning
        else if taskState is "proxy-unavailable" then
            display alert taskTitle message "本机 Clash 端口未响应。请打开 Clash，保持系统代理开启、TUN 关闭，再重试。端口如有变化，按住 Option 点此图标重新设置。" as warning
        else if taskState is "missing-app" then
            display alert taskTitle message "没有找到选定的原版应用或它的主程序。请按住 Option 点此图标，检查应用路径。" as warning
        else if taskState is not "launched" then
            error "启动器返回了未识别的状态。"
        end if
    on error taskMessage number taskNumber
        if taskNumber is not -128 then display alert taskTitle message taskMessage as warning
    end try
end run

on configurePort(taskTitle, taskWorker, previousPort)
    repeat
        set taskAnswer to display dialog "填写 Clash 的 HTTP / Mixed 混合端口。代理地址固定为本机 127.0.0.1。请保持系统代理开启、TUN 关闭。" default answer previousPort with title taskTitle buttons {"取消", "继续"} default button "继续" cancel button "取消"
        set taskPort to text returned of taskAnswer
        try
            do shell script "/bin/zsh " & quoted form of taskWorker & " --validate-port " & quoted form of taskPort
            return taskPort
        on error
            display alert taskTitle message "请输入 1-65535 之间的整数端口，例如 7897。" as warning
        end try
    end repeat
end configurePort

on configureApp(taskTitle, previousApp)
    set taskAnswer to display dialog "填写原版 ChatGPT / Codex 的 .app 路径。常见位置是 /Applications/ChatGPT.app 或 /Applications/Codex.app。不要填这个启动器自己的路径。" default answer previousApp with title taskTitle buttons {"取消", "保存并启动"} default button "保存并启动" cancel button "取消"
    set taskApp to text returned of taskAnswer
    do shell script "/usr/bin/test -d " & quoted form of taskApp
    if taskApp is (POSIX path of (path to me)) or (taskApp & "/") is (POSIX path of (path to me)) then error "请选择原版应用，不要选择启动器自己。"
    return taskApp
end configureApp

