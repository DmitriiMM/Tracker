import UIKit

final class OnboardingViewController: UIPageViewController {
    private lazy var pages: [UIViewController] = [firstVC, secondVC]
    
    private lazy var firstVC = UIViewController()
    private lazy var secondVC = UIViewController()
    
    private lazy var onboardingFirstImageView = UIImageView(image: UIImage(named: "1"))
    private lazy var onboardingSecondImageView = UIImageView(image: UIImage(named: "2"))
    
    private lazy var onboardingFirstLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.appFont(.bold, withSize: 32)
        label.text = "Отслеживайте только то, что хотите"
        label.textColor = .black
        label.numberOfLines = 3
        label.textAlignment = .center
        
        return label
    }()
    
    private lazy var onboardingSecondLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.appFont(.bold, withSize: 32)
        label.text = "Даже если это не литры воды и йога"
        label.textColor = .black
        label.numberOfLines = 3
        label.textAlignment = .center
        
        return label
    }()
    
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
        
        button.addTarget(self, action: #selector(onboardingButtonTapped), for: .touchUpInside)
        
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        delegate = self
        dataSource = self
        
        if let first = pages.first {
            setViewControllers([first], direction: .forward, animated: true, completion: nil)
        }
        
        addSubviews()
        addConstraints()
    }
    
    @objc
    func onboardingButtonTapped() {
        let tabBarVC = TabBarController()
        tabBarVC.modalPresentationStyle = .fullScreen
        present(tabBarVC, animated: true)
    }
    
    private func addSubviews() {
        firstVC.view.addSubview(onboardingFirstImageView)
        firstVC.view.addSubview(onboardingFirstLabel)
        secondVC.view.addSubview(onboardingSecondImageView)
        secondVC.view.addSubview(onboardingSecondLabel)
        view.addSubview(pageControl)
        view.addSubview(onboardingButton)
    }
    
    private func addConstraints() {
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        onboardingButton.translatesAutoresizingMaskIntoConstraints = false
        onboardingFirstLabel.translatesAutoresizingMaskIntoConstraints = false
        onboardingFirstImageView.translatesAutoresizingMaskIntoConstraints = false
        onboardingSecondLabel.translatesAutoresizingMaskIntoConstraints = false
        onboardingSecondImageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            pageControl.bottomAnchor.constraint(equalTo: onboardingButton.topAnchor, constant: -24),
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            onboardingButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -84),
            onboardingButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            onboardingButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            onboardingButton.heightAnchor.constraint(equalToConstant: 60),
            
            onboardingFirstImageView.leadingAnchor.constraint(equalTo: firstVC.view.leadingAnchor),
            onboardingFirstImageView.trailingAnchor.constraint(equalTo: firstVC.view.trailingAnchor),
            onboardingFirstImageView.topAnchor.constraint(equalTo: firstVC.view.topAnchor),
            onboardingFirstImageView.bottomAnchor.constraint(equalTo: firstVC.view.bottomAnchor),
            
            onboardingFirstLabel.topAnchor.constraint(equalTo: firstVC.view.centerYAnchor, constant: 26),
            onboardingFirstLabel.leadingAnchor.constraint(equalTo: firstVC.view.leadingAnchor, constant: 16),
            onboardingFirstLabel.trailingAnchor.constraint(equalTo: firstVC.view.trailingAnchor, constant: -16),
            
            onboardingSecondImageView.leadingAnchor.constraint(equalTo: secondVC.view.leadingAnchor),
            onboardingSecondImageView.trailingAnchor.constraint(equalTo: secondVC.view.trailingAnchor),
            onboardingSecondImageView.topAnchor.constraint(equalTo: secondVC.view.topAnchor),
            onboardingSecondImageView.bottomAnchor.constraint(equalTo: secondVC.view.bottomAnchor),
            
            onboardingSecondLabel.topAnchor.constraint(equalTo: secondVC.view.centerYAnchor, constant: 26),
            onboardingSecondLabel.leadingAnchor.constraint(equalTo: secondVC.view.leadingAnchor, constant: 16),
            onboardingSecondLabel.trailingAnchor.constraint(equalTo: secondVC.view.trailingAnchor, constant: -16),
        ])
    }
}

// MARK: - UIPageViewControllerDelegate
extension OnboardingViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        if let currentViewController = pageViewController.viewControllers?.first,
           let currentIndex = pages.firstIndex(of: currentViewController) {
            pageControl.currentPage = currentIndex
        }
    }
}

// MARK: - UIPageViewControllerDataSource
extension OnboardingViewController: UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = pages.firstIndex(of: viewController) else {
            return nil
        }
        
        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex >= 0 else {
            return nil
        }
        
        return pages[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = pages.firstIndex(of: viewController) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        
        guard nextIndex < pages.count else {
            return nil
        }
        
        return pages[nextIndex]
    }
}

