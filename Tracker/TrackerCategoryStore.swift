//
//  TrackerCategoryStore.swift
//  Tracker
//
//  Created by Данил Третьяченко on 13.05.2026.
//

import CoreData
import UIKit

final class TrackerCategoryStore: NSObject {
    private let context: NSManagedObjectContext

    // Инициализатор с контекстом из нашего DataProvider
    init(context: NSManagedObjectContext = DataProvider.shared.context) {
        self.context = context
    }

    // Метод для получения всех категорий из базы
    var categories: [TrackerCategoryCoreData] {
            // Вызываем fetchRequest() у самого класса сущности
            let request = TrackerCategoryCoreData.fetchRequest()
            
            do {
                return try context.fetch(request)
            } catch {
                print("Ошибка при чтении категорий: \(error)")
                return []
            }
        }

    // Метод для создания дефолтной категории (понадобится для первых тестов)
    func createCategory(title: String) throws {
        let categoryCoreData = TrackerCategoryCoreData(context: context)
        categoryCoreData.title = title
        try context.save()
    }
}
