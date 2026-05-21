import UIKit

final class OnboardingPageViewController: UIPageViewController {
    
    // MARK: - Properties
    private var pages: [UIViewController] = []
    
    private lazy var pageControl: UIPageControl = {
        let control = UIPageControl()
        control.translatesAutoresizingMaskIntoConstraints = false
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
        setupPageControl()
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
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            // Точки ложатся ровно под текстом на высоту отступа кнопки
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
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed,
           let currentVC = pageViewController.viewControllers?.first,
           let index = pages.firstIndex(of: currentVC) {
            pageControl.currentPage = index
        }
    }
}

// MARK: - OnboardingViewControllerCustomDelegate
extension OnboardingPageViewController: OnboardingViewControllerCustomDelegate {
    func onboardingButtonTapped() {
        UserDefaults.standard.set(true, forKey: "HasSeenOnboarding")
        
        guard let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate else { return }
        let tabBarController = TabBarController() // Твой основной контроллер таббара
        sceneDelegate.window?.rootViewController = tabBarController
    }
}
