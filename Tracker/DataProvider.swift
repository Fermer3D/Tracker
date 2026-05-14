//
//  Untitled.swift
//  Tracker
//
//  Created by Данил Третьяченко on 13.05.2026.
//

import CoreData

final class DataProvider {
    static let shared = DataProvider()
    
    // Название должно строго совпадать с названием твоего .xcdatamodeld файла
    private let persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "TrackerModel")
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                // В реальном приложении здесь должна быть обработка ошибки
                fatalError("Не удалось загрузить хранилище: \(error)")
            }
        }
        return container
    }()
    
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
}
