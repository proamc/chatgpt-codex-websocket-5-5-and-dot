#!/bin/zsh
set -eu
task_root="${0:A:h:h}"
task_out="$task_root/dist/ChatGPT Clash Launcher.app"
if [[ -e "$task_out" ]]; then
  print -u2 'dist/ChatGPT Clash Launcher.app 已存在。请先移走它，再重建。'
  exit 1
fi
/bin/mkdir -p "$task_root/dist"
/usr/bin/osacompile -o "$task_out" "$task_root/src/launcher.applescript"
/bin/cp "$task_root/src/launch.zsh" "$task_out/Contents/Resources/launch.zsh"
/bin/chmod 755 "$task_out/Contents/Resources/launch.zsh"
task_plist="$task_out/Contents/Info.plist"
/usr/libexec/PlistBuddy -c 'Add :CFBundleIdentifier string io.github.proamc.chatgpt-clash-launcher' "$task_plist"
/usr/libexec/PlistBuddy -c 'Set :CFBundleName ChatGPT Clash Launcher' "$task_plist"
/usr/libexec/PlistBuddy -c 'Add :CFBundleDisplayName string ChatGPT · Clash' "$task_plist"
/usr/libexec/PlistBuddy -c 'Add :CFBundleShortVersionString string 1.0.0' "$task_plist"
/usr/libexec/PlistBuddy -c 'Add :CFBundleVersion string 1' "$task_plist"
/usr/libexec/PlistBuddy -c 'Add :LSUIElement bool true' "$task_plist"
/usr/libexec/PlistBuddy -c 'Add :LSMinimumSystemVersion string 11.0' "$task_plist"
# Remove unused, overly broad permission descriptions from Apple's template.
for task_permission in NSAppleEventsUsageDescription NSAppleMusicUsageDescription NSCalendarsUsageDescription NSCameraUsageDescription NSContactsUsageDescription NSHomeKitUsageDescription NSMicrophoneUsageDescription NSPhotoLibraryUsageDescription NSRemindersUsageDescription NSSiriUsageDescription NSSystemAdministrationUsageDescription; do
  /usr/libexec/PlistBuddy -c "Delete :$task_permission" "$task_plist"
done
# AppleScript's generated template icon is used. No OpenAI/Clash artwork is copied.
/usr/bin/codesign --force --sign - "$task_out"
/usr/bin/codesign --verify --strict "$task_out"
/usr/bin/plutil -lint "$task_plist"
/bin/zsh -n "$task_out/Contents/Resources/launch.zsh"
/usr/bin/ditto -c -k --sequesterRsrc --keepParent "$task_out" "$task_root/dist/ChatGPT-Clash-Launcher-macOS.zip"
(
  cd "$task_root/dist"
  /usr/bin/shasum -a 256 'ChatGPT-Clash-Launcher-macOS.zip' > SHA256SUMS.txt
)
print "Built: $task_out"
