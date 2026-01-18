//
//  AppDelegate.swift
//  time-shifty
//
//  应用委托，负责应用生命周期管理
//

import AppKit
import SwiftUI
import Combine

/// 应用委托
class AppDelegate: NSObject, NSApplicationDelegate {
    // MARK: - 管理器
    
    private var windowManager: WindowManager!
    private var menuBarManager: MenuBarManager!
    
    // Combine 订阅
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - 应用生命周期
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        Logger.info("应用启动", category: "App")
        
        // 配置应用为菜单栏应用（无 Dock 图标）
        NSApplication.shared.setActivationPolicy(.accessory)
        
        // 初始化管理器
        setupManagers()
        
        Logger.success("应用初始化完成", category: "App")
    }
    
    // MARK: - 设置
    
    /// 初始化所有管理器
    private func setupManagers() {
        // 创建窗口管理器
        let settings = AppSettings.shared
        windowManager = WindowManager(cityCount: settings.cities.count)
        
        // 创建菜单栏管理器
        menuBarManager = MenuBarManager(windowManager: windowManager)
        menuBarManager.setupMenuBar()
        
        // 创建并显示窗口
        let contentView = ContentView(onHoverAction: { [weak windowManager] in
            windowManager?.moveToNextCorner()
        })
        windowManager.createWindow(contentView: contentView)
        
        // 监听屏幕设置变化
        setupScreenChangeObserver()
    }
    
    /// 监听屏幕设置变化
    private func setupScreenChangeObserver() {
        AppSettings.shared.$preferredScreenIndex
            .dropFirst() // 跳过初始值
            .sink { [weak self] newIndex in
                Logger.info("检测到屏幕设置变化: \(newIndex)", category: "App")
                self?.windowManager?.updateWindowPosition()
            }
            .store(in: &cancellables)
    }
}
