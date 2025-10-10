import UIKit

// MARK: - StatisticItem

struct StatisticItem {
    let value: Int
    let title: String
}

// MARK: - StatisticsViewController

final class StatisticsViewController: UIViewController {
    
    // MARK: - Properties
    
    private var descriptionLabel = UILabel()
    private var imageView = UIImageView()
    
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
        
        setUpImageView()
        
        setUpStatisticsView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        loadStatistics()
        
        updatePlaceholderVisibility()
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
    
    func setUpImageView() {
        imageView.image = UIImage(named: "StaticticsSectionMainImage")
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
        
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 80),
            imageView.heightAnchor.constraint(equalToConstant: 80)
        ])
        
        descriptionLabel.text = L10n.Empty.statistics
        descriptionLabel.textAlignment = .center
        descriptionLabel.textColor = .dynamicTitleColor
        descriptionLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(descriptionLabel)
        
        NSLayoutConstraint.activate([
            descriptionLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16)
        ])
    }
    
    func setUpStatisticsView() {
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
        
        
    }
    
    // MARK: - Helper Methods

    func updatePlaceholderVisibility() {
        let hasTrackers = !stackView.arrangedSubviews.isEmpty
        imageView.isHidden = hasTrackers
        descriptionLabel.isHidden = hasTrackers
    }
    
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
                StatisticItem(value: completedToday, title: "Трекеров завершено"),
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
