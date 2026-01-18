//
//  Config.swift
//  time-shifty
//
//  应用配置和常量定义
//

import Foundation
import CoreGraphics

/// 应用全局配置
enum AppConfig {
    // MARK: - 窗口配置
    
    /// 窗口宽度
    static let windowWidth: CGFloat = 300
    
    /// 每个时区行的高度
    static let cityRowHeight: CGFloat = 28
    
    /// 窗口内边距（已弃用，现在直接在 ContentView 中硬编码）
    // static let windowPadding: CGFloat = 4
    
    /// 窗口与屏幕边缘的间距
    static let screenPadding: CGFloat = 40
    
    /// 根据城市数量计算窗口高度
    static func windowHeight(cityCount: Int) -> CGFloat {
        guard cityCount > 0 else { return 0 }
        
        // 精确计算：内容高度（无外边距）
        // 内容高度 = 城市行总高度 + 城市间距
        let contentHeight = CGFloat(cityCount) * cityRowHeight + CGFloat(max(0, cityCount - 1)) * contentSpacing
        return contentHeight  // 列表外边距为0，只依赖城市间距
    }
    
    // MARK: - 动画配置
    
    /// 窗口移动动画时长（秒）
    static let animationDuration: TimeInterval = 0.4
    
    /// 移动完成后的冷却时间（秒）
    static let cooldownDuration: TimeInterval = 0.1
    
    // MARK: - UI 配置
    
    /// 窗口圆角半径
    static let cornerRadius: CGFloat = 12
    
    /// 内容间距（城市之间的垂直间距）
    static let contentSpacing: CGFloat = 14
    
    // MARK: - 调试配置
    
    /// 是否启用详细日志
    static let verboseLogging = true
}
