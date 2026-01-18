//
//  WindowManager.swift
//  time-shifty
//
//  窗口位置管理和动画控制
//

import AppKit
import SwiftUI

/// 窗口管理器，负责窗口的创建、移动和动画
class WindowManager {
    // MARK: - 属性
    
    /// 窗口实例
    private(set) var window: PanelWindow?
    
    /// 当前角落索引（0=左下, 1=左上, 2=右上, 3=右下）
    private var currentCornerIndex = 1
    
    /// 是否正在移动中（防抖标志）
    private var isMoving = false
    
    /// 城市数量（用于计算窗口高度）
    private let cityCount: Int
    
    // MARK: - 初始化
    
    init(cityCount: Int) {
        self.cityCount = cityCount
    }
    
    // MARK: - 窗口创建
    
    /// 创建并配置窗口
    func createWindow(contentView: some View) {
        let height = AppConfig.windowHeight(cityCount: cityCount)
        let window = PanelWindow.createFloatingWindow(
            width: AppConfig.windowWidth,
            height: height
        )
        
        // 设置 SwiftUI 内容视图
        let hostingView = TrackingHostingView(rootView: AnyView(contentView))
        hostingView.onMouseEnter = { [weak self] in
            self?.handleMouseEnter()
        }
        
        window.contentView = hostingView
        self.window = window
        
        // 初始位置
        moveToCorner(animated: false)
        window.makeKeyAndOrderFront(nil)
        
        Logger.success("窗口已创建并显示", category: "WindowManager")
    }
    
    // MARK: - 窗口移动
    
    /// 处理鼠标进入事件
    private func handleMouseEnter() {
        Logger.info("检测到鼠标进入", category: "WindowManager")
        moveToNextCorner()
    }
    
    /// 移动到下一个角落
    func moveToNextCorner() {
        // 防抖：如果正在移动中，忽略此次请求
        guard !isMoving else {
            Logger.debug("移动中，忽略请求", category: "WindowManager")
            return
        }
        
        // 更新到下一个角落
        currentCornerIndex = (currentCornerIndex + 1) % 4
        moveToCorner(animated: true)
    }
    
    /// 移动窗口到指定角落
    /// - Parameter animated: 是否使用动画
    private func moveToCorner(animated: Bool) {
        guard let window = window else {
            Logger.error("无法获取窗口", category: "WindowManager")
            return
        }
        
        // 获取首选屏幕
        let screen = AppSettings.shared.preferredScreen?.visibleFrame ?? NSScreen.main?.visibleFrame
        guard let screenFrame = screen else {
            Logger.error("无法获取屏幕信息", category: "WindowManager")
            return
        }
        
        isMoving = true
        
        let newPosition = calculateCornerPosition(
            index: currentCornerIndex,
            in: screenFrame
        )
        
        Logger.info("移动到角落 \(cornerName(currentCornerIndex)): \(newPosition)", category: "WindowManager")
        
        if animated {
            animateWindowMove(to: newPosition)
        } else {
            window.setFrameOrigin(newPosition)
            isMoving = false
        }
    }
    
    /// 计算角落位置
    private func calculateCornerPosition(index: Int, in screen: NSRect) -> NSPoint {
        let padding = AppConfig.screenPadding
        let width = AppConfig.windowWidth
        let height = AppConfig.windowHeight(cityCount: cityCount)
        
        // 四个角的坐标（macOS 坐标系：左下角为原点）
        let positions: [NSPoint] = [
            NSPoint(x: screen.minX + padding, y: screen.minY + padding),            // 0: 左下
            NSPoint(x: screen.minX + padding, y: screen.maxY - height - padding),   // 1: 左上
            NSPoint(x: screen.maxX - width - padding, y: screen.maxY - height - padding), // 2: 右上
            NSPoint(x: screen.maxX - width - padding, y: screen.minY + padding)     // 3: 右下
        ]
        
        return positions[index]
    }
    
    /// 执行窗口移动动画
    private func animateWindowMove(to position: NSPoint) {
        guard let window = window else { return }
        
        var newFrame = window.frame
        newFrame.origin = position
        
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = AppConfig.animationDuration
            context.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            window.animator().setFrame(newFrame, display: true)
        }, completionHandler: { [weak self] in
            self?.handleAnimationComplete()
        })
    }
    
    /// 动画完成后的处理
    private func handleAnimationComplete() {
        Logger.success("移动动画完成", category: "WindowManager")
        
        // 延迟解锁，防止鼠标还在窗口上时立即触发下一次移动
        DispatchQueue.main.asyncAfter(deadline: .now() + AppConfig.cooldownDuration) { [weak self] in
            self?.isMoving = false
            Logger.debug("移动状态已解锁", category: "WindowManager")
        }
    }
    
    // MARK: - 窗口控制
    
    /// 显示窗口
    func showWindow() {
        window?.makeKeyAndOrderFront(nil)
        Logger.info("窗口已显示", category: "WindowManager")
    }
    
    /// 隐藏窗口
    func hideWindow() {
        window?.orderOut(nil)
        Logger.info("窗口已隐藏", category: "WindowManager")
    }
    
    /// 切换窗口显示状态
    func toggleWindow() {
        if window?.isVisible == true {
            hideWindow()
        } else {
            showWindow()
        }
    }
    
    /// 更新窗口位置到当前屏幕（用于屏幕切换）
    func updateWindowPosition() {
        Logger.info("更新窗口位置到新屏幕", category: "WindowManager")
        moveToCorner(animated: true)
    }
    
    // MARK: - 辅助方法
    
    /// 获取角落名称（用于日志）
    private func cornerName(_ index: Int) -> String {
        ["左下", "左上", "右上", "右下"][index]
    }
}
