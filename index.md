# FixClipWatchBar

Menu bar toggle app for `/Users/reinaldomendez/.local/bin/fix-clip-watch`.

Project root: `/Users/reinaldomendez/testrun/FixClipWatchBar`

Files:
- Package.swift — Swift package manifest (unused; built with clang)
- Sources/main.m — AppKit status item, start/stop toggle, About window with orange checkpoint badge.
- build/FixClipWatchBar — compiled binary (x86_64 Mach-O).
- FixClipWatchBar.app — installed bundle (LSUIElement = true, com.rei.fixclipwatchbar).
- index.md — this file.

State: v0.1.0, pushed to public repo github.com/mendezrein/FixClipWatchBar (origin -> main, commit 7030de1). Added global hotkey toggle default Cmd+Shift+4 with changeable shortcut (menu "Change Shortcut…", persisted in UserDefaults), rebuilt build/FixClipWatchBar. Watcher running. Verified toggle (start/stop/status) end-to-end.
