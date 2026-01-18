//
//  Logger.swift
//  time-shifty
//
//  统一的日志管理工具
//

import Foundation

/// 日志工具类
enum Logger {
    /// 日志级别
    enum Level {
        case info    // 一般信息
        case success // 成功
        case warning // 警告
        case error   // 错误
        case debug   // 调试信息
        
        var emoji: String {
            switch self {
            case .info:    return "ℹ️"
            case .success: return "✅"
            case .warning: return "⚠️"
            case .error:   return "❌"
            case .debug:   return "🔍"
            }
        }
    }
    
    /// 记录日志
    static func log(_ message: String, level: Level = .info, category: String = "App") {
        guard AppConfig.verboseLogging else { return }
        print("\(level.emoji) [\(category)] \(message)")
    }
    
    /// 快捷方法
    static func info(_ message: String, category: String = "App") {
        log(message, level: .info, category: category)
    }
    
    static func success(_ message: String, category: String = "App") {
        log(message, level: .success, category: category)
    }
    
    static func warning(_ message: String, category: String = "App") {
        log(message, level: .warning, category: category)
    }
    
    static func error(_ message: String, category: String = "App") {
        log(message, level: .error, category: category)
    }
    
    static func debug(_ message: String, category: String = "App") {
        log(message, level: .debug, category: category)
    }
}
