import UIKit

// MARK: - TrackersViewControllerDelegate

protocol TrackersViewControllerDelegate: AnyObject {
    func trackerForEdit(_ tracker: Tracker, in category: TrackerCategoryCoreData)
}

// MARK: - TrackersViewController

final class TrackersViewController: UIViewController, UINavigationControllerDelegate {
    
    // MARK: - Properties
    
    private var shouldFilterByDate = true
    weak var trackerCreationDelegate: TrackerCreationDelegate?
    
    private let trackerView = TrackerCollectionView()
    
    private lazy var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker(frame: .zero)
        datePicker.preferredDatePickerStyle = .compact
        datePicker.datePickerMode = .date
        datePicker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
        return datePicker
    }()
    
    let searchController = UISearchController(searchResultsController: nil)
    
    private let descriptionLabel = UILabel()
    private let imageView = UIImageView()
    private let filterButton = UIButton(type: .system)
    
    private let trackerStore = TrackerStore()
    private let categoryStore = TrackerCategoryStore()
    private let recordStore = TrackerRecordStore()
    private var dataProviderProtocol: TrackerDataProviderProtocol?
    private var trackerDataProvider: TrackerDataProvider?
    private var completedTrackers: [TrackerRecord] = []
    
    var filteredCategoriesFromSearchBar: [TrackerCategory] = []
    
    let editTrackerViewController = EditTrackerViewController()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .dynamicBackground
        
        do {
            dataProviderProtocol = try TrackerDataProvider(trackerStore: trackerStore, categoryStore: categoryStore, recordStore: recordStore)
            dataProviderProtocol?.delegate = self
        } catch {
            print("Ошибка инициализации dataProviderProtocol: \(error)")
        }
        
        trackerDataProvider = dataProviderProtocol as? TrackerDataProvider
        
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchResultsUpdater = self
        
        completedTrackers = (try? recordStore.fetchAllRecords()) ?? []
        
        trackerDataProvider?.cleanExpiredIrregularTrackers()
        
        setupNavigationBar()
        setUpTrackersViewController()
        setUpTracker()
        
        datePicker.date = Date()
        
        trackerView.collectionView.reloadData()
        
        updatePlaceholderVisibility()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //AnalyticsService.shared.logEvent(.open(screen: "Main"))
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        //AnalyticsService.shared.logEvent(.close(screen: "Main"))
    }
    
    // MARK: - Setup UI
    
    func setupNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .dynamicBackground
        appearance.titleTextAttributes = [.foregroundColor: UIColor.dynamicTitleColor]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.dynamicTitleColor]
        appearance.shadowColor = nil
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        
        title = L10n.Title.mainScreen
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(named: "Plus"),
            style: .plain,
            target: self,
            action: #selector(plusTapped)
        )
        navigationItem.leftBarButtonItem?.tintColor = .dynamicButtonBackground
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
        
        // Добавляем поиск
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = L10n.Trackers.Search.title
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
        
        descriptionLabel.text = L10n.Empty.trackers
        descriptionLabel.textAlignment = .center
        descriptionLabel.textColor = .dynamicTitleColor
        descriptionLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(descriptionLabel)
        
        NSLayoutConstraint.activate([
            descriptionLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
        
        filterButton.setTitle("Фильтрация", for: .normal)
        filterButton.setTitleColor(.ypWhite, for: .normal)
        filterButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        filterButton.backgroundColor = .ypBlueTracker
        filterButton.layer.cornerRadius = 16
        filterButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(filterButton)
        
        NSLayoutConstraint.activate([
            filterButton.widthAnchor.constraint(equalToConstant: 114),
            filterButton.heightAnchor.constraint(equalToConstant: 50),
            filterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            filterButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
        
        filterButton.addTarget(self, action: #selector(filterButtonTapped), for: .touchUpInside)
    }
    
    // MARK: - Helper Methods
    
    func updatePlaceholderVisibility() {
        let hasTrackers = !currentCategories().isEmpty
        
        imageView.isHidden = hasTrackers
        descriptionLabel.isHidden = hasTrackers
    }
    
    // MARK: - Actions
    
    @objc
    func plusTapped(_ sender: UITabBarItem) {
        //AnalyticsService.shared.logEvent(.click(screen: "Main", item: "add_track"))
        let creatingTrackerVC = UINavigationController(rootViewController: CreatingTrackerViewController())
        if let creatingVC = creatingTrackerVC.viewControllers.first as? CreatingTrackerViewController {
            creatingVC.delegate = self
            creatingVC.dataProvider = self.trackerDataProvider
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
        
        shouldFilterByDate = true
        trackerView.collectionView.reloadData()
        updatePlaceholderVisibility()
    }
    
    @objc
    func filterButtonTapped() {
        //AnalyticsService.shared.logEvent(.click(screen: "Main", item: "filter"))
        let filterViewController = FilterViewController()
        filterViewController.delegate = self
        let filterVC = UINavigationController(rootViewController: filterViewController)
        
        filterVC.modalPresentationStyle = .pageSheet
        filterVC.modalTransitionStyle = .coverVertical
        
        present(filterVC, animated: true)
    }
}

// MARK: - UICollectionViewDataSource & UICollectionViewDelegateFlowLayout

extension TrackersViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    // MARK: DataSource
    
    private func currentCategories() -> [TrackerCategory] {
        return searchController.isActive && !(searchController.searchBar.text?.isEmpty ?? true) ? filteredCategoriesFromSearchBar : filteredCategories()
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return currentCategories().count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return currentCategories()[section].trackers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? TrackerCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        let currentCategories = currentCategories()
        let tracker = currentCategories[indexPath.section].trackers[indexPath.item]
        let date = datePicker.date
        
        let normalizedDate = Calendar.current.startOfDay(for: datePicker.date)
        let isCompletedToday = completedTrackers.contains {
            $0.trackerId == tracker.id && Calendar.current.isDate($0.date, inSameDayAs: normalizedDate)
        }
        let completedDays = completedTrackers.filter { $0.trackerId == tracker.id }.count
        
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
    
    func filteredCategories() -> [TrackerCategory] {
        guard let dataProvider = dataProviderProtocol else { return [] }
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
        
        guard shouldFilterByDate else { return categories }
        
        let date = datePicker.date
        let weekday = Calendar.current.component(.weekday, from: date) // 1 = Воскресенье, 2 = Понедельник, ...
        // Преобразуем календарный weekday в WeekDay (monday = 1, tuesday = 2, ..., sunday = 7)
        let adjustedWeekday = weekday == 1 ? 7 : weekday - 1 // Воскресенье (1) -> 7, Понедельник (2) -> 1, и т.д.
        // условие ? значениеЕслиУсловиеИстинно : значениеЕслиУсловиеЛожно
        let currentWeekDay = WeekDay(rawValue: adjustedWeekday)
        
        return categories.map { category -> TrackerCategory in
            let filteredTrackers = category.trackers.filter { tracker in
                if tracker.schedule.isEmpty {
                    return isSameDay(date, as: tracker.creationDate)
                } else {
                    return tracker.schedule.contains { $0 == currentWeekDay }
                }
            }
            return TrackerCategory(title: category.title, trackers: filteredTrackers)
        }.filter { !$0.trackers.isEmpty }
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
        //AnalyticsService.shared.logEvent(.click(screen: "Main", item: "track"))
        if isCompleted {
            let normalizedDate = Calendar.current.startOfDay(for: date)
            
            let record = TrackerRecord(id: UUID(), trackerId: trackerId, date: normalizedDate)
            if !completedTrackers.contains { $0.trackerId == trackerId && Calendar.current.isDate($0.date, inSameDayAs: normalizedDate)} {
                completedTrackers.append(record)
                
                do {
                    try recordStore.addRecord(record)
                } catch {
                    completedTrackers.removeAll { $0.id == record.id }
                    print("Failed to save record: \(error)")
                }
            }
            
        } else {
            completedTrackers.removeAll { rec in
                rec.trackerId == trackerId && Calendar.current.isDate(rec.date, inSameDayAs: date)
            }
            
            do {
                try recordStore.deleteRecord(trackerId: trackerId, date: date)
            } catch {
                print("Failed to delete record: \(error)")
            }
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
    
    func didTapPinButton(trackerId: UUID) {
        // TODO: Реализовать функционал закрепления трекера
    }
    
    func didTapEditButton(trackerId: UUID) {
        //AnalyticsService.shared.logEvent(.click(screen: "Main", item: "edit"))
        let filteredCategories = filteredCategories()
        
        var selectedTracker: Tracker? = nil
        var selectedCategory: TrackerCategory? = nil
        
        for section in 0..<filteredCategories.count {
            for item in 0..<filteredCategories[section].trackers.count {
                let tracker = filteredCategories[section].trackers[item]
                if tracker.id == trackerId {
                    selectedTracker = tracker
                    selectedCategory = filteredCategories[section]
                    break
                }
            }
            if selectedTracker != nil { break }
        }
        
        let editTrackerViewController = EditTrackerViewController()
        
        editTrackerViewController.delegate = self
        editTrackerViewController.tracker = selectedTracker
        editTrackerViewController.category = selectedCategory

        let editTrackerVC = UINavigationController(rootViewController: editTrackerViewController)
        
        editTrackerVC.modalPresentationStyle = .pageSheet
        editTrackerVC.modalTransitionStyle = .coverVertical
        
        present(editTrackerVC, animated: true)
    }
    
    func didTapDeleteButton(trackerId: UUID) {
        //AnalyticsService.shared.logEvent(.click(screen: "Main", item: "delete"))
        var targetIndexPath: IndexPath?
        let filteredCategories = filteredCategories()
        
        for section in 0..<filteredCategories.count {
            for item in 0..<filteredCategories[section].trackers.count {
                if filteredCategories[section].trackers[item].id == trackerId {
                    targetIndexPath = IndexPath(item: item, section: section)
                    break
                }
            }
            if targetIndexPath != nil { break }
        }

        if let indexPath = targetIndexPath {
            showDeleteConfirmationAlert(for: trackerId, at: indexPath)
        } else {
            trackerView.collectionView.reloadData()
            updatePlaceholderVisibility()
        }
    }

    func showDeleteConfirmationAlert(for trackerId: UUID, at indexPath: IndexPath) {
        let alert = UIAlertController(
            title: nil,
            message: "Этот трекер точно не нужен?",
            preferredStyle: .actionSheet
        )
        
        let cancelAction = UIAlertAction(title: "Отменить", style: .cancel, handler: nil)
        
        let deleteAction = UIAlertAction(title: "Удалить", style: .destructive) { [weak self] _ in
            guard let self = self else { return }
            do {
                try self.trackerStore.deleteTracker(by: trackerId)
                
                self.trackerView.collectionView.performBatchUpdates({
                    self.trackerView.collectionView.deleteItems(at: [indexPath])
                }, completion: { _ in
                    self.updatePlaceholderVisibility()
                })
                
            } catch {
                print("Ошибка при удалении трекера: \(error)")
            }
        }
        
        alert.addAction(cancelAction)
        alert.addAction(deleteAction)
        present(alert, animated: true, completion: nil)
    }

}

// MARK: - TrackerCreationDelegate

extension TrackersViewController: TrackerCreationDelegate {
    func didCreateTracker(_ tracker: Tracker, categoryTitle: String) {
        do {
            try dataProviderProtocol?.addTracker(tracker, to: categoryTitle)
            trackerDataProvider?.setFilter(.today(Date()))
            updatePlaceholderVisibility()
        } catch {
            print("Ошибка при добавлении трекера: \(error)")
        }
    }
}

// MARK: - TrackerDataProviderDelegate

extension TrackersViewController: TrackerDataProviderDelegate {
    func didUpdate(_ update: TrackerStoreUpdate) {
        trackerView.collectionView.reloadData()
        updatePlaceholderVisibility()
    }
    
    func setFilter(_ filter: FilterType) {
        updatePlaceholderVisibility()
    }
}

extension TrackersViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let text = searchController.searchBar.text ?? ""
        
        shouldFilterByDate = false
        
        trackerDataProvider?.searchTrackers(with: text) { [weak self] categories in
            guard let self = self else { return }
            
            if text.isEmpty {
                self.filteredCategoriesFromSearchBar = []
            } else {
                self.filteredCategoriesFromSearchBar = categories
            }
            
            self.trackerView.collectionView.reloadData()
        }
    }
}

extension TrackersViewController: FilterViewControllerDelegate {
    func didSelectFilter(_ filter: FilterType) {
        switch filter {
        case .all:
            datePicker.date = Date()
            shouldFilterByDate = false
        case .today, .completed, .uncompleted:
            datePicker.date = Date()
            shouldFilterByDate = true
        }
        
        trackerDataProvider?.setFilter(filter)
        trackerView.collectionView.reloadData()
        updatePlaceholderVisibility()
    }
}

extension TrackersViewController: EditTrackerViewControllerDelegate {
    func didUpdateTracker(_ tracker: Tracker, categoryTitle: String) {
        trackerView.collectionView.reloadData()
        updatePlaceholderVisibility()
    }
}
