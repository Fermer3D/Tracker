//
//  FilterOption.swift
//  Tracker
//
//  Created by Данил Третьяченко on 24.05.2026.
//

import Foundation

enum FilterOption: Int, CaseIterable {
    case all = 0
    case today = 1
    case completed = 2
    case notCompleted = 3
    
    var title: String {
        switch self {
        case .all: return "Все трекеры"
        case .today: return "Трекеры на сегодня"
        case .completed: return "Завершённые"
        case .notCompleted: return "Незавершённые"
        }
    }
}
