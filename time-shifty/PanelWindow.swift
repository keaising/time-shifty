//
//  PanelWindow.swift
//  time-shifty
//
//  自定义的浮动面板窗口
//

import AppKit

/// 无边框浮动窗口
class PanelWindow: NSWindow {
    /// 允许窗口成为关键窗口（接收键盘输入）
    override var canBecomeKey: Bool { true }
    
    /// 允许窗口成为主窗口
    override var canBecomeMain: Bool { true }
    
    /// 允许窗口接收第一响应者事件
    override var acceptsFirstResponder: Bool { true }
    
    /// 创建配置好的浮动窗口
    static func createFloatingWindow(width: CGFloat, height: CGFloat) -> PanelWindow {
        let window = PanelWindow(
            contentRect: NSRect(x: 0, y: 0, width: width, height: height),
            styleMask: [.borderless, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        
        // 窗口外观配置
        window.isOpaque = false
        window.backgroundColor = .clear
        window.hasShadow = false
        
        // 窗口行为配置
        window.level = .floating
        window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        
        // 鼠标事件配置
        window.acceptsMouseMovedEvents = true
        window.ignoresMouseEvents = false
        
        Logger.success("浮动窗口创建成功", category: "Window")
        return window
    }
}
