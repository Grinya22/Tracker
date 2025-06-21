import UIKit

final class OnboardingViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    // MARK: - Properties
    
    lazy var pages: [UIViewController] = {
        let blueOne = createPage(with: UIImage(named: "backgroundBlue")!, text: "Отслеживайте только \nто, что хотите", buttonText: "Вот это технологии!")

        let redOne = createPage(with: UIImage(named: "backgroundRed")!, text: "Даже если это \nне литры воды и йога", buttonText: "Вот это технологии!")

        return [blueOne, redOne]
    }()
        
    lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        
        pageControl.currentPage = 0
        pageControl.numberOfPages = pages.count
        
        pageControl.currentPageIndicatorTintColor = .ypBlack
        pageControl.pageIndicatorTintColor = .ypGray
        
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        return pageControl
    }()
    
    // MARK: - Initialization
    
    init() {
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .clear
        
        delegate = self
        dataSource = self
        
        if let first = pages.first {
            setViewControllers(
                [first],
                direction: .forward,
                animated: true,
                completion: nil
            )
        }
    
        setupPageControl()
    }
    
    // MARK: - Setup Methods
    
    private func setupPageControl() {
        view.addSubview(pageControl)
        NSLayoutConstraint.activate([
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pageControl.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -134)
        ])
    }
    
    private func createPage(with image: UIImage, text: String, buttonText: String) -> UIViewController {
        let page = UIViewController()
        page.view.backgroundColor = .clear

        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        page.view.addSubview(imageView)

        let label = UILabel()
        label.text = text
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = .ypBlack
        label.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        page.view.addSubview(label)

        let button = UIButton()
        button.setTitle(buttonText, for: .normal)
        button.setTitleColor(.ypWhite, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .ypBlack
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        page.view.addSubview(button)

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: page.view.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: page.view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: page.view.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: page.view.bottomAnchor),

            label.centerXAnchor.constraint(equalTo: page.view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: page.view.centerYAnchor, constant: 65),
            label.leadingAnchor.constraint(greaterThanOrEqualTo: page.view.leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(lessThanOrEqualTo: page.view.trailingAnchor, constant: -16),

            button.centerXAnchor.constraint(equalTo: page.view.centerXAnchor),
            button.bottomAnchor.constraint(equalTo: page.view.safeAreaLayoutGuide.bottomAnchor, constant: -60),
            button.leadingAnchor.constraint(equalTo: page.view.leadingAnchor, constant: 20),
            button.trailingAnchor.constraint(equalTo: page.view.trailingAnchor, constant: -20),
            button.heightAnchor.constraint(equalToConstant: 60)
        ])

        button.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)

        return page
    }
    
    @objc private func didTapButton() {
        UserDefaults.standard.set(true, forKey: "hasSeenOnboarding")
        
        let tabBarController = AppTabBarController()
        
        if let window = UIApplication.shared.windows.first {
            UIView.transition(
                with: window,
                duration: 0.5,
                options: .transitionCrossDissolve,
                animations: { window.rootViewController = tabBarController },
                completion: nil
            )
            
            window.makeKeyAndVisible()
        }
    }
    
    // MARK: - UIPageViewControllerDataSource
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = pages.firstIndex(of: viewController) else { return nil }
        
        let previousIndex = viewControllerIndex - 1
        
        return previousIndex >= 0 ? pages[previousIndex] : pages.last
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = pages.firstIndex(of: viewController) else { return nil }
        
        let nextIndex = viewControllerIndex + 1
        
        return nextIndex < pages.count ? pages[nextIndex] : pages.first
    }
    
    // MARK: - UIPageViewControllerDelegate
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        if let currentViewController = pageViewController.viewControllers?.first,
           let currentIndex = pages.firstIndex(of: currentViewController) {
            pageControl.currentPage = currentIndex
        }
    }
}
