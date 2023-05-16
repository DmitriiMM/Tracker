import UIKit

enum Pages: CaseIterable {
    case pageZero
    case pageOne
    
    var title: String {
        switch self {
        case .pageZero:
            return "Отслеживайте только то, что хотите"
        case .pageOne:
            return "Даже если это не литры воды и йога"
        }
    }
    
    var index: Int {
        switch self {
        case .pageZero:
            return 0
        case .pageOne:
            return 1
        }
    }
}

final class OnboardingViewController: UIPageViewController {
    private var pages: [Pages] = Pages.allCases
    
    private lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.numberOfPages = pages.count
        pageControl.currentPage = 0
        pageControl.currentPageIndicatorTintColor = .black
        pageControl.pageIndicatorTintColor = .systemGray
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        
        return pageControl
    }()
    
    private lazy var onboardingButton: UIButton = {
        let button = UIButton()
        button.setTitle("Вот это технологии!", for: .normal)
        button.titleLabel?.textColor = .white
        button.titleLabel?.font = UIFont.appFont(.medium, withSize: 16)
        button.tintColor = .white
        button.backgroundColor = .black
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        
        button.addTarget(self, action: #selector(onboardingButtonTapped), for: .touchUpInside)
        
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addSubviews()
        addConstraints()
        setupPageController()
    }
    
    @objc
    func onboardingButtonTapped() {
        let tabBarVC = TabBarController()
        tabBarVC.modalPresentationStyle = .fullScreen
        present(tabBarVC, animated: true)
    }
    
    private func setupPageController() {
        dataSource = self
        delegate = self
        let initialVC = PageViewController(with: pages[0])
        setViewControllers([initialVC], direction: .forward, animated: true, completion: nil)
    }
    
    private func addSubviews() {
        view.addSubview(pageControl)
        view.addSubview(onboardingButton)
    }
    
    private func addConstraints() {
        NSLayoutConstraint.activate([
            pageControl.bottomAnchor.constraint(equalTo: onboardingButton.topAnchor, constant: -24),
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            onboardingButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -84),
            onboardingButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            onboardingButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            onboardingButton.heightAnchor.constraint(equalToConstant: 60),
        ])
    }
}


// MARK: - UIPageViewControllerDelegate
extension OnboardingViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if let currentViewController = pageViewController.viewControllers?.first as? PageViewController {
            pageControl.currentPage = currentViewController.page.index
        }
    }
}

// MARK: - UIPageViewControllerDataSource
extension OnboardingViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let currentVC = viewController as? PageViewController else { return nil }
        var index = currentVC.page.index
        if index == 0 {
            return nil
        }
        
        index -= 1
        let vc = PageViewController(with: pages[index])
        
        return vc
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let currentVC = viewController as? PageViewController else { return nil }
        var index = currentVC.page.index
        if index >= self.pages.count - 1 {
            return nil
        }
        
        index += 1
        let vc = PageViewController(with: pages[index])
        
        return vc
    }
}
