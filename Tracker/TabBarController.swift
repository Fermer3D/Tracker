import UIKit

final class TabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 1. Настройка внешнего вида (Appearance)
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        
        // Используем цвет фона из ваших Assets (тот же, что и у контроллеров)
        appearance.backgroundColor = UIColor(named: "YP Background") ?? .systemBackground
        
        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
        
        // 2. Настройка цветов иконок
        // Используем YP цвета, чтобы не было конфликтов с системным синим
        tabBar.tintColor = UIColor(named: "YP Blue") ?? .systemBlue
        tabBar.unselectedItemTintColor = .gray // Цвет неактивных иконок
        
        // 3. Инициализация контроллеров
        let trackersVC = UINavigationController(rootViewController: TrackersViewController())
        trackersVC.tabBarItem = UITabBarItem(
            title: NSLocalizedString("trackers_title", comment: ""),
            image: UIImage(systemName: "record.circle.fill"),
            tag: 0
        )
        
        let statsVC = UINavigationController(rootViewController: StatisticsViewController())
        statsVC.tabBarItem = UITabBarItem(
            title: NSLocalizedString("statistics_title", comment: ""),
            image: UIImage(systemName: "hare.fill"),
            tag: 1
        )
        
        viewControllers = [trackersVC, statsVC]
    }
}
