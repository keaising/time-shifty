//
//  MenuBarManager.swift
//  time-shifty
//
//  菜单栏图标和菜单管理
//

import AppKit

/// 菜单栏管理器
class MenuBarManager {
    // MARK: - 属性
    
    /// 状态栏图标项
    private var statusItem: NSStatusItem?
    
    /// 窗口管理器引用（用于控制窗口）
    private weak var windowManager: WindowManager?
    
    /// 设置窗口管理器
    private let settingsWindowManager = SettingsWindowManager()
    
    // MARK: - 初始化
    
    init(windowManager: WindowManager) {
        self.windowManager = windowManager
    }
    
    // MARK: - 设置
    
    /// 创建并配置菜单栏图标
    func setupMenuBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        
        configureButton()
        configureMenu()
        
        Logger.success("菜单栏已配置", category: "MenuBar")
    }
    
    /// 配置状态栏按钮
    private func configureButton() {
        guard let button = statusItem?.button else { return }
        
        button.image = NSImage(
            systemSymbolName: "t.square.fill",
            accessibilityDescription: "Time Shifty"
        )
        button.toolTip = "Time Shifty - 多时区时钟"
    }
    
    /// 配置菜单
    private func configureMenu() {
        let menu = NSMenu()
        let localization = LocalizationManager.shared
        
        // 显示/隐藏窗口
        let showHideTitle = localization.effectiveLanguage == .chinese ? "显示/隐藏窗口" : "Show/Hide Window"
        menu.addItem(
            withTitle: showHideTitle,
            action: #selector(toggleWindow),
            keyEquivalent: ""
        ).target = self
        
        // 设置
        menu.addItem(
            withTitle: localization.string(.menuSettings),
            action: #selector(openSettings),
            keyEquivalent: ","
        ).target = self
        
        menu.addItem(.separator())
        
        // 退出
        menu.addItem(
            withTitle: localization.string(.menuQuit),
            action: #selector(quitApp),
            keyEquivalent: "q"
        ).target = self
        
        statusItem?.menu = menu
    }
    
    // MARK: - 菜单操作
    
    /// 切换窗口显示
    @objc private func toggleWindow() {
        windowManager?.toggleWindow()
    }
    
    /// 打开设置窗口
    @objc private func openSettings() {
        Logger.info("打开设置窗口", category: "MenuBar")
        settingsWindowManager.showSettings()
    }
    
    /// 退出应用
    @objc private func quitApp() {
        Logger.info("用户请求退出应用", category: "MenuBar")
        NSApplication.shared.terminate(nil)
    }
}
