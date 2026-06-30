#!/bin/bash
# Cross-platform notification hook for Claude Code (Stop + Notification events).
# Fires:
#   1) terminal bell -> VS Code terminal tab shows a bell badge when tab is unfocused
#   2) system notification banner:
#        - macOS:   terminal-notifier (preferred) or osascript
#        - Windows: PowerShell WinRT toast (no extra module needed)
#        - Linux:   notify-send (if available)

CURRENT_DIR=$(basename "$PWD")
TITLE="Claude Code"
MESSAGE="Task finished in ${CURRENT_DIR}"

# Run a command with a hard time limit so a slow/hung notifier can never
# block this Stop hook (which would freeze the turn at "running stop hooks").
# macOS ships no `timeout`/`gtimeout`, so implement it with a watchdog.
with_timeout() {
  local secs="$1"; shift
  "$@" & local pid=$!
  ( sleep "$secs"; kill -9 "$pid" 2>/dev/null ) >/dev/null 2>&1 & local killer=$!
  wait "$pid" 2>/dev/null
  kill "$killer" 2>/dev/null; wait "$killer" 2>/dev/null
}

# 1) Terminal bell (works in VS Code integrated terminal on every OS)
{ printf '\a' > /dev/tty; } 2>/dev/null || printf '\a' >&2

# 2) System notification banner, by platform
case "$(uname -s)" in
  Darwin)
    # NOTE: terminal-notifier's `-sender <bundle-id>` flag hangs indefinitely
    # on recent macOS (it blocks trying to impersonate the sender app), which
    # stalls the Stop hook. Do NOT pass -sender. Calls are also time-boxed.
    if command -v terminal-notifier >/dev/null 2>&1; then
      with_timeout 5 terminal-notifier \
        -title "$TITLE" \
        -message "$MESSAGE" \
        -group "claude-code-${CURRENT_DIR}" \
        >/dev/null 2>&1
    elif command -v osascript >/dev/null 2>&1; then
      with_timeout 5 osascript -e "display notification \"${MESSAGE}\" with title \"${TITLE}\"" >/dev/null 2>&1
    fi
    ;;

  MINGW*|MSYS*|CYGWIN*|Windows_NT)
    # Pass strings via env vars to avoid shell/PowerShell quoting issues.
    CC_NOTIF_TITLE="$TITLE" CC_NOTIF_MSG="$MESSAGE" \
    powershell.exe -NoProfile -ExecutionPolicy Bypass -Command '
      try {
        [Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime] | Out-Null
        $t = [Windows.UI.Notifications.ToastNotificationManager]::GetTemplateContent([Windows.UI.Notifications.ToastTemplateType]::ToastText02)
        $x = $t.GetElementsByTagName("text")
        $x.Item(0).AppendChild($t.CreateTextNode($env:CC_NOTIF_TITLE)) | Out-Null
        $x.Item(1).AppendChild($t.CreateTextNode($env:CC_NOTIF_MSG)) | Out-Null
        $appId = "{1AC14E77-02E7-4E5D-B744-2EB1AE5198B7}\WindowsPowerShell\v1.0\powershell.exe"
        $toast = [Windows.UI.Notifications.ToastNotification]::new($t)
        [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier($appId).Show($toast)
      } catch { }
    ' >/dev/null 2>&1
    ;;

  Linux)
    if command -v notify-send >/dev/null 2>&1; then
      notify-send "$TITLE" "$MESSAGE" >/dev/null 2>&1
    fi
    ;;
esac

exit 0
