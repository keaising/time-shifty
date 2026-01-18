//
//  SettingsView.swift
//  time-shifty
//
//  设置界面
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var settings = AppSettings.shared
    @ObservedObject var localization = LocalizationManager.shared
    @State private var showAddCity = false
    @State private var selectedCity: City?
    
    var body: some View {
        TabView {
            // 城市和时区设置
            citiesTab
                .tabItem {
                    Label(localization.string(.settingsTabCities), systemImage: "globe")
                }
            
            // 显示设置
            displayTab
                .tabItem {
                    Label(localization.string(.settingsTabDisplay), systemImage: "display")
                }
        }
        .frame(width: 600, height: 520)
    }
    
    // MARK: - 城市设置标签
    
    private var citiesTab: some View {
        VStack(alignment: .leading, spacing: 20) {
            // 标题和描述
            VStack(alignment: .leading, spacing: 6) {
                Text(localization.string(.citiesTitle))
                    .font(.system(.title2, design: .rounded, weight: .bold))
                Text(localization.effectiveLanguage == .chinese ? 
                    "管理你的时区城市列表，拖动可调整顺序" : 
                    "Manage your time zone cities, drag to reorder")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            
            // 城市列表
            if settings.cities.isEmpty {
                emptyStateView
                    .padding(.horizontal, 20)
            } else {
                List {
                    ForEach(settings.cities) { city in
                        cityCardView(city: city)
                            .listRowInsets(EdgeInsets(top: 6, leading: 20, bottom: 6, trailing: 20))
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                    }
                    .onMove(perform: settings.moveCity)
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .frame(height: cityListHeight)
            }
            
            Divider()
            
            // 底部操作按钮
            HStack(spacing: 12) {
                Button(action: { showAddCity.toggle() }) {
                    HStack(spacing: 6) {
                        Image(systemName: "plus.circle.fill")
                        Text(localization.string(.citiesAdd))
                    }
                    .font(.system(.body, design: .rounded, weight: .medium))
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Color.accentColor)
                    .cornerRadius(8)
                }
                .buttonStyle(.plain)
                
                Spacer()
                
                Button(action: { settings.resetToDefaults() }) {
                    HStack(spacing: 6) {
                        Image(systemName: "arrow.counterclockwise")
                        Text(localization.string(.citiesResetToDefault))
                    }
                    .font(.system(.body, design: .rounded))
                    .foregroundColor(.orange)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
        .sheet(isPresented: $showAddCity) {
            addCitySheet
        }
    }
    
    // MARK: - 城市卡片视图
    
    private func cityCardView(city: CityTimeZone) -> some View {
        HStack(spacing: 16) {
            // 拖动图标
            ZStack {
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.secondary.opacity(0.08))
                    .frame(width: 28, height: 28)
                Image(systemName: "line.3.horizontal")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.secondary.opacity(0.6))
            }
            
            // 城市图标
            ZStack {
                Circle()
                    .fill(Color.accentColor.opacity(0.15))
                    .frame(width: 44, height: 44)
                Image(systemName: "building.2.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.accentColor)
            }
            
            // 城市信息
            VStack(alignment: .leading, spacing: 4) {
                Text(city.localizedCityName)  // 使用本地化的城市名
                    .font(.system(.body, design: .rounded, weight: .semibold))
                    .foregroundColor(.primary)
                
                HStack(spacing: 8) {
                    HStack(spacing: 4) {
                        Image(systemName: "clock.fill")
                            .font(.system(size: 11))
                        Text(currentTime(for: city.timeZoneIdentifier))
                            .font(.system(.caption, design: .monospaced))
                    }
                    .foregroundColor(.secondary)
                    
                    Circle()
                        .fill(Color.secondary.opacity(0.3))
                        .frame(width: 3, height: 3)
                    
                    Text(city.timeZoneIdentifier.split(separator: "/").last.map(String.init) ?? city.timeZoneIdentifier)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // 删除按钮
            Button(action: {
                if let index = settings.cities.firstIndex(where: { $0.id == city.id }) {
                    settings.cities.remove(at: index)
                }
            }) {
                ZStack {
                    Circle()
                        .fill(Color.red.opacity(0.1))
                        .frame(width: 32, height: 32)
                    Image(systemName: "trash.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.red)
                }
            }
            .buttonStyle(.plain)
            .help(localization.effectiveLanguage == .chinese ? "删除此城市" : "Remove this city")
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(NSColor.controlBackgroundColor))
                .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(Color.primary.opacity(0.06), lineWidth: 1)
        )
    }
    
    // MARK: - 空状态视图
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "globe.americas.fill")
                .font(.system(size: 48))
                .foregroundColor(.secondary.opacity(0.5))
            
            Text(localization.effectiveLanguage == .chinese ? 
                "还没有添加城市" : 
                "No cities added yet")
                .font(.system(.title3, design: .rounded, weight: .semibold))
                .foregroundColor(.secondary)
            
            Text(localization.effectiveLanguage == .chinese ? 
                "点击下方按钮添加你的第一个时区城市" : 
                "Click the button below to add your first time zone city")
                .font(.subheadline)
                .foregroundColor(.secondary.opacity(0.8))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }
    
    // MARK: - 获取当前时间
    
    private func currentTime(for timeZoneIdentifier: String) -> String {
        guard let timeZone = TimeZone(identifier: timeZoneIdentifier) else {
            return "--:--"
        }
        let formatter = DateFormatter()
        formatter.timeZone = timeZone
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: Date())
    }
    
    // MARK: - 显示设置标签
    
    private var displayTab: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // 标题
                VStack(alignment: .leading, spacing: 6) {
                    Text(localization.string(.displayTimeFormat))
                        .font(.system(.title2, design: .rounded, weight: .bold))
                    Text(localization.effectiveLanguage == .chinese ? 
                        "自定义时间显示格式和界面语言" : 
                        "Customize time display format and interface language")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                // 时间格式设置
                VStack(alignment: .leading, spacing: 16) {
                    HStack(spacing: 8) {
                        Image(systemName: "clock.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.accentColor)
                        Text(localization.string(.displayTimeFormat))
                            .font(.system(.headline, design: .rounded))
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(TimeFormat.allCases) { format in
                            Button(action: {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    settings.timeFormat = format
                                }
                            }) {
                                HStack(spacing: 12) {
                                    Image(systemName: settings.timeFormat == format ? "checkmark.circle.fill" : "circle")
                                        .font(.system(size: 18))
                                        .foregroundColor(settings.timeFormat == format ? .accentColor : .secondary.opacity(0.3))
                                    
                                    Text(format.displayName)
                                        .font(.system(.body, design: .rounded))
                                        .foregroundColor(.primary)
                                    
                                    Spacer()
                                }
                                .padding(12)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(settings.timeFormat == format ? Color.accentColor.opacity(0.1) : Color.clear)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .strokeBorder(
                                            settings.timeFormat == format ? Color.accentColor.opacity(0.3) : Color.primary.opacity(0.06),
                                            lineWidth: 1.5
                                        )
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    
                    // 自定义格式输入
                    if settings.timeFormat == .custom {
                        VStack(alignment: .leading, spacing: 12) {
                            TextField(localization.string(.displayCustomFormatPlaceholder), text: $settings.customFormatString)
                                .textFieldStyle(.plain)
                                .font(.system(.body, design: .monospaced, weight: .medium))
                                .padding(12)
                                .background(Color(NSColor.textBackgroundColor))
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .strokeBorder(Color.primary.opacity(0.1), lineWidth: 1)
                                )
                            
                            // 格式示例
                            VStack(alignment: .leading, spacing: 8) {
                                Text(localization.string(.displayCustomFormatExamples))
                                    .font(.system(.caption, design: .rounded, weight: .semibold))
                                    .foregroundColor(.secondary)
                                
                                VStack(alignment: .leading, spacing: 6) {
                                    formatExample("HH:mm:ss", localization.string(.formatExample24h))
                                    formatExample("h:mm:ss a", localization.string(.formatExample12h))
                                    formatExample("yyyy-MM-dd HH:mm", localization.string(.formatExampleDateTime))
                                    formatExample("MM/dd HH:mm", localization.string(.formatExampleShortDate))
                                    formatExample("HH:mm", localization.string(.formatExampleTimeOnly))
                                }
                            }
                            .padding(12)
                            .background(Color(NSColor.controlBackgroundColor).opacity(0.5))
                            .cornerRadius(8)
                            
                            // 实时预览
                            if !settings.customFormatString.isEmpty {
                                HStack(spacing: 12) {
                                    Image(systemName: "eye.fill")
                                        .font(.system(size: 14))
                                        .foregroundColor(.accentColor)
                                    Text(localization.string(.displayCustomFormatPreview))
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    Text(formatPreview)
                                        .font(.system(.body, design: .monospaced, weight: .bold))
                                        .foregroundColor(.accentColor)
                                    Spacer()
                                }
                                .padding(12)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.accentColor.opacity(0.1))
                                )
                            }
                        }
                        .transition(.opacity.combined(with: .move(edge: .top)))
                    }
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(NSColor.controlBackgroundColor))
                        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(Color.primary.opacity(0.06), lineWidth: 1)
                )
                
                // 屏幕选择
                VStack(alignment: .leading, spacing: 16) {
                    HStack(spacing: 8) {
                        Image(systemName: "display")
                            .font(.system(size: 16))
                            .foregroundColor(.accentColor)
                        Text(localization.string(.displayScreen))
                            .font(.system(.headline, design: .rounded))
                    }
                    
                    Picker("", selection: $settings.preferredScreenIndex) {
                        Text(localization.string(.displayScreenMain)).tag(-1)
                        ForEach(0..<NSScreen.screens.count, id: \.self) { index in
                            Text("\(localization.string(.displayScreenExternal)) \(index + 1)").tag(index)
                        }
                    }
                    .pickerStyle(.menu)
                    
                    HStack(spacing: 8) {
                        Image(systemName: "info.circle.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary.opacity(0.7))
                        Text(NSScreen.screens.count > 1 ? 
                            (localization.effectiveLanguage == .chinese ? 
                                "当前有 \(NSScreen.screens.count) 个屏幕" : 
                                "Currently \(NSScreen.screens.count) screens") :
                            (localization.effectiveLanguage == .chinese ? 
                                "当前只有一个屏幕" : 
                                "Currently one screen"))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(NSColor.controlBackgroundColor))
                        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(Color.primary.opacity(0.06), lineWidth: 1)
                )
                
                // 语言设置
                VStack(alignment: .leading, spacing: 16) {
                    HStack(spacing: 8) {
                        Image(systemName: "globe.americas.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.accentColor)
                        Text(localization.string(.displayLanguage))
                            .font(.system(.headline, design: .rounded))
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(AppLanguage.allCases) { language in
                            Button(action: {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    localization.currentLanguage = language
                                }
                            }) {
                                HStack(spacing: 12) {
                                    Image(systemName: localization.currentLanguage == language ? "checkmark.circle.fill" : "circle")
                                        .font(.system(size: 18))
                                        .foregroundColor(localization.currentLanguage == language ? .accentColor : .secondary.opacity(0.3))
                                    
                                    Text(language.displayName)
                                        .font(.system(.body, design: .rounded))
                                        .foregroundColor(.primary)
                                    
                                    Spacer()
                                }
                                .padding(12)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(localization.currentLanguage == language ? Color.accentColor.opacity(0.1) : Color.clear)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .strokeBorder(
                                            localization.currentLanguage == language ? Color.accentColor.opacity(0.3) : Color.primary.opacity(0.06),
                                            lineWidth: 1.5
                                        )
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(NSColor.controlBackgroundColor))
                        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(Color.primary.opacity(0.06), lineWidth: 1)
                )
                
                // 重置按钮
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        settings.resetToDefaults()
                    }
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "arrow.counterclockwise")
                        Text(localization.string(.displayRestoreDefaults))
                    }
                    .font(.system(.body, design: .rounded, weight: .medium))
                    .foregroundColor(.orange)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(10)
                }
                .buttonStyle(.plain)
            }
            .padding(20)
        }
    }
    
    // MARK: - 添加城市弹窗
    
    private var addCitySheet: some View {
        VStack(spacing: 0) {
            // 顶部标题栏
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(localization.string(.citiesAddTitle))
                        .font(.system(.title2, design: .rounded, weight: .bold))
                    Text(localization.string(.citiesAddDescription))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button(action: {
                    showAddCity = false
                    resetAddCityForm()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.secondary.opacity(0.5))
                }
                .buttonStyle(.plain)
            }
            .padding(24)
            .background(Color(NSColor.controlBackgroundColor))
            
            Divider()
            
            // 内容区域
            ScrollView {
                VStack(spacing: 24) {
                    // 城市选择
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 8) {
                            Image(systemName: "globe.americas.fill")
                                .font(.system(size: 16))
                                .foregroundColor(.accentColor)
                            Text(localization.string(.citiesSelectCity))
                                .font(.system(.headline, design: .rounded))
                        }
                        
                        Picker("", selection: $selectedCity) {
                            Text(localization.string(.citiesSelectPlaceholder)).tag(nil as City?)
                            
                            ForEach(sortedCities) { city in
                                // 格式化为 "UTC+8    Tokyo (Japan)"
                                let paddedOffset = city.utcOffset.padding(toLength: 10, withPad: " ", startingAt: 0)
                                Text("\(paddedOffset) \(city.displayName) (\(city.displayCountry))")
                                    .tag(city as City?)
                            }
                        }
                        .pickerStyle(.menu)
                        .frame(maxWidth: .infinity)
                    }
                    
                    // 显示已选城市的详细信息
                    if let city = selectedCity {
                        VStack(spacing: 16) {
                            // 城市预览卡片
                            VStack(spacing: 16) {
                                // 城市图标和名称
                                HStack(spacing: 16) {
                                    ZStack {
                                        Circle()
                                            .fill(
                                                LinearGradient(
                                                    colors: [Color.accentColor.opacity(0.8), Color.accentColor],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                )
                                            )
                                            .frame(width: 56, height: 56)
                                        Image(systemName: "building.2.fill")
                                            .font(.system(size: 28))
                                            .foregroundColor(.white)
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 6) {
                                        Text(city.displayName)
                                            .font(.system(.title3, design: .rounded, weight: .bold))
                                        Text(city.displayCountry)
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                }
                                
                                Divider()
                                
                                // 详细信息
                                VStack(spacing: 12) {
                                    infoRow(
                                        icon: "clock.fill",
                                        label: localization.string(.citiesTimeZone),
                                        value: city.timeZoneIdentifier
                                    )
                                    
                                    infoRow(
                                        icon: "globe.fill",
                                        label: localization.string(.citiesOffset),
                                        value: city.utcOffset
                                    )
                                    
                                    infoRow(
                                        icon: "timer",
                                        label: localization.effectiveLanguage == .chinese ? "当前时间" : "Current Time",
                                        value: currentTime(for: city.timeZoneIdentifier)
                                    )
                                }
                            }
                            .padding(20)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color(NSColor.controlBackgroundColor))
                                    .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 2)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .strokeBorder(Color.primary.opacity(0.08), lineWidth: 1)
                            )
                        }
                        .transition(.opacity.combined(with: .scale(scale: 0.95)))
                    }
                    
                    Spacer(minLength: 20)
                }
                .padding(24)
            }
            
            Divider()
            
            // 底部按钮
            HStack(spacing: 12) {
                Button(action: {
                    showAddCity = false
                    resetAddCityForm()
                }) {
                    Text(localization.string(.cancel))
                        .font(.system(.body, design: .rounded, weight: .medium))
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(Color(NSColor.controlBackgroundColor))
                        .cornerRadius(8)
                }
                .buttonStyle(.plain)
                .keyboardShortcut(.cancelAction)
                
                Button(action: {
                    addCity()
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "plus.circle.fill")
                        Text(localization.string(.add))
                    }
                    .font(.system(.body, design: .rounded, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(selectedCity == nil ? Color.gray.opacity(0.3) : Color.accentColor)
                    .cornerRadius(8)
                }
                .buttonStyle(.plain)
                .keyboardShortcut(.defaultAction)
                .disabled(selectedCity == nil)
            }
            .padding(24)
            .background(Color(NSColor.windowBackgroundColor))
        }
        .frame(width: 520, height: 550)
    }
    
    // MARK: - 信息行视图
    
    private func infoRow(icon: String, label: String, value: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(.accentColor)
                .frame(width: 24)
            
            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .frame(width: 80, alignment: .leading)
            
            Text(value)
                .font(.system(.body, design: .monospaced, weight: .medium))
                .foregroundColor(.primary)
            
            Spacer()
        }
    }
    
    /// 按时区排序的城市列表
    private var sortedCities: [City] {
        return CityDatabase.shared.getAllCitiesSortedByTimeZone()
    }
    
    /// 计算城市列表的高度
    /// 每个城市卡片高度约 88px (包含上下间距)
    /// 最多显示4个城市不滚动，超过4个则固定高度显示滚动条
    private var cityListHeight: CGFloat {
        let cityCardHeight: CGFloat = 88 // 每个城市卡片的高度
        let maxVisibleCities: Int = 4    // 最多显示4个不滚动
        let cityCount = settings.cities.count
        
        if cityCount <= maxVisibleCities {
            // 少于等于4个城市，按实际高度显示
            return CGFloat(cityCount) * cityCardHeight
        } else {
            // 超过4个城市，固定高度显示滚动条
            return CGFloat(maxVisibleCities) * cityCardHeight
        }
    }
    
    // MARK: - 辅助方法
    
    private func addCity() {
        guard let selected = selectedCity else { return }
        settings.addCity(name: selected.displayName, timeZoneIdentifier: selected.timeZoneIdentifier)
        showAddCity = false
        resetAddCityForm()
    }
    
    private func resetAddCityForm() {
        selectedCity = nil
    }
    
    /// 格式示例视图
    private func formatExample(_ format: String, _ description: String) -> some View {
        HStack {
            Text("•")
            Text(format)
                .font(.system(.caption, design: .monospaced))
            Text("→")
                .foregroundColor(.secondary)
            Text(description)
        }
    }
    
    /// 格式预览
    private var formatPreview: String {
        let formatter = DateFormatter()
        formatter.dateFormat = settings.customFormatString
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone.current
        return formatter.string(from: Date())
    }
}

#Preview {
    SettingsView()
}
