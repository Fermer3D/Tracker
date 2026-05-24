import UIKit
import CoreData
import AppMetricaCore

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    // MARK: - Core Data Stack
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "TrackerModel")
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Не удалось загрузить хранилище: \(error)")
            }
        }
        return container
    }()

    // MARK: - UIApplicationDelegate
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        setupAnalytics()
        setupAppearance()
        
        return true
    }

    // MARK: - Private Methods
    private func setupAppearance() {
        // Настройка NavigationBar
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithOpaqueBackground()
        navBarAppearance.backgroundColor = .ypBg
        
        // Используем .label (системный цвет), чтобы текст заголовка
        // автоматически менял цвет (черный в светлой, белый в темной)
        let titleAttributes = [NSAttributedString.Key.foregroundColor: UIColor.label]
        navBarAppearance.titleTextAttributes = titleAttributes
        navBarAppearance.largeTitleTextAttributes = titleAttributes
        
        UINavigationBar.appearance().standardAppearance = navBarAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navBarAppearance

        // Настройка TabBar
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        tabBarAppearance.backgroundColor = .ypBg
        
        UITabBar.appearance().standardAppearance = tabBarAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
        
        // ВАЖНО: Убираем принудительный tintColor для всей системы,
        // так как он может "перекрашивать" ваши кнопки в ChoiceViewController
        UITabBar.appearance().tintColor = .ypBlue
    }

    private func setupAnalytics() {
        let configuration = AppMetricaConfiguration(apiKey: "e7663f73-5192-4917-a06f-652303c20063")
        
        guard let configuration = configuration else {
            assertionFailure("Ошибка: Не удалось создать конфигурацию AppMetrica")
            return
        }
        
        AppMetrica.activate(with: configuration)
    }

    // MARK: - UISceneSession Lifecycle
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {}
    
    // MARK: - Core Data Saving support
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
