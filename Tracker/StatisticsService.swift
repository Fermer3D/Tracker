import Foundation
import UIKit

protocol StatisticsServiceProtocol {
    func calculateStatistics() -> [StatisticModel]
}

struct StatisticModel {
    let value: Int
    let title: String
}

final class StatisticsService: StatisticsServiceProtocol {
    
    func calculateStatistics() -> [StatisticModel] {
        let trackerStore = TrackerStore.shared
        let recordStore = TrackerRecordStore.shared
        
        let allRecords = (try? recordStore.fetchRecords()) ?? []
        let allTrackers = (try? trackerStore.fetchAllTrackers()) ?? []
        
        guard !allRecords.isEmpty else {
            return [
                StatisticModel(value: 0, title: "Лучший период"),
                StatisticModel(value: 0, title: "Идеальные дни"),
                StatisticModel(value: 0, title: "Трекеров завершено"),
                StatisticModel(value: 0, title: "Среднее значение")
            ]
        }
        
        let completedCount = allRecords.count
        let perfectDays = calculatePerfectDays(records: allRecords, trackers: allTrackers)
        let bestStreak = calculateBestStreak(records: allRecords)
        let averageValue = calculateAverage(records: allRecords)
        
        return [
            StatisticModel(value: bestStreak, title: "Лучший период"),
            StatisticModel(value: perfectDays, title: "Идеальные дни"),
            StatisticModel(value: completedCount, title: "Трекеров завершено"),
            StatisticModel(value: averageValue, title: "Среднее значение")
        ]
    }
    
    // MARK: - Расчет идеальных дней
    private func calculatePerfectDays(records: [TrackerRecord], trackers: [Tracker]) -> Int {
        let recordsByDay = Dictionary(grouping: records) { Calendar.current.startOfDay(for: $0.date) }
        var perfectDaysCount = 0
        
        for (date, dayRecords) in recordsByDay {
            // Внимание: В Swift Calendar.component(.weekday) возвращает 1 для воскресенья, 7 для субботы.
            // Убедитесь, что ваш WeekDay enum (rawValue) соответствует этой логике.
            let dayOfWeek = Calendar.current.component(.weekday, from: date)
            guard let weekDay = WeekDay(rawValue: dayOfWeek) else { continue }
            
            let plannedTrackers = trackers.filter { tracker in
                let schedule = tracker.schedule ?? []
                return schedule.contains(weekDay)
            }
            
            let completedIDs = Set(dayRecords.map { $0.trackerId })
            let plannedIDs = Set(plannedTrackers.map { $0.id })
            
            if !plannedIDs.isEmpty && plannedIDs.isSubset(of: completedIDs) {
                perfectDaysCount += 1
            }
        }
        return perfectDaysCount
    }
    
    // MARK: - Расчет лучшего периода (Streak)
    private func calculateBestStreak(records: [TrackerRecord]) -> Int {
        let uniqueDates = Set(records.map { Calendar.current.startOfDay(for: $0.date) }).sorted()
        
        guard !uniqueDates.isEmpty else { return 0 }
        
        var maxStreak = 0
        var currentStreak = 1
        
        for i in 1..<uniqueDates.count {
            let prevDate = uniqueDates[i-1]
            let currDate = uniqueDates[i]
            
            if let diff = Calendar.current.dateComponents([.day], from: prevDate, to: currDate).day, diff == 1 {
                currentStreak += 1
            } else {
                maxStreak = max(maxStreak, currentStreak)
                currentStreak = 1
            }
        }
        
        return max(maxStreak, currentStreak)
    }
    
    // MARK: - Расчет среднего значения
    private func calculateAverage(records: [TrackerRecord]) -> Int {
        let uniqueDays = Set(records.map { Calendar.current.startOfDay(for: $0.date) })
        let uniqueDaysCount = uniqueDays.count
        
        guard uniqueDaysCount > 0 else { return 0 }
        
        // Считаем среднее: общее кол-во записей / кол-во дней, когда были выполнены трекеры
        let average = Double(records.count) / Double(uniqueDaysCount)
        return Int(round(average))
    }
}
