//
//  time_shiftyApp.swift
//  time-shifty
//
//  应用程序入口
//

import SwiftUI

@main
struct TimeShiftyApp: App {
    /// 应用委托适配器
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        /// 使用 Settings 场景，但不显示任何内容
        /// 实际窗口由 AppDelegate 管理
        Settings {
            EmptyView()
        }
    }
}
