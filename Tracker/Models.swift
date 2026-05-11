//
//  Models.swift
//  Tracker
//
//  Created by Данил Третьяченко on 12.05.2026.
//

import UIKit

// 1. Дни недели. Используем Int, чтобы легко сопоставлять с Calendar.current.component(.weekday, from: date)
enum WeekDay: Int, CaseIterable {
    case sunday = 1, monday, tuesday, wednesday, thursday, friday, saturday
    
    var russianName: String {
        switch self {
        case .monday: return "Понедельник"
        case .tuesday: return "Вторник"
        case .wednesday: return "Среда"
        case .thursday: return "Четверг"
        case .friday: return "Пятница"
        case .saturday: return "Суббота"
        case .sunday: return "Воскресенье"
        }
    }
}

// 2. Модель самого Трекера
struct Tracker {
    let id: UUID
    let name: String
    let color: UIColor
    let emoji: String
    let schedule: [WeekDay]? // Если nil — это "Нерегулярное событие"
}

// 3. Категория (например, "Спорт", "Здоровье")
struct TrackerCategory {
    let title: String
    let trackers: [Tracker]
}

// 4. Запись о том, что трекер был выполнен
struct TrackerRecord: Hashable{
    let trackerId: UUID
    let date: Date
}
