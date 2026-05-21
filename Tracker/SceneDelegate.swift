import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)
        
        // 1. Проверяем флаг в UserDefaults (строку удаления объекта полностью убрали)
        let hasSeenOnboarding = UserDefaults.standard.bool(forKey: "HasSeenOnboarding")
        
        // 2. Настраиваем правильную точку входа в приложение
        if hasSeenOnboarding {
            // Если уже видел — показываем главный экран с таббаром
            window.rootViewController = TabBarController()
        } else {
            // Если зашел впервые — показываем главный контейнер онбординга (UIPageViewController)
            window.rootViewController = OnboardingPageViewController()
        }
        
        self.window = window
        window.makeKeyAndVisible()
    }

    func sceneDidDisconnect(_ scene: UIScene) {}

    func sceneDidBecomeActive(_ scene: UIScene) {}

    func sceneWillResignActive(_ scene: UIScene) {}

    func sceneWillEnterForeground(_ scene: UIScene) {}

    func sceneDidEnterBackground(_ scene: UIScene) {}
}
