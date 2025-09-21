import UIKit

// MARK: - AppTabBarController

final class AppTabBarController: UITabBarController {

    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpTabBar()
    }
    
    // MARK: - Setup UI
    
    private func setUpTabBar() {
        let trackerViewController = TrackersViewController()
        let statisticViewController = StatisticsViewController()
        
        let trackerNavigationController = UINavigationController(rootViewController: trackerViewController)
        let statisticNavigationController = UINavigationController(rootViewController: statisticViewController)
        
        trackerNavigationController.navigationBar.prefersLargeTitles = true
        statisticNavigationController.navigationBar.prefersLargeTitles = true
        
        configureNavigationBar(trackerNavigationController.navigationBar)
        configureNavigationBar(statisticNavigationController.navigationBar)
        
        trackerNavigationController.tabBarItem = UITabBarItem(
            title: L10n.TabBar.trackers,
            image: UIImage(named: "TrakerTabBarItem"),
            tag: 0
        )
        statisticNavigationController.tabBarItem = UITabBarItem(
            title: L10n.TabBar.statistics,
            image: UIImage(named: "StatisticsTabBarItem"),
            tag: 1
        )
        
        viewControllers = [trackerNavigationController, statisticNavigationController]
        
        tabBar.tintColor = .ypBlueTracker
        tabBar.unselectedItemTintColor = .ypGray
        tabBar.backgroundColor = .dynamicBackground
        
        tabBar.shadowImage = UIImage()
        tabBar.backgroundImage = UIImage()
    }
    
    // MARK: - NavigationBar Appearance Helper
    
    private func configureNavigationBar(_ navigationBar: UINavigationBar) {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .dynamicBackground
        appearance.titleTextAttributes = [.foregroundColor: UIColor.dynamicTitleColor]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.dynamicTitleColor]
        appearance.shadowColor = nil
        
        navigationBar.standardAppearance = appearance
        navigationBar.scrollEdgeAppearance = appearance
        navigationBar.compactAppearance = appearance
    }
}
