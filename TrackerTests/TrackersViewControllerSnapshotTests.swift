import XCTest
import SnapshotTesting
@testable import Tracker

// РАСКОММЕНТИРУЙТЕ следующую строку только для ЗАПИСИ (первый запуск):
// SnapshotTesting.isRecording = true

class TrackersViewControllerSnapshotTests: XCTestCase {
    
    let deviceConfig = ViewImageConfig.iPhone13Pro
    
    // Тест для светлой темы
    func testTrackersViewControllerLight() {
        let vc = TrackersViewController()
        applyAppearance(for: vc, style: .light)
        
        assertSnapshot(
            matching: vc,
            as: .image(on: deviceConfig, traits: .init(userInterfaceStyle: .light))
        )
    }
    
    // Тест для тёмной темы
    func testTrackersViewControllerDark() {
        let vc = TrackersViewController()
        applyAppearance(for: vc, style: .dark)
        
        assertSnapshot(
            matching: vc,
            as: .image(on: deviceConfig, traits: .init(userInterfaceStyle: .dark))
        )
    }
    
    // Вспомогательный метод для принудительной настройки стиля
    private func applyAppearance(for vc: UIViewController, style: UIUserInterfaceStyle) {
        vc.overrideUserInterfaceStyle = style
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .ypBg
        
        // Оборачиваем в навигационный контроллер для корректного отображения Bar
        let nav = UINavigationController(rootViewController: vc)
        nav.navigationBar.standardAppearance = appearance
        nav.navigationBar.scrollEdgeAppearance = appearance
    }
}
