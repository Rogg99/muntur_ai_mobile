<#
.SYNOPSIS
    Repositions the Android emulator window onto the primary monitor.

.DESCRIPTION
    The Android emulator (qemu-system-x86_64) sometimes restores its window
    at a stale, off-screen position left over from a previous multi-monitor
    setup (e.g. Top=-1096) instead of respecting emulator-user.ini. This
    script finds the running emulator window by process name and forces it
    to a safe position/size on the primary monitor via the Win32 API,
    regardless of what PID the emulator got this time.

.PARAMETER X
    Target window X position (default: 20).
.PARAMETER Y
    Target window Y position (default: 20).
.PARAMETER Width
    Target window width (default: 350).
.PARAMETER Height
    Target window height (default: 750).
.PARAMETER TimeoutSeconds
    How long to wait for the emulator window to appear before giving up
    (default: 30). Useful if you run this right after launching the
    emulator instead of after it has fully started.

.EXAMPLE
    ./tools/fix-emulator-window.ps1
    Run after the emulator window has appeared (or shortly after launching
    it — the script will wait).
#>
param(
    [int]$X = 20,
    [int]$Y = 20,
    [int]$Width = 350,
    [int]$Height = 750,
    [int]$TimeoutSeconds = 30
)

Add-Type @"
using System;
using System.Runtime.InteropServices;
public class EmuWindow {
    [DllImport("user32.dll")]
    public static extern bool SetWindowPos(IntPtr hWnd, IntPtr hWndInsertAfter, int X, int Y, int cx, int cy, uint uFlags);
    [DllImport("user32.dll")]
    public static extern bool ShowWindowAsync(IntPtr hWnd, int nCmdShow);
    [DllImport("user32.dll")]
    public static extern bool GetWindowRect(IntPtr hWnd, out RECT lpRect);
    public struct RECT { public int Left; public int Top; public int Right; public int Bottom; }
}
"@

$SWP_ASYNCWINDOWPOS = 0x4000
$SWP_NOZORDER = 0x0004
$SW_RESTORE = 9

$deadline = (Get-Date).AddSeconds($TimeoutSeconds)
$proc = $null

while ((Get-Date) -lt $deadline) {
    $proc = Get-Process -Name "qemu-system-x86_64" -ErrorAction SilentlyContinue |
        Where-Object { $_.MainWindowHandle -ne [IntPtr]::Zero } |
        Select-Object -First 1
    if ($proc) { break }
    Start-Sleep -Milliseconds 500
}

if (-not $proc) {
    Write-Error "No running emulator window found (qemu-system-x86_64) after waiting ${TimeoutSeconds}s. Launch the emulator first."
    exit 1
}

$hwnd = $proc.MainWindowHandle
Write-Host "Found emulator window (PID $($proc.Id))."

$before = New-Object EmuWindow+RECT
[EmuWindow]::GetWindowRect($hwnd, [ref]$before) | Out-Null
Write-Host "Current position: Left=$($before.Left) Top=$($before.Top) Right=$($before.Right) Bottom=$($before.Bottom)"

[EmuWindow]::ShowWindowAsync($hwnd, $SW_RESTORE) | Out-Null
Start-Sleep -Milliseconds 300
[EmuWindow]::SetWindowPos($hwnd, [IntPtr]::Zero, $X, $Y, $Width, $Height, $SWP_ASYNCWINDOWPOS -bor $SWP_NOZORDER) | Out-Null
Start-Sleep -Milliseconds 300

$after = New-Object EmuWindow+RECT
[EmuWindow]::GetWindowRect($hwnd, [ref]$after) | Out-Null
Write-Host "New position: Left=$($after.Left) Top=$($after.Top) Right=$($after.Right) Bottom=$($after.Bottom)"
