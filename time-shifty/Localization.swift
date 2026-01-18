//
//  Localization.swift
//  time-shifty
//
//  多语言支持
//

import Foundation
import SwiftUI
import Combine

/// 支持的语言
enum AppLanguage: String, CaseIterable, Identifiable {
    case system = "system"
    case english = "en"
    case chinese = "zh-Hans"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .system: return "System / 跟随系统"
        case .english: return "English"
        case .chinese: return "简体中文"
        }
    }
    
    /// 获取系统语言
    static var systemLanguage: AppLanguage {
        let preferredLanguage = Locale.preferredLanguages.first ?? "en"
        if preferredLanguage.hasPrefix("zh") {
            return .chinese
        } else {
            return .english
        }
    }
}

/// 本地化管理器
class LocalizationManager: ObservableObject {
    static let shared = LocalizationManager()
    
    private let defaults = UserDefaults.standard
    private let languageKey = "appLanguage"
    
    @Published var currentLanguage: AppLanguage {
        didSet {
            defaults.set(currentLanguage.rawValue, forKey: languageKey)
            objectWillChange.send()
            Logger.info("语言已切换: \(currentLanguage.displayName)", category: "Localization")
        }
    }
    
    /// 实际使用的语言（处理 system 选项）
    var effectiveLanguage: AppLanguage {
        currentLanguage == .system ? AppLanguage.systemLanguage : currentLanguage
    }
    
    private init() {
        if let savedLanguage = defaults.string(forKey: languageKey),
           let language = AppLanguage(rawValue: savedLanguage) {
            self.currentLanguage = language
        } else {
            self.currentLanguage = .system
        }
    }
    
    /// 获取本地化字符串
    func string(_ key: LocalizedStringKey) -> String {
        return L10n.string(key, language: effectiveLanguage)
    }
}

/// 本地化字符串键
enum LocalizedStringKey: String {
    // 通用
    case appName = "app_name"
    case ok = "ok"
    case cancel = "cancel"
    case add = "add"
    case delete = "delete"
    case save = "save"
    case reset = "reset"
    
    // 菜单栏
    case menuSettings = "menu_settings"
    case menuQuit = "menu_quit"
    case menuShow = "menu_show"
    case menuHide = "menu_hide"
    
    // 设置窗口
    case settingsTitle = "settings_title"
    case settingsTabCities = "settings_tab_cities"
    case settingsTabDisplay = "settings_tab_display"
    
    // 城市设置
    case citiesTitle = "cities_title"
    case citiesAdd = "cities_add"
    case citiesDelete = "cities_delete"
    case citiesResetToDefault = "cities_reset_to_default"
    case citiesAddTitle = "cities_add_title"
    case citiesAddDescription = "cities_add_description"
    case citiesSelectCity = "cities_select_city"
    case citiesSelectPlaceholder = "cities_select_placeholder"
    case citiesSelectedCity = "cities_selected_city"
    case citiesTimeZone = "cities_time_zone"
    case citiesOffset = "cities_offset"
    
    // 显示设置
    case displayTitle = "display_title"
    case displayTimeFormat = "display_time_format"
    case displayFormat24h = "display_format_24h"
    case displayFormat12h = "display_format_12h"
    case displayFormatShort = "display_format_short"
    case displayFormatCustom = "display_format_custom"
    case displayCustomFormatPlaceholder = "display_custom_format_placeholder"
    case displayCustomFormatExamples = "display_custom_format_examples"
    case displayCustomFormatPreview = "display_custom_format_preview"
    case displayScreen = "display_screen"
    case displayScreenMain = "display_screen_main"
    case displayScreenExternal = "display_screen_external"
    case displayLanguage = "display_language"
    case displayRestoreDefaults = "display_restore_defaults"
    
    // 时间格式示例
    case formatExample24h = "format_example_24h"
    case formatExample12h = "format_example_12h"
    case formatExampleDateTime = "format_example_datetime"
    case formatExampleShortDate = "format_example_short_date"
    case formatExampleTimeOnly = "format_example_time_only"
}

/// 本地化字符串表
struct L10n {
    /// 中文字符串
    private static let zhHans: [LocalizedStringKey: String] = [
        // 通用
        .appName: "Time Shifty",
        .ok: "确定",
        .cancel: "取消",
        .add: "添加",
        .delete: "删除",
        .save: "保存",
        .reset: "重置",
        
        // 菜单栏
        .menuSettings: "设置...",
        .menuQuit: "退出",
        .menuShow: "显示",
        .menuHide: "隐藏",
        
        // 设置窗口
        .settingsTitle: "Time Shifty - 设置",
        .settingsTabCities: "城市",
        .settingsTabDisplay: "显示",
        
        // 城市设置
        .citiesTitle: "城市和时区",
        .citiesAdd: "添加城市",
        .citiesDelete: "删除",
        .citiesResetToDefault: "重置为默认",
        .citiesAddTitle: "添加城市",
        .citiesAddDescription: "城市按时区从早到晚排列（UTC-12 到 UTC+14）",
        .citiesSelectCity: "选择城市：",
        .citiesSelectPlaceholder: "请选择...",
        .citiesSelectedCity: "城市：",
        .citiesTimeZone: "时区：",
        .citiesOffset: "偏移：",
        
        // 显示设置
        .displayTitle: "显示设置",
        .displayTimeFormat: "时间格式",
        .displayFormat24h: "24 小时制 (14:30:00)",
        .displayFormat12h: "12 小时制 (2:30:00 PM)",
        .displayFormatShort: "24 小时制 - 简短 (14:30)",
        .displayFormatCustom: "自定义格式",
        .displayCustomFormatPlaceholder: "格式字符串",
        .displayCustomFormatExamples: "示例：",
        .displayCustomFormatPreview: "预览：",
        .displayScreen: "显示屏幕",
        .displayScreenMain: "主屏幕",
        .displayScreenExternal: "屏幕",
        .displayLanguage: "语言",
        .displayRestoreDefaults: "恢复默认设置",
        
        // 时间格式示例
        .formatExample24h: "14:30:00 (24小时)",
        .formatExample12h: "2:30:00 PM (12小时)",
        .formatExampleDateTime: "2026-01-15 14:30",
        .formatExampleShortDate: "01/15 14:30",
        .formatExampleTimeOnly: "14:30 (仅时分)",
    ]
    
    /// 英文字符串
    private static let en: [LocalizedStringKey: String] = [
        // 通用
        .appName: "Time Shifty",
        .ok: "OK",
        .cancel: "Cancel",
        .add: "Add",
        .delete: "Delete",
        .save: "Save",
        .reset: "Reset",
        
        // 菜单栏
        .menuSettings: "Settings...",
        .menuQuit: "Quit",
        .menuShow: "Show",
        .menuHide: "Hide",
        
        // 设置窗口
        .settingsTitle: "Time Shifty - Settings",
        .settingsTabCities: "Cities",
        .settingsTabDisplay: "Display",
        
        // 城市设置
        .citiesTitle: "Cities & Time Zones",
        .citiesAdd: "Add City",
        .citiesDelete: "Delete",
        .citiesResetToDefault: "Reset to Default",
        .citiesAddTitle: "Add City",
        .citiesAddDescription: "Cities sorted by time zone (UTC-12 to UTC+14)",
        .citiesSelectCity: "Select City:",
        .citiesSelectPlaceholder: "Please select...",
        .citiesSelectedCity: "City:",
        .citiesTimeZone: "Time Zone:",
        .citiesOffset: "Offset:",
        
        // 显示设置
        .displayTitle: "Display Settings",
        .displayTimeFormat: "Time Format",
        .displayFormat24h: "24-Hour (14:30:00)",
        .displayFormat12h: "12-Hour (2:30:00 PM)",
        .displayFormatShort: "24-Hour - Short (14:30)",
        .displayFormatCustom: "Custom Format",
        .displayCustomFormatPlaceholder: "Format String",
        .displayCustomFormatExamples: "Examples:",
        .displayCustomFormatPreview: "Preview:",
        .displayScreen: "Display Screen",
        .displayScreenMain: "Main Screen",
        .displayScreenExternal: "Screen",
        .displayLanguage: "Language",
        .displayRestoreDefaults: "Restore Defaults",
        
        // 时间格式示例
        .formatExample24h: "14:30:00 (24-hour)",
        .formatExample12h: "2:30:00 PM (12-hour)",
        .formatExampleDateTime: "2026-01-15 14:30",
        .formatExampleShortDate: "01/15 14:30",
        .formatExampleTimeOnly: "14:30 (time only)",
    ]
    
    /// 获取本地化字符串
    static func string(_ key: LocalizedStringKey, language: AppLanguage) -> String {
        let table = language == .chinese ? zhHans : en
        return table[key] ?? key.rawValue
    }
}
