#!/bin/bash
# macOS notification hook for Claude Code (Stop + Notification events).
# Fires:
#   1) terminal bell -> VS Code terminal tab shows a bell badge when tab is unfocused
#   2) macOS system notification banner via terminal-notifier (preferred) or osascript

CURRENT_DIR=$(basename "$PWD")

# 1) Terminal bell (works in VS Code integrated terminal)
{ printf '\a' > /dev/tty; } 2>/dev/null || printf '\a' >&2

# 2) System notification banner
if command -v terminal-notifier >/dev/null 2>&1; then
  terminal-notifier \
    -title "Claude Code" \
    -message "Task finished in ${CURRENT_DIR}" \
    -group "claude-code-${CURRENT_DIR}" \
    -sender com.microsoft.VSCode \
    >/dev/null 2>&1
elif command -v osascript >/dev/null 2>&1; then
  osascript -e "display notification \"Task finished in ${CURRENT_DIR}\" with title \"Claude Code\"" >/dev/null 2>&1
fi

exit 0
