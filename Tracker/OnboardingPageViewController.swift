import UIKit

final class OnboardingPageViewController: UIPageViewController {
    
    // MARK: - Properties
    private var pages: [UIViewController] = []
    
    // MARK: - Visual Elements
    // ИСПРАВЛЕНО: PageControl должен быть возвращен
    private lazy var pageControl: UIPageControl = {
        let control = UIPageControl()
        control.translatesAutoresizingMaskIntoConstraints = false
        // ИСПРАВЛЕНО: Чёрный активный, серый неактивный (как на фото 2)
        control.currentPageIndicatorTintColor = .black
        control.pageIndicatorTintColor = .lightGray
        return control
    }()
    
    // MARK: - Initializers
    init() {
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPages()
        setupPageControl() // ИСПРАВЛЕНО: Вызов настройки точек
    }
    
    // MARK: - Setup
    private func setupPages() {
        let firstPage = OnboardingViewController(
            imageName: "Onboarding1",
            text: "Отслеживайте только то, что хотите",
            buttonTitle: "Вот это технологии!"
        )
        firstPage.delegate = self
        
        let secondPage = OnboardingViewController(
            imageName: "Onboarding2",
            text: "Даже если это не литры воды и йога",
            buttonTitle: "Вот это технологии!"
        )
        secondPage.delegate = self
        
        pages = [firstPage, secondPage]
        
        if let first = pages.first {
            setViewControllers([first], direction: .forward, animated: true, completion: nil)
        }
        
        self.dataSource = self
        self.delegate = self
    }
    
    private func setupPageControl() {
        view.addSubview(pageControl)
        pageControl.numberOfPages = pages.count
        pageControl.currentPage = 0
        
        NSLayoutConstraint.activate([
            // ИСПРАВЛЕНО: Точки внизу по центру
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            // ИСПРАВЛЕНО: Точки над кнопкой (высота кнопки 60 + отступ 50 = 110, так что отступ -134 хороший)
            pageControl.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -134)
        ])
    }
}

// MARK: - UIPageViewControllerDataSource & Delegate
extension OnboardingPageViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let index = pages.firstIndex(of: viewController), index > 0 else { return nil }
        return pages[index - 1]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let index = pages.firstIndex(of: viewController), index < pages.count - 1 else { return nil }
        return pages[index + 1]
    }
    
    // ИСПРАВЛЕНО: Обновляем PageControl при пролистывании
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed,
           let currentVC = pageViewController.viewControllers?.first,
           let index = pages.firstIndex(of: currentVC) {
            pageControl.currentPage = index
        }
    }
}

// MARK: - OnboardingViewControllerDelegate
extension OnboardingPageViewController: OnboardingViewControllerDelegate {
    func onboardingButtonTapped() {
        // Записываем флаг, что пользователь видел онбординг
        UserDefaults.standard.set(true, forKey: "HasSeenOnboarding")
        
        // Переключаемся на TabBarController (через Shared Application)
        guard let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate else { return }
        let tabBarController = TabBarController() // твой класс ТабБара
        sceneDelegate.window?.rootViewController = tabBarController
    }
}
