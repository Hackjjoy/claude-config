# Windows toast notification for Claude Code with click-to-focus.
#
# Two roles in one file:
#   * Launcher (default): runs synchronously from the hook. Finds the window of
#     the terminal hosting this Claude session by walking the process ancestry,
#     then spawns a detached, hidden copy of itself (-Wait) to own the toast and
#     returns immediately so the hook is not blocked.
#   * Waiter (-Wait): shows the toast, subscribes to its Activated event, and
#     stays alive long enough to bring the host window to the foreground when the
#     user clicks the toast. Self-exits after a timeout.
#
# Strings come in via env vars (CC_NOTIF_TITLE / CC_NOTIF_MSG) to dodge quoting
# issues; they are inherited by the detached waiter.

param(
  [switch]$Wait,
  [long]$Hwnd = 0
)

$ErrorActionPreference = 'SilentlyContinue'
$appId = "{1AC14E77-02E7-4E5D-B744-2EB1AE5198B7}\WindowsPowerShell\v1.0\powershell.exe"

# ----- Launcher role -------------------------------------------------------
if (-not $Wait) {
  # Walk up the process tree from this launcher to the first ancestor that owns
  # a top-level window. That is the terminal/editor hosting this session
  # (e.g. the specific VS Code or Windows Terminal window), even when several
  # are open.
  $hwndFound = 0
  $cur = $PID
  for ($i = 0; $i -lt 12 -and $cur; $i++) {
    $proc = Get-CimInstance Win32_Process -Filter "ProcessId=$cur"
    if (-not $proc) { break }
    $ps = Get-Process -Id $cur -ErrorAction SilentlyContinue
    if ($ps -and $ps.MainWindowHandle -ne 0) { $hwndFound = [long]$ps.MainWindowHandle; break }
    $cur = $proc.ParentProcessId
  }

  # Kill a previous waiter so toasts don't pile up; only the latest is useful.
  $pidFile = Join-Path $env:TEMP 'cc-toast-waiter.pid'
  if (Test-Path $pidFile) {
    $old = Get-Content $pidFile -ErrorAction SilentlyContinue
    if ($old -match '^\d+$') { Stop-Process -Id ([int]$old) -Force -ErrorAction SilentlyContinue }
  }

  $child = Start-Process powershell.exe -PassThru -WindowStyle Hidden -ArgumentList @(
    '-NoProfile', '-ExecutionPolicy', 'Bypass',
    '-File', $PSCommandPath,
    '-Wait', '-Hwnd', $hwndFound
  )
  if ($child) { Set-Content -Path $pidFile -Value $child.Id }
  return
}

# ----- Waiter role ---------------------------------------------------------
Add-Type @"
using System;
using System.Runtime.InteropServices;
public class CCWin {
  [DllImport("user32.dll")] static extern bool SetForegroundWindow(IntPtr h);
  [DllImport("user32.dll")] static extern bool ShowWindow(IntPtr h, int n);
  [DllImport("user32.dll")] static extern bool IsIconic(IntPtr h);
  [DllImport("user32.dll")] static extern IntPtr GetForegroundWindow();
  [DllImport("user32.dll")] static extern uint GetWindowThreadProcessId(IntPtr h, out uint pid);
  [DllImport("kernel32.dll")] static extern uint GetCurrentThreadId();
  [DllImport("user32.dll")] static extern bool AttachThreadInput(uint a, uint b, bool f);
  [DllImport("user32.dll")] static extern bool BringWindowToTop(IntPtr h);
  // Attach to both the current foreground thread and the target thread so
  // Windows lets us steal focus; required when the call originates from a
  // background (hidden) process.
  public static void Focus(IntPtr h) {
    if (h == IntPtr.Zero) return;
    if (IsIconic(h)) ShowWindow(h, 9); // SW_RESTORE
    uint pid;
    uint cur = GetCurrentThreadId();
    uint fgT = GetWindowThreadProcessId(GetForegroundWindow(), out pid);
    uint tgT = GetWindowThreadProcessId(h, out pid);
    AttachThreadInput(cur, fgT, true); AttachThreadInput(cur, tgT, true);
    BringWindowToTop(h); SetForegroundWindow(h);
    AttachThreadInput(cur, fgT, false); AttachThreadInput(cur, tgT, false);
  }
}
"@

$title = $env:CC_NOTIF_TITLE; if (-not $title) { $title = 'Claude Code' }
$msg   = $env:CC_NOTIF_MSG;   if (-not $msg)   { $msg   = 'Task finished' }

[Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime] | Out-Null
$tpl = [Windows.UI.Notifications.ToastNotificationManager]::GetTemplateContent([Windows.UI.Notifications.ToastTemplateType]::ToastText02)
$texts = $tpl.GetElementsByTagName("text")
$texts.Item(0).AppendChild($tpl.CreateTextNode($title)) | Out-Null
$texts.Item(1).AppendChild($tpl.CreateTextNode($msg)) | Out-Null
$toast = [Windows.UI.Notifications.ToastNotification]::new($tpl)

$script:activated = $false
$handler = [Windows.Foundation.TypedEventHandler[Windows.UI.Notifications.ToastNotification, System.Object]] {
  param($s, $e)
  [CCWin]::Focus([IntPtr]$Hwnd)
  $script:activated = $true
}
$toast.add_Activated($handler) | Out-Null
# Stop early only if the user explicitly swipes the toast away (UserCanceled).
# A TimedOut dismissal just means the banner collapsed into the Action Center,
# where the user can still click it later, so we keep waiting in that case.
$toast.add_Dismissed([Windows.Foundation.TypedEventHandler[Windows.UI.Notifications.ToastNotification, Windows.UI.Notifications.ToastDismissedEventArgs]] {
  param($s, $e)
  if ($e.Reason -eq [Windows.UI.Notifications.ToastDismissalReason]::UserCanceled) { $script:activated = $true }
}) | Out-Null

[Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier($appId).Show($toast)

# Stay alive so the Activated callback can fire when clicked. Banners drop to
# the Action Center after a few seconds; keep a window of a few minutes to catch
# a returning user, then exit regardless.
$deadline = (Get-Date).AddSeconds(180)
while (-not $script:activated -and (Get-Date) -lt $deadline) { Start-Sleep -Milliseconds 250 }
