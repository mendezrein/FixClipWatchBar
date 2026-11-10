# FixClipWatchBar

macOS menu bar toggle app for `/Users/reinaldomendez/.local/bin/fix-clip-watch`.

## About

🍎 macOS status-item menu bar app  
⚡ Start / stop / status toggle for `fix-clip-watch`  
🟠 Orange checkpoint badge in About window  
📦 LSUIElement bundle `com.rei.fixclipwatchbar`  
🛠️ Built with ObjC + AppKit (clang), v0.1.0

## What it is

Small macOS status-item app (LSUIElement, `com.rei.fixclipwatchbar`) that starts, stops, and reports status of the `fix-clip-watch` watcher from the menu bar. Includes an About window with an orange checkpoint badge.

## Files

- `Package.swift` — Swift package manifest (unused; built with clang)
- `Sources/main.m` — AppKit status item, start/stop toggle, About window
- `build/FixClipWatchBar` — compiled x86_64 Mach-O binary
- `FixClipWatchBar.app` — installed app bundle
- `index.md` — project index

## State

v0.1.0 — watcher running. Toggle (start/stop/status) verified end-to-end.
