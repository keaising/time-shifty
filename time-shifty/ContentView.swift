import SwiftUI
import Combine

struct ContentView: View {
    // MARK: - 属性
    
    /// 鼠标悬停回调
    var onHoverAction: () -> Void
    
    /// 应用设置
    @ObservedObject var settings = AppSettings.shared
    
    /// 本地化管理器（用于监听语言变化）
    @ObservedObject var localization = LocalizationManager.shared
    
    /// 存储城市时间的字典（键是城市ID）
    @State private var times: [UUID: String] = [:]
    
    /// 每秒更新定时器
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            // 背景感应层（防止鼠标穿透）
            Color.white.opacity(0.001)

            // 背景色层
            RoundedRectangle(cornerRadius: AppConfig.cornerRadius)
                .fill(Color.accentColor.opacity(0.12))
            
            // 毛玻璃背景
            RoundedRectangle(cornerRadius: AppConfig.cornerRadius)
                .fill(.regularMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: AppConfig.cornerRadius)
                        .stroke(.white.opacity(0.3), lineWidth: 1.5)
                )
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 2)
            
            // 时钟列表
            timeListView
        }
        .frame(
            width: AppConfig.windowWidth,
            height: AppConfig.windowHeight(cityCount: settings.cities.count)
        )
        .contentShape(Rectangle())
        .onHover { isHovering in
            if isHovering {
                onHoverAction()
            }
        }
        .onReceive(timer) { _ in
            updateTimes()
        }
        .onAppear {
            updateTimes()
        }
    }
    
    // MARK: - 视图组件
    
    /// 时钟列表视图
    private var timeListView: some View {
        VStack(alignment: .leading, spacing: AppConfig.contentSpacing) {
            ForEach(settings.cities) { city in
                TimeRow(
                    city: city.localizedCityName,  // 使用本地化的城市名
                    time: times[city.id] ?? "--:--:--"
                )
            }
        }
        .padding(.horizontal, 20)  // 左右边距
        .padding(.vertical, 0)  // 整个列表容器的上下边距设为0
    }
    
    // MARK: - 辅助方法
    
    /// 更新所有城市的时间
    private func updateTimes() {
        var newTimes: [UUID: String] = [:]
        let formatter = DateFormatter()
        formatter.dateFormat = settings.effectiveTimeFormat
        formatter.locale = Locale(identifier: "en_US_POSIX")
        
        for city in settings.cities {
            if let timeZone = city.timeZone {
                formatter.timeZone = timeZone
                newTimes[city.id] = formatter.string(from: Date())
            } else {
                newTimes[city.id] = "无效时区"
            }
        }
        
        times = newTimes
    }
}

// 时间行子组件
struct TimeRow: View {
    var city: String
    var time: String
    
    var body: some View {
        HStack {
            Text(city)
                .font(.system(.title3, design: .monospaced, weight: .regular))
                .foregroundColor(.primary)
            Spacer()
            Text(time)
                .font(.system(.title3, design: .monospaced, weight: .regular))
                .foregroundColor(.primary)
        }
    }
}

// 预览代码（可选，方便在 Xcode 右侧查看）
#Preview {
    ContentView(onHoverAction: {})
}
