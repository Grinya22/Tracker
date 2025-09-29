import UIKit
import CoreData
import YandexMobileMetrica
import YandexMobileMetricaCrashes

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        UIColorValueTransformer.register()
        ScheduleValueTransformer.register()
        
        if let configuration = YMMYandexMetricaConfiguration(apiKey: "a9533351-d3a3-4f5d-95fc-a5ed31896c0e") {
            configuration.crashReporting = true
            YMMYandexMetrica.activate(with: configuration)
        }

        return true
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
            CoreDataStack.shared.saveContext()
            print("AppDelegate: Сохранение при background")
        }

        func applicationWillTerminate(_ application: UIApplication) {
            CoreDataStack.shared.saveContext()
            print("AppDelegate: Сохранение при termination")
        }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        
        let container = NSPersistentContainer(name: "Tracker")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}

