//
//  SettingsWindowManager.swift
//  time-shifty
//
//  设置窗口管理器
//

import AppKit
import SwiftUI

/// 设置窗口管理器
class SettingsWindowManager {
    // MARK: - 属性
    
    private var settingsWindow: NSWindow?
    private var windowDelegate: WindowDelegate?
    
    // MARK: - 窗口管理
    
    /// 显示设置窗口
    func showSettings() {
        // 如果窗口已存在，直接显示
        if let window = settingsWindow {
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            Logger.info("设置窗口已激活", category: "Settings")
            return
        }
        
        // 创建新窗口
        let settingsView = SettingsView()
        let hostingView = NSHostingView(rootView: settingsView)
        
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 600, height: 520),
            styleMask: [.titled, .closable, .miniaturizable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        
        window.title = LocalizationManager.shared.string(.settingsTitle)
        window.contentView = hostingView
        window.center()
        window.isReleasedWhenClosed = false
        window.titlebarAppearsTransparent = true
        window.titleVisibility = .visible
        
        // 创建并保持对 delegate 的强引用
        let delegate = WindowDelegate()
        self.windowDelegate = delegate
        window.delegate = delegate
        
        // 设置窗口级别，确保可见
        window.level = .normal
        
        self.settingsWindow = window
        window.makeKeyAndOrderFront(nil)
        
        // 激活应用
        NSApp.activate(ignoringOtherApps: true)
        
        Logger.success("设置窗口已创建并显示", category: "Settings")
    }
    
    /// 关闭设置窗口
    func closeSettings() {
        settingsWindow?.close()
        settingsWindow = nil
        windowDelegate = nil
        Logger.info("设置窗口已关闭", category: "Settings")
    }
    
    // MARK: - 窗口代理
    
    private class WindowDelegate: NSObject, NSWindowDelegate {
        func windowWillClose(_ notification: Notification) {
            Logger.info("设置窗口即将关闭", category: "Settings")
        }
    }
}
