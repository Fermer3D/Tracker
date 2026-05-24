//
//  Protocols.swift
//  Tracker
//
//  Created by Данил Третьяченко on 24.05.2026.
//

import Foundation

protocol NewHabitViewControllerDelegate: AnyObject {
    func didCreateTracker(_ tracker: Tracker)
}

//protocol ScheduleViewControllerDelegate: AnyObject {
//    func didUpdateSchedule(_ selectedDays: [WeekDay])
//}
