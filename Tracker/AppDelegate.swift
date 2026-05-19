import UIKit
import CoreData // 1. Обязательно импортируем Core Data

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    // 2. Добавляем контейнер, который будет управлять нашей базой данных
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         ВАЖНО: Имя "Tracker" должно в точности (буква в букву, с учётом регистра)
         совпадать с названием твоего файла модели данных в проекте.
         Если у тебя файл называется, например, Model.xcdatamodeld, поменяй "Tracker" на "Model".
         */
        let container = NSPersistentContainer(name: "Tracker")
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Не удалось загрузить хранилище Core Data: \(error), \(error.userInfo)")
            }
        }
        return container
    }()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    }
}
