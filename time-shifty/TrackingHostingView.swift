//
//  TrackingHostingView.swift
//  time-shifty
//
//  支持鼠标追踪的 SwiftUI 宿主视图
//

import SwiftUI
import AppKit

/// 自定义 NSHostingView，添加鼠标进入/退出事件追踪
class TrackingHostingView<Content: View>: NSHostingView<Content> {
    /// 鼠标进入回调
    var onMouseEnter: (() -> Void)?
    
    /// 鼠标退出回调
    var onMouseExit: (() -> Void)?
    
    // MARK: - 追踪区域管理
    
    override func updateTrackingAreas() {
        super.updateTrackingAreas()
        
        // 移除旧的追踪区域
        trackingAreas.forEach { removeTrackingArea($0) }
        
        // 创建新的追踪区域，覆盖整个视图
        let options: NSTrackingArea.Options = [
            .mouseEnteredAndExited,  // 追踪进入和退出事件
            .activeAlways,           // 始终激活（即使窗口不是焦点）
            .inVisibleRect           // 自动适应可见区域
        ]
        
        let trackingArea = NSTrackingArea(
            rect: bounds,
            options: options,
            owner: self,
            userInfo: nil
        )
        
        addTrackingArea(trackingArea)
        Logger.debug("鼠标追踪区域已更新: \(bounds)", category: "Tracking")
    }
    
    // MARK: - 鼠标事件
    
    override func mouseEntered(with event: NSEvent) {
        super.mouseEntered(with: event)
        Logger.debug("鼠标进入", category: "Tracking")
        onMouseEnter?()
    }
    
    override func mouseExited(with event: NSEvent) {
        super.mouseExited(with: event)
        Logger.debug("鼠标离开", category: "Tracking")
        onMouseExit?()
    }
}
