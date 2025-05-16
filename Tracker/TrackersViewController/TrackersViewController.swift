import UIKit

final class TrackersViewController: UIViewController {
    var categories: [TrackerCategory] = [] {
        didSet {
            updatePlaceholderVisibility()
        }
    }
    
    var completedTrackers: [TrackerRecord] = []
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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Загружаем категории из TrackerData
        categories = TrackerData.getCategories()
        
        // Тестовые трекеры
        let calendar = Calendar.current
        // Устанавливаем текущую дату с обнулением времени
        let currentDate = calendar.startOfDay(for: Date()) // Обнуляем время
        datePicker.date = currentDate
        
        //shouldFilterByDate = true
        
        setupNavigationBar()
        setUpTrackersViewController()
        setUpTracker()
        
        // Применяем фильтрацию сразу после загрузки
        trackerView.collectionView.reloadData()
        
        updatePlaceholderVisibility()
    }
    
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

    func updatePlaceholderVisibility() {
        guard let imageView = imageView else { return }
        
        let hasTrackers = !categories.flatMap { $0.trackers }.isEmpty
        imageView.isHidden = hasTrackers
        descriptionLabel.isHidden = hasTrackers
    }

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

extension TrackersViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
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
    
    private func filteredCategories() -> [TrackerCategory] {
        // Если фильтрация не нужна, возвращаем все категории без изменений
        guard shouldFilterByDate else {
            print("Фильтрация отключена, возвращены все категории: \(categories)")
            return categories
        }

        let date = datePicker.date
        let dayAbbreviations = ["Вс", "Пн", "Вт", "Ср", "Чт", "Пт", "Сб"]
        let dateDayIndex = Calendar.current.component(.weekday, from: date) - 1 // -1, потому что индексы начинаются с 0, а .weekday с 1
        let dayString = dayAbbreviations[dateDayIndex]

        let filtered = categories.map { category -> TrackerCategory in
            let filteredTrackers = category.trackers.filter { tracker in
                print("Проверка трекера \(tracker.name): schedule = \(tracker.schedule), creationDate = \(tracker.creationDate)")
                if tracker.schedule.isEmpty {
                    return isSameDay(date, as: tracker.creationDate)
                } else {
                    return tracker.schedule.contains(dayString)
                }
            }
            return TrackerCategory(title: category.title, trackers: filteredTrackers)
        }.filter { !$0.trackers.isEmpty } // Убираем пустые категории после фильтрации
        print("Отфильтрованные категории: \(filtered)")
        return filtered
    }
    
    private func isSameDay(_ date1: Date, as date2: Date) -> Bool {
        let calendar = Calendar.current
        let components1 = calendar.dateComponents([.year, .month, .day], from: date1)
        let components2 = calendar.dateComponents([.year, .month, .day], from: date2)
        return components1.year == components2.year &&
               components1.month == components2.month &&
               components1.day == components2.day
    }
    
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
}

extension TrackersViewController: TrackerCollectionViewCellDelegate {
    func didTapTrackerPlusButton(trackerId: UUID, date: Date, isCompleted: Bool) {
        if isCompleted {
            let record = TrackerRecord(id: trackerId, data: date)
            completedTrackers.append(record)
        } else {
            completedTrackers.removeAll { $0.id == trackerId && Calendar.current.isDate($0.data, inSameDayAs: date) }
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

extension TrackersViewController: TrackerCreationDelegate {
    func didCreateTracker(_ tracker: Tracker, categoryTitle: String) {
        print("Создан трекер: \(tracker.name), категория: \(categoryTitle)")
        if let categoryIndex = categories.firstIndex(where: { $0.title == categoryTitle }) {
            let category = categories[categoryIndex]
            let updatedTrackers = category.trackers + [tracker]
            categories[categoryIndex] = TrackerCategory(title: categoryTitle, trackers: updatedTrackers)
        } else {
            let newCategory = TrackerCategory(title: categoryTitle, trackers: [tracker])
            categories.append(newCategory)
        }
        print("Обновленные категории: \(categories)")
        trackerView.collectionView.reloadData()
        trackerView.collectionView.layoutIfNeeded()
        
        let filtered = filteredCategories()
        print("После добавления трекера отфильтрованные категории: \(filtered)")
        updatePlaceholderVisibility()
    }
}
