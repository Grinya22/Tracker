import UIKit

// MARK: - TrackersViewController

final class TrackersViewController: UIViewController {
    
    // MARK: - Properties
    
//    var categories: [TrackerCategory] = [] {
//        didSet {
//            updatePlaceholderVisibility()
//        }
//    }
    
    private var shouldFilterByDate = false // Флаг для фильтрации
    weak var trackerCreationDelegate: TrackerCreationDelegate?

    private let trackerView = TrackerCollectionView()

    private lazy var descriptionLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker(frame: .zero)
        datePicker.preferredDatePickerStyle = .compact
        datePicker.datePickerMode = .date
        datePicker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
        return datePicker
    }()

    private var imageView: UIImageView!
    
    private let trackerStore = TrackerStore()
    private let categoryStore = TrackerCategoryStore()
    private let recordStore = TrackerRecordStore()
    private var dataProvider: TrackerDataProviderProtocol?
    private var completedTrackers: [TrackerRecord] = []
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Загружаем категории из TrackerData
//        categories = TrackerData.getCategories()
//
//        // Тестовые трекеры
//        let calendar = Calendar.current
//        // Устанавливаем текущую дату с обнулением времени
//        let currentDate = calendar.startOfDay(for: Date()) // Обнуляем время
//        datePicker.date = currentDate
//
//        //shouldFilterByDate = true
        
        do {
            dataProvider = try TrackerDataProvider(trackerStore: trackerStore, categoryStore: categoryStore, recordStore: recordStore)
            dataProvider?.delegate = self
        } catch {
            print("Ошибка инициализации DataProvider: \(error)")
        }
        
        setupNavigationBar()
        setUpTrackersViewController()
        setUpTracker()
        
        // Применяем фильтрацию сразу после загрузки
        trackerView.collectionView.reloadData()
        
        updatePlaceholderVisibility()
    }
    
    // MARK: - Setup UI
    
    func setupNavigationBar() {
        view.backgroundColor = .ypWhite
        title = "Трекеры"

        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(named: "Plus"),
            style: .plain,
            target: self,
            action: #selector(plusTapped)
        )
        navigationItem.leftBarButtonItem?.tintColor = .ypBlack
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)

        // Добавляем поиск
        let searchController = UISearchController(searchResultsController: nil)
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Поиск"
        navigationItem.searchController = searchController
    }
    
    func setUpTrackersViewController() {
        trackerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(trackerView)

        NSLayoutConstraint.activate([
            trackerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            trackerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            trackerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            trackerView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        trackerView.setUpCollectionView()
        trackerView.collectionView.dataSource = self
        trackerView.collectionView.delegate = self

        trackerView.collectionView.register(TrackerCollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        trackerView.collectionView.register(SupplementaryView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "Header")
    }

    func setUpTracker() {
        imageView = UIImageView()
        imageView.image = UIImage(named: "TrakerSectionMainImage")
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)

        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 80),
            imageView.heightAnchor.constraint(equalToConstant: 80)
        ])

        descriptionLabel = UILabel()
        descriptionLabel.text = "Что будем отслеживать?"
        descriptionLabel.textAlignment = .center
        descriptionLabel.textColor = .ypBlack
        descriptionLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(descriptionLabel)

        NSLayoutConstraint.activate([
            descriptionLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
    }
    
    // MARK: - Helper Methods

    func updatePlaceholderVisibility() {
        guard let imageView = imageView, let dataProvider = dataProvider else { return }
        var hasTrackers = false
        
        for section in 0..<dataProvider.numberOfSections {
            if dataProvider.numberOfRowsInSection(section) > 0 {
                hasTrackers = true
                break
            }
        }
        
        imageView.isHidden = hasTrackers
        descriptionLabel.isHidden = hasTrackers
    }
    
    // MARK: - Actions
    
    @objc
    func plusTapped(_ sender: UITabBarItem) {
        let creatingTrackerVC = UINavigationController(rootViewController: CreatingTrackerViewController())
        if let creatingVC = creatingTrackerVC.viewControllers.first as? CreatingTrackerViewController {
            creatingVC.delegate = self
            print("Делегат установлен для CreatingHabitViewController")
        }
        
        creatingTrackerVC.modalPresentationStyle = .pageSheet
        creatingTrackerVC.modalTransitionStyle = .coverVertical
        present(creatingTrackerVC, animated: true)
    }

    @objc
    func datePickerValueChanged(_ sender: UIDatePicker) {
        let selectedDate = sender.date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        let formattedDate = dateFormatter.string(from: selectedDate)
        print("Выбранная дата: \(formattedDate)")

        shouldFilterByDate = true // Включаем фильтрацию
        trackerView.collectionView.reloadData()
        updatePlaceholderVisibility()
    }
}

// MARK: - UICollectionViewDataSource & UICollectionViewDelegateFlowLayout

extension TrackersViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    // MARK: DataSource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return filteredCategories().count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredCategories()[section].trackers.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? TrackerCollectionViewCell else {
            return UICollectionViewCell()
        }

        let filteredCategories = filteredCategories()
        let tracker = filteredCategories[indexPath.section].trackers[indexPath.item]
        let date = datePicker.date
        
        let isCompletedToday = completedTrackers.contains {
            $0.id == tracker.id && Calendar.current.isDate($0.data, inSameDayAs: date)
        }

        let completedDays = completedTrackers.filter { $0.id == tracker.id }.count
        
        cell.delegate = self
        cell.configure(
            emoji: tracker.emoji,
            title: tracker.name,
            completedDays: completedDays,
            isCompletedToday: isCompletedToday,
            date: date,
            color: tracker.color,
            trackerID: tracker.id
        )

        return cell
    }
    
    // MARK: Delegate Flow Layout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let availableWidth = collectionView.bounds.width // Уже учли отступы в TrackerCollectionView (16 + 16)
        let widthPerItem = (availableWidth - 16) / 2 // 16 — это interitemSpacing между двумя ячейками (в макете 8)
        return CGSize(width: widthPerItem, height: 148)
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                     withReuseIdentifier: "Header",
                                                                     for: indexPath) as! SupplementaryView
        let filteredCategories = filteredCategories()
        header.titleLabel.text = filteredCategories[indexPath.section].title
        return header
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 50)
    }
    
    // MARK: Helper Methods
    
    private func filteredCategories() -> [TrackerCategory] {
        guard let dataProvider = dataProvider else { return [] }
        var categories: [TrackerCategory] = []
        
        for section in 0..<dataProvider.numberOfSections {
            guard let title = dataProvider.categoryTitle(forSection: section) else { continue }
            var trackers: [Tracker] = []
            for item in 0..<dataProvider.numberOfRowsInSection(section) {
                if let tracker = dataProvider.object(at: IndexPath(item: item, section: section)) {
                    trackers.append(tracker)
                }
            }
            if !trackers.isEmpty {
                categories.append(TrackerCategory(title: title, trackers: trackers))
            }
        }
        
        guard shouldFilterByDate else {
            return categories
        }
        
        let date = datePicker.date
        let weekday = Calendar.current.component(.weekday, from: date) // 1 = Воскресенье, 2 = Понедельник, ...
        // Преобразуем календарный weekday в WeekDay (monday = 1, tuesday = 2, ..., sunday = 7)
        let adjustedWeekday = weekday == 1 ? 7 : weekday - 1 // Воскресенье (1) -> 7, Понедельник (2) -> 1, и т.д.
        // условие ? значениеЕслиУсловиеИстинно : значениеЕслиУсловиеЛожно
        let currentWeekDay = WeekDay(rawValue: adjustedWeekday)

        return categories.map { category -> TrackerCategory in
            let filteredTrackers = category.trackers.filter { tracker in
                print("Проверка трекера \(tracker.name): schedule = \(tracker.schedule), creationDate = \(tracker.creationDate)")
                if tracker.schedule.isEmpty {
                    return isSameDay(date, as: tracker.creationDate)
                } else {
                    return tracker.schedule.contains { $0 == currentWeekDay }
                }
            }
            return TrackerCategory(title: category.title, trackers: filteredTrackers)
        }.filter { !$0.trackers.isEmpty } // Убираем пустые категории после фильтрации
    }
    
    private func isSameDay(_ date1: Date, as date2: Date) -> Bool {
        let calendar = Calendar.current
        let components1 = calendar.dateComponents([.year, .month, .day], from: date1)
        let components2 = calendar.dateComponents([.year, .month, .day], from: date2)
        return components1.year == components2.year &&
               components1.month == components2.month &&
               components1.day == components2.day
    }
}

// MARK: - TrackerCollectionViewCellDelegate

extension TrackersViewController: TrackerCollectionViewCellDelegate {
    func didTapTrackerPlusButton(trackerId: UUID, date: Date, isCompleted: Bool) {
        if isCompleted {
            let record = TrackerRecord(id: trackerId, data: date)
            completedTrackers.append(record)
        } else {
            completedTrackers.removeAll { $0.id == trackerId && Calendar.current.isDate($0.data, inSameDayAs: date) }
            try? recordStore.deleteRecord(trackerId: trackerId, date: date)
        }
        
        var targetIndexPath: IndexPath?
        let filteredCategories = filteredCategories()
        
        for section in 0..<filteredCategories.count {
            for item in 0..<filteredCategories[section].trackers.count {
                if filteredCategories[section].trackers[item].id == trackerId {
                    targetIndexPath = IndexPath(item: item, section: section)
                }
            }
            if targetIndexPath != nil { break }
        }
        
        if let indexPath = targetIndexPath {
            trackerView.collectionView.reloadItems(at: [indexPath])
        }
    }
}

// MARK: - TrackerCreationDelegate

extension TrackersViewController: TrackerCreationDelegate {
    func didCreateTracker(_ tracker: Tracker, categoryTitle: String) {
        do {
            try? dataProvider?.addTracker(tracker, to: categoryTitle)
            trackerView.collectionView.reloadData()
            updatePlaceholderVisibility()
        } catch {
            print("Ошибка при добавлении трекера: \(error)")
        }
    }
}

// MARK: - TrackerDataProviderDelegate

extension TrackersViewController: TrackerDataProviderDelegate {
    func didUpdate(_ update: TrackerStoreUpdate) {
        // Кэшируем актуальные категории перед обновлением
        let currentCategories = filteredCategories()
        
        // Проверяем, что индексы валидны
        let validInsertedIndexes = update.insertedIndexes.filter { indexPath in
            indexPath.section < currentCategories.count &&
            indexPath.item < currentCategories[indexPath.section].trackers.count
        }
        
        let validDeletedIndexes = update.deletedIndexes.filter { indexPath in
            indexPath.section < currentCategories.count &&
            indexPath.item < currentCategories[indexPath.section].trackers.count
        }
        
        // Выполняем обновления только для валидных индексов
        trackerView.collectionView.performBatchUpdates {
            if !validInsertedIndexes.isEmpty {
                trackerView.collectionView.insertItems(at: validInsertedIndexes)
            }
            if !validDeletedIndexes.isEmpty {
                trackerView.collectionView.deleteItems(at: validDeletedIndexes)
            }
        }
        
        // Перезагружаем данные, чтобы учесть возможные изменения
        trackerView.collectionView.reloadData()
        updatePlaceholderVisibility()
    }
}
