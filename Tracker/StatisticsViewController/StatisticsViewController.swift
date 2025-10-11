import UIKit

// MARK: - StatisticItem

struct StatisticItem {
    let value: Int
    let title: String
}

// MARK: - StatisticsViewController

final class StatisticsViewController: UIViewController {
    
    // MARK: - Properties
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .dynamicBackground
        
        title = L10n.Title.statisticsScreen
        
        setUpStatisticsView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        loadStatistics()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //AnalyticsService.shared.logEvent(.open(screen: "Statistics"))
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        //AnalyticsService.shared.logEvent(.close(screen: "Statistics"))
    }
    
    // MARK: - Setup UI
    func setUpStatisticsView() {
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
        
        
    }
    
    // MARK: - Helper Methods
    
    func loadStatistics() {
        let recordStore = TrackerRecordStore()
        
        do {
            let idealDays = try recordStore.idealDaysCount()
            let bestPeriod = try recordStore.bestPeriod()
            let average = try recordStore.averageCompletedPerDay()
            let completedTotal = try recordStore.completedTrackersCount()
            let completedToday = try recordStore.completedTrackersCount(for: Date())
            
            let items: [StatisticItem] = [
                StatisticItem(value: bestPeriod, title: "Лучший период"),
                StatisticItem(value: idealDays, title: "Идеальные дни"),
                StatisticItem(value: completedToday, title: "Трекеров завершено сегодня"),
                StatisticItem(value: completedTotal, title: "Трекеров завершено всего"),
                StatisticItem(value: average, title: "Среднее значение")
            ]
            
            for item in items {
                let card = StatisticCardView(value: item.value, title: item.title)
                stackView.addArrangedSubview(card)
            }
            
        } catch {
            print("Ошибка статистики: \(error)")
        }
    }
}
