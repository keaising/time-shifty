//
//  CityDatabase.swift
//  time-shifty
//
//  城市和时区数据库（本地，无需网络）
//

import Foundation

/// 城市信息
struct City: Identifiable, Hashable, Codable {
    let id = UUID()
    let englishName: String          // 英文名称（如：Beijing）
    let chineseName: String          // 中文名称（如：北京）
    let timeZoneIdentifier: String   // 时区标识符（如：Asia/Shanghai）
    let aliases: [String]            // 别名（如：["Peking"]）
    let country: String              // 国家/地区（英文）
    let countryZh: String            // 国家/地区（中文）
    let isPopular: Bool              // 是否为热门城市
    
    enum CodingKeys: String, CodingKey {
        case englishName, chineseName, timeZoneIdentifier, aliases, country, countryZh, isPopular
    }
    
    /// 根据当前语言显示的名称
    var displayName: String {
        let language = LocalizationManager.shared.effectiveLanguage
        return language == .chinese ? chineseName : englishName
    }
    
    /// 根据当前语言显示的国家
    var displayCountry: String {
        let language = LocalizationManager.shared.effectiveLanguage
        return language == .chinese ? countryZh : country
    }
    
    /// 时区对象
    var timeZone: TimeZone? {
        TimeZone(identifier: timeZoneIdentifier)
    }
    
    /// UTC 偏移量描述
    var utcOffset: String {
        guard let tz = timeZone else { return "" }
        let seconds = tz.secondsFromGMT()
        let hours = seconds / 3600
        let minutes = abs(seconds % 3600) / 60
        
        if minutes == 0 {
            return String(format: "UTC%+d", hours)
        } else {
            return String(format: "UTC%+d:%02d", hours, minutes)
        }
    }
    
    /// 用于搜索的文本
    var searchText: String {
        ([englishName, chineseName, timeZoneIdentifier, country, countryZh] + aliases).joined(separator: " ").lowercased()
    }
}

/// 城市数据库管理器
class CityDatabase {
    static let shared = CityDatabase()
    
    private var allCities: [City] = []
    
    private init() {
        loadCities()
    }
    
    /// 加载城市数据
    private func loadCities() {
        // 热门城市（硬编码，覆盖全球主要城市）
        allCities = [
            // 亚洲 - 东亚
            City(englishName: "Beijing", chineseName: "北京", timeZoneIdentifier: "Asia/Shanghai", 
                 aliases: ["Peking"], country: "China", countryZh: "中国", isPopular: true),
            City(englishName: "Shanghai", chineseName: "上海", timeZoneIdentifier: "Asia/Shanghai",
                 aliases: [], country: "China", countryZh: "中国", isPopular: true),
            City(englishName: "Hong Kong", chineseName: "香港", timeZoneIdentifier: "Asia/Hong_Kong",
                 aliases: ["HK"], country: "China", countryZh: "中国", isPopular: true),
            City(englishName: "Taipei", chineseName: "台北", timeZoneIdentifier: "Asia/Taipei",
                 aliases: [], country: "Taiwan", countryZh: "中国台湾", isPopular: true),
            City(englishName: "Tokyo", chineseName: "东京", timeZoneIdentifier: "Asia/Tokyo",
                 aliases: [], country: "Japan", countryZh: "日本", isPopular: true),
            City(englishName: "Seoul", chineseName: "首尔", timeZoneIdentifier: "Asia/Seoul",
                 aliases: ["서울"], country: "South Korea", countryZh: "韩国", isPopular: true),
            
            // 亚洲 - 东南亚
            City(englishName: "Singapore", chineseName: "新加坡", timeZoneIdentifier: "Asia/Singapore",
                 aliases: [], country: "Singapore", countryZh: "新加坡", isPopular: true),
            City(englishName: "Bangkok", chineseName: "曼谷", timeZoneIdentifier: "Asia/Bangkok",
                 aliases: [], country: "Thailand", countryZh: "泰国", isPopular: true),
            City(englishName: "Ho Chi Minh", chineseName: "胡志明市", timeZoneIdentifier: "Asia/Ho_Chi_Minh",
                 aliases: ["Saigon"], country: "Vietnam", countryZh: "越南", isPopular: false),
            City(englishName: "Jakarta", chineseName: "雅加达", timeZoneIdentifier: "Asia/Jakarta",
                 aliases: [], country: "Indonesia", countryZh: "印度尼西亚", isPopular: false),
            City(englishName: "Manila", chineseName: "马尼拉", timeZoneIdentifier: "Asia/Manila",
                 aliases: [], country: "Philippines", countryZh: "菲律宾", isPopular: false),
            
            // 亚洲 - 南亚
            City(englishName: "Mumbai", chineseName: "孟买", timeZoneIdentifier: "Asia/Kolkata",
                 aliases: ["Bombay"], country: "India", countryZh: "印度", isPopular: false),
            City(englishName: "New Delhi", chineseName: "新德里", timeZoneIdentifier: "Asia/Kolkata",
                 aliases: ["Delhi"], country: "India", countryZh: "印度", isPopular: true),
            
            // 亚洲 - 西亚
            City(englishName: "Dubai", chineseName: "迪拜", timeZoneIdentifier: "Asia/Dubai",
                 aliases: [], country: "UAE", countryZh: "阿联酋", isPopular: true),
            City(englishName: "Tel Aviv", chineseName: "特拉维夫", timeZoneIdentifier: "Asia/Jerusalem",
                 aliases: ["Jerusalem"], country: "Israel", countryZh: "以色列", isPopular: false),
            City(englishName: "Istanbul", chineseName: "伊斯坦布尔", timeZoneIdentifier: "Europe/Istanbul",
                 aliases: [], country: "Turkey", countryZh: "土耳其", isPopular: false),
            
            // 欧洲 - 西欧
            City(englishName: "London", chineseName: "伦敦", timeZoneIdentifier: "Europe/London",
                 aliases: [], country: "UK", countryZh: "英国", isPopular: true),
            City(englishName: "Paris", chineseName: "巴黎", timeZoneIdentifier: "Europe/Paris",
                 aliases: [], country: "France", countryZh: "法国", isPopular: true),
            City(englishName: "Berlin", chineseName: "柏林", timeZoneIdentifier: "Europe/Berlin",
                 aliases: [], country: "Germany", countryZh: "德国", isPopular: true),
            City(englishName: "Amsterdam", chineseName: "阿姆斯特丹", timeZoneIdentifier: "Europe/Amsterdam",
                 aliases: [], country: "Netherlands", countryZh: "荷兰", isPopular: false),
            City(englishName: "Brussels", chineseName: "布鲁塞尔", timeZoneIdentifier: "Europe/Brussels",
                 aliases: [], country: "Belgium", countryZh: "比利时", isPopular: false),
            
            // 欧洲 - 南欧
            City(englishName: "Rome", chineseName: "罗马", timeZoneIdentifier: "Europe/Rome",
                 aliases: [], country: "Italy", countryZh: "意大利", isPopular: true),
            City(englishName: "Madrid", chineseName: "马德里", timeZoneIdentifier: "Europe/Madrid",
                 aliases: [], country: "Spain", countryZh: "西班牙", isPopular: false),
            City(englishName: "Barcelona", chineseName: "巴塞罗那", timeZoneIdentifier: "Europe/Madrid",
                 aliases: [], country: "Spain", countryZh: "西班牙", isPopular: false),
            
            // 欧洲 - 北欧
            City(englishName: "Stockholm", chineseName: "斯德哥尔摩", timeZoneIdentifier: "Europe/Stockholm",
                 aliases: [], country: "Sweden", countryZh: "瑞典", isPopular: false),
            City(englishName: "Copenhagen", chineseName: "哥本哈根", timeZoneIdentifier: "Europe/Copenhagen",
                 aliases: [], country: "Denmark", countryZh: "丹麦", isPopular: false),
            
            // 欧洲 - 东欧
            City(englishName: "Moscow", chineseName: "莫斯科", timeZoneIdentifier: "Europe/Moscow",
                 aliases: [], country: "Russia", countryZh: "俄罗斯", isPopular: true),
            City(englishName: "Zurich", chineseName: "苏黎世", timeZoneIdentifier: "Europe/Zurich",
                 aliases: [], country: "Switzerland", countryZh: "瑞士", isPopular: false),
            
            // 美洲 - 北美
            City(englishName: "New York", chineseName: "纽约", timeZoneIdentifier: "America/New_York",
                 aliases: ["NYC"], country: "USA", countryZh: "美国", isPopular: true),
            City(englishName: "Los Angeles", chineseName: "洛杉矶", timeZoneIdentifier: "America/Los_Angeles",
                 aliases: ["LA"], country: "USA", countryZh: "美国", isPopular: true),
            City(englishName: "Chicago", chineseName: "芝加哥", timeZoneIdentifier: "America/Chicago",
                 aliases: [], country: "USA", countryZh: "美国", isPopular: true),
            City(englishName: "San Francisco", chineseName: "旧金山", timeZoneIdentifier: "America/Los_Angeles",
                 aliases: ["SF"], country: "USA", countryZh: "美国", isPopular: true),
            City(englishName: "Seattle", chineseName: "西雅图", timeZoneIdentifier: "America/Los_Angeles",
                 aliases: [], country: "USA", countryZh: "美国", isPopular: false),
            City(englishName: "Boston", chineseName: "波士顿", timeZoneIdentifier: "America/New_York",
                 aliases: [], country: "USA", countryZh: "美国", isPopular: false),
            City(englishName: "Washington DC", chineseName: "华盛顿", timeZoneIdentifier: "America/New_York",
                 aliases: ["DC"], country: "USA", countryZh: "美国", isPopular: false),
            City(englishName: "Toronto", chineseName: "多伦多", timeZoneIdentifier: "America/Toronto",
                 aliases: [], country: "Canada", countryZh: "加拿大", isPopular: true),
            City(englishName: "Vancouver", chineseName: "温哥华", timeZoneIdentifier: "America/Vancouver",
                 aliases: [], country: "Canada", countryZh: "加拿大", isPopular: false),
            
            // 美洲 - 中南美
            City(englishName: "Mexico City", chineseName: "墨西哥城", timeZoneIdentifier: "America/Mexico_City",
                 aliases: [], country: "Mexico", countryZh: "墨西哥", isPopular: false),
            City(englishName: "Sao Paulo", chineseName: "圣保罗", timeZoneIdentifier: "America/Sao_Paulo",
                 aliases: [], country: "Brazil", countryZh: "巴西", isPopular: false),
            City(englishName: "Buenos Aires", chineseName: "布宜诺斯艾利斯", timeZoneIdentifier: "America/Argentina/Buenos_Aires",
                 aliases: [], country: "Argentina", countryZh: "阿根廷", isPopular: false),
            
            // 大洋洲
            City(englishName: "Sydney", chineseName: "悉尼", timeZoneIdentifier: "Australia/Sydney",
                 aliases: [], country: "Australia", countryZh: "澳大利亚", isPopular: true),
            City(englishName: "Melbourne", chineseName: "墨尔本", timeZoneIdentifier: "Australia/Melbourne",
                 aliases: [], country: "Australia", countryZh: "澳大利亚", isPopular: false),
            City(englishName: "Auckland", chineseName: "奥克兰", timeZoneIdentifier: "Pacific/Auckland",
                 aliases: [], country: "New Zealand", countryZh: "新西兰", isPopular: false),
            
            // 非洲
            City(englishName: "Cairo", chineseName: "开罗", timeZoneIdentifier: "Africa/Cairo",
                 aliases: [], country: "Egypt", countryZh: "埃及", isPopular: false),
            City(englishName: "Johannesburg", chineseName: "约翰内斯堡", timeZoneIdentifier: "Africa/Johannesburg",
                 aliases: [], country: "South Africa", countryZh: "南非", isPopular: false),
        ]
        
        Logger.success("城市数据库已加载，共 \(allCities.count) 个城市", category: "CityDB")
    }
    
    /// 获取所有城市
    func getAllCities() -> [City] {
        allCities
    }
    
    /// 获取热门城市
    func getPopularCities() -> [City] {
        allCities.filter { $0.isPopular }
    }
    
    /// 搜索城市
    func searchCities(_ query: String) -> [City] {
        guard !query.isEmpty else { return getPopularCities() }
        
        let lowercasedQuery = query.lowercased()
        return allCities.filter { city in
            city.searchText.contains(lowercasedQuery)
        }.sorted { city1, city2 in
            // 优先显示热门城市
            if city1.isPopular != city2.isPopular {
                return city1.isPopular
            }
            return city1.displayName < city2.displayName
        }
    }
    
    /// 按拼音首字母分组（用于中文城市）
    func getCitiesGroupedByLetter() -> [(letter: String, cities: [City])] {
        let grouped = Dictionary(grouping: allCities) { city -> String in
            String(city.displayName.prefix(1))
        }
        return grouped.sorted { $0.key < $1.key }.map { (letter: $0.key, cities: $0.value) }
    }
    
    /// 获取所有城市并按时区从早到晚排序（UTC-12 到 UTC+14）
    func getAllCitiesSortedByTimeZone() -> [City] {
        return allCities.sorted { city1, city2 in
            guard let tz1 = city1.timeZone, let tz2 = city2.timeZone else {
                return false
            }
            let offset1 = tz1.secondsFromGMT()
            let offset2 = tz2.secondsFromGMT()
            
            // 如果时区相同，按城市名称排序
            if offset1 == offset2 {
                return city1.displayName < city2.displayName
            }
            
            // 按 UTC 偏移量从小到大排序
            return offset1 < offset2
        }
    }
}
