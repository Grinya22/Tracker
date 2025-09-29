import Foundation
import YandexMobileMetrica
import YandexMobileMetricaCrashes

enum AnalyticsEvent {
    case open(screen: String)
    case close(screen: String)
    case click(screen: String, item: String)
}

final class AnalyticsService {
    static let shared = AnalyticsService()
    
    func logEvent(_ event: AnalyticsEvent) {
        var parameters: [AnyHashable: Any] = [:]
        
        switch event {
        case .open(let screen):
            parameters["event"] = "open"
            parameters["screen"] = screen
        case .close(let screen):
            parameters["event"] = "close"
            parameters["screen"] = screen
        case .click(let screen, let item):
            parameters["event"] = "click"
            parameters["screen"] = screen
            parameters["item"] = item
        }
        
        YMMYandexMetrica.reportEvent("ui_event", parameters: parameters) { error in
            print("AppMetrica error: \(error.localizedDescription)")
        }
        print("Analytics event sent: \(parameters)")
    }
}
