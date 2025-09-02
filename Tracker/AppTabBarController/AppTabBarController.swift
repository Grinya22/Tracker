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
        
        trackerNavigationController.tabBarItem = UITabBarItem(title: L10n.TabBar.trackers, image: UIImage(named: "TrakerTabBarItem"), tag: 0)
        statisticNavigationController.tabBarItem = UITabBarItem(title: L10n.TabBar.statistics, image: UIImage(named: "StatisticsTabBarItem"), tag: 1)
        
        viewControllers = [trackerNavigationController, statisticNavigationController]
        
        tabBar.tintColor = .ypBlueTracker
        tabBar.unselectedItemTintColor = .ypGray
        tabBar.backgroundColor = .ypWhite
    }

}

