//
//  Settings.swift
//  time-shifty
//
//  应用设置模型和持久化
//

import Foundation
import AppKit
import Combine
import SwiftUI

/// 时间格式
enum TimeFormat: String, CaseIterable, Identifiable {
    case format24 = "HH:mm:ss"
    case format12 = "h:mm:ss a"
    case formatShort = "HH:mm"
    case custom = ""
    
    var id: String { rawValue }
    
    var displayName: String {
        let localization = LocalizationManager.shared
        switch self {
        case .format24: return localization.string(.displayFormat24h)
        case .format12: return localization.string(.displayFormat12h)
        case .formatShort: return localization.string(.displayFormatShort)
        case .custom: return localization.string(.displayFormatCustom)
        }
    }
}

/// 城市时区配置项
struct CityTimeZone: Identifiable, Codable, Equatable {
    let id: UUID
    var cityName: String
    var timeZoneIdentifier: String
    
    init(id: UUID = UUID(), cityName: String, timeZoneIdentifier: String) {
        self.id = id
        self.cityName = cityName
        self.timeZoneIdentifier = timeZoneIdentifier
    }
    
    var timeZone: TimeZone? {
        TimeZone(identifier: timeZoneIdentifier)
    }
    
    /// 获取本地化的城市名称（根据当前语言）
    var localizedCityName: String {
        // 尝试从数据库中查找对应的城市
        let allCities = CityDatabase.shared.getAllCities()
        if let city = allCities.first(where: { $0.timeZoneIdentifier == timeZoneIdentifier }) {
            return city.displayName  // 返回本地化名称
        }
        // 如果找不到，返回存储的名称
        return cityName
    }
}

/// 应用设置管理器
class AppSettings: ObservableObject {
    static let shared = AppSettings()
    
    private let defaults = UserDefaults.standard
    
    // MARK: - 设置键
    
    private enum Keys {
        static let cities = "cities"
        static let timeFormat = "timeFormat"
        static let customFormatString = "customFormatString"
        static let preferredScreenIndex = "preferredScreenIndex"
    }
    
    // MARK: - 发布的属性
    
    /// 城市列表
    @Published var cities: [CityTimeZone] {
        didSet {
            saveCities()
            Logger.info("城市列表已更新，共 \(cities.count) 个城市", category: "Settings")
        }
    }
    
    /// 时间格式
    @Published var timeFormat: TimeFormat {
        didSet {
            defaults.set(timeFormat.rawValue, forKey: Keys.timeFormat)
            Logger.info("时间格式已更新: \(timeFormat.displayName)", category: "Settings")
        }
    }
    
    /// 自定义时间格式字符串
    @Published var customFormatString: String {
        didSet {
            defaults.set(customFormatString, forKey: Keys.customFormatString)
            Logger.info("自定义格式已更新: \(customFormatString)", category: "Settings")
        }
    }
    
    /// 实际使用的时间格式字符串
    var effectiveTimeFormat: String {
        if timeFormat == .custom && !customFormatString.isEmpty {
            return customFormatString
        }
        return timeFormat.rawValue
    }
    
    /// 首选屏幕索引（-1 表示主屏幕）
    @Published var preferredScreenIndex: Int {
        didSet {
            defaults.set(preferredScreenIndex, forKey: Keys.preferredScreenIndex)
            Logger.info("首选屏幕已更新: \(preferredScreenIndex)", category: "Settings")
        }
    }
    
    // MARK: - 初始化
    
    private init() {
        // 加载城市列表
        self.cities = Self.loadCities()
        
        // 加载时间格式
        if let formatString = defaults.string(forKey: Keys.timeFormat),
           let format = TimeFormat(rawValue: formatString) {
            self.timeFormat = format
        } else {
            self.timeFormat = .format24
        }
        
        // 加载自定义格式字符串
        self.customFormatString = defaults.string(forKey: Keys.customFormatString) ?? "yyyy-MM-dd HH:mm:ss"
        
        // 加载首选屏幕
        self.preferredScreenIndex = defaults.integer(forKey: Keys.preferredScreenIndex)
        
        Logger.success("设置已加载", category: "Settings")
    }
    
    // MARK: - 城市管理
    
    /// 添加城市
    func addCity(name: String, timeZoneIdentifier: String) {
        let city = CityTimeZone(cityName: name, timeZoneIdentifier: timeZoneIdentifier)
        cities.append(city)
    }
    
    /// 删除城市
    func removeCity(at offsets: IndexSet) {
        cities.remove(atOffsets: offsets)
    }
    
    /// 移动城市
    func moveCity(from source: IndexSet, to destination: Int) {
        cities.move(fromOffsets: source, toOffset: destination)
    }
    
    // MARK: - 持久化
    
    /// 保存城市列表
    private func saveCities() {
        if let encoded = try? JSONEncoder().encode(cities) {
            defaults.set(encoded, forKey: Keys.cities)
        }
    }
    
    /// 加载城市列表
    private static func loadCities() -> [CityTimeZone] {
        guard let data = UserDefaults.standard.data(forKey: Keys.cities),
              let cities = try? JSONDecoder().decode([CityTimeZone].self, from: data) else {
            // 返回默认城市列表
            return [
                CityTimeZone(cityName: "Beijing", timeZoneIdentifier: "Asia/Shanghai"),
                CityTimeZone(cityName: "Tokyo", timeZoneIdentifier: "Asia/Tokyo"),
                CityTimeZone(cityName: "Los Angeles", timeZoneIdentifier: "America/Los_Angeles"),
                CityTimeZone(cityName: "London", timeZoneIdentifier: "Europe/London")
            ]
        }
        return cities
    }
    
    /// 重置为默认设置
    func resetToDefaults() {
        cities = Self.loadCities()
        timeFormat = .format24
        preferredScreenIndex = 0
        Logger.info("设置已重置为默认值", category: "Settings")
    }
    
    // MARK: - 屏幕管理
    
    /// 获取首选屏幕
    var preferredScreen: NSScreen? {
        let screens = NSScreen.screens
        if preferredScreenIndex < 0 || preferredScreenIndex >= screens.count {
            return NSScreen.main
        }
        return screens[preferredScreenIndex]
    }
}
