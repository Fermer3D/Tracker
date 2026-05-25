import Foundation
import AppMetricaCore

final class AnalyticsService {
    static let shared = AnalyticsService()
    
    private init() {}
    
    // Типы событий согласно ТЗ
    enum Event: String {
        case open, close, click
    }
    
    // Экраны
    enum Screen: String {
        case main = "Main"
    }
    
    // Элементы (item)
    enum Item: String {
        case addTrack = "add_track"
        case track
        case filter
        case edit
        case delete
    }
    
    func report(event: Event, screen: Screen, item: Item? = nil) {
        var params: [String: Any] = [
            "screen": screen.rawValue
        ]
        
        if let item = item {
            params["item"] = item.rawValue
        }
        
        // Используем обновленный синтаксис: name: вместо позиционного аргумента
        AppMetrica.reportEvent(name: event.rawValue, parameters: params) { error in
            print("❌ REPORT ERROR: \(error.localizedDescription)")
        }
    }
}
