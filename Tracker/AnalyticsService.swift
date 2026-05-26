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
        // Создаем параметры согласно ТЗ
        var params: [String: Any] = [
            "event": event.rawValue, // Добавлено для соответствия требованиям ТЗ
            "screen": screen.rawValue
        ]
        
        if let item = item {
            params["item"] = item.rawValue
        }
        
        // Дублирование в логи для отладки
        print("Analytics event: \(event.rawValue), params: \(params)")
        
        // Отправка в AppMetrica
        AppMetrica.reportEvent(name: event.rawValue, parameters: params) { error in
            print("❌ REPORT ERROR: \(error.localizedDescription)")
        }
    }
}
