import UIKit

// MARK: - EditTrackerViewControllerDelegate

protocol EditTrackerViewControllerDelegate: AnyObject {
    func didUpdateTracker(_ tracker: Tracker, categoryTitle: String)
}

// MARK: - EditTrackerViewController

final class EditTrackerViewController: UIViewController, TrackerOptionsTableViewDelegate, CollectionTableViewControllerDelegate, ScheduleTableViewControllerDelegate, EmojiSelectionDelegate, ColorSelectionDelegate {
    
    // MARK: - Properties
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.keyboardDismissMode = .interactive
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private let contentView: UIView = {
        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        return contentView
    }()
    
    private let dayLabel = UILabel()
    private let optionsTableView: TrackerOptionsTableView
    private let emojiCollectionView: EmojiCollectionView
    private let colorCollectionView: ColorCollectionView
    
    private let textField = UITextField()
    
    private var selectedCategory: String?
    private var selectedDays: [WeekDay] = []
    private var selectedEmoji: String?
    private var selectedColor: UIColor?
    private var trackerName: String?
    
    weak var delegate: EditTrackerViewControllerDelegate?
    
    var tracker: Tracker?
    var category: TrackerCategory?
    
    private let trackerStore = TrackerStore()
    private let trackerRecordStore = TrackerRecordStore()

    // MARK: - Initialization
    
    init() {
        optionsTableView = TrackerOptionsTableView(itemsOfTableView: [L10n.category, L10n.schedule])
        emojiCollectionView = EmojiCollectionView(frame: .zero)
        colorCollectionView = ColorCollectionView(frame: .zero)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .dynamicBackground
        
        setupNavigationBar()
        setUpCreatingTrackerViewController()
        
        populateFields()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        AnalyticsService.shared.logEvent(.open(screen: "EditTracker"))
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        AnalyticsService.shared.logEvent(.close(screen: "EditTracker"))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        optionsTableView.deselectSelectedRow()
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
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(cancelTapped)
        )
        
        navigationItem.leftBarButtonItem?.tintColor = .dynamicButtonBackground
        navigationItem.backBarButtonItem?.title = ""
        
        navigationItem.title = "Редактирование привычки"
    }
    
    func setUpCreatingTrackerViewController() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
        
        dayLabel.textColor = .dynamicTitleColor
        dayLabel.textAlignment = .center
        dayLabel.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        dayLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(dayLabel)
        
        NSLayoutConstraint.activate([
            dayLabel.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 24),
            dayLabel.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            dayLabel.trailingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            dayLabel.heightAnchor.constraint(equalToConstant: 38)
        ])
        
        textField.textColor = .dynamicTitleColor
        textField.attributedPlaceholder = NSAttributedString(
            string: L10n.SearchBar.nameTracker,
            attributes: [.foregroundColor: UIColor.ypGray]
        )
        textField.backgroundColor = .dynamicTextFieldOrTableViewBackgroundColor
        textField.translatesAutoresizingMaskIntoConstraints = false
        let leftPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: textField.frame.height))
        textField.leftView = leftPaddingView
        textField.leftViewMode = .always
        textField.layer.cornerRadius = 16
        textField.layer.masksToBounds = true
        contentView.addSubview(textField)
        
        NSLayoutConstraint.activate([
            textField.topAnchor.constraint(equalTo: dayLabel.bottomAnchor, constant: 40),
            textField.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            textField.heightAnchor.constraint(equalToConstant: 75)
        ])
        textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)

        optionsTableView.delegate = self
        optionsTableView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(optionsTableView)
        
        NSLayoutConstraint.activate([
            optionsTableView.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 24),
            optionsTableView.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            optionsTableView.trailingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            optionsTableView.heightAnchor.constraint(equalToConstant: 150)
        ])
        
        let emojiLabel = UILabel()
        emojiLabel.text = L10n.Title.chooseEmoji
        emojiLabel.textColor = .dynamicTitleColor
        emojiLabel.font = UIFont.boldSystemFont(ofSize: 19)
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(emojiLabel)
        
        NSLayoutConstraint.activate([
            emojiLabel.topAnchor.constraint(equalTo: optionsTableView.bottomAnchor, constant: 32),
            emojiLabel.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor, constant: 28)
        ])
        
        emojiCollectionView.translatesAutoresizingMaskIntoConstraints = false
        emojiCollectionView.delegate = self
        contentView.addSubview(emojiCollectionView)
        
        NSLayoutConstraint.activate([
            emojiCollectionView.topAnchor.constraint(equalTo: emojiLabel.bottomAnchor, constant: 24),
            emojiCollectionView.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            emojiCollectionView.trailingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.trailingAnchor, constant: -16),
        ])
        
        let colorLabel = UILabel()
        colorLabel.text = L10n.Title.chooseColor
        colorLabel.textColor = .dynamicTitleColor
        colorLabel.font = UIFont.boldSystemFont(ofSize: 19)
        colorLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(colorLabel)
        
        NSLayoutConstraint.activate([
            colorLabel.topAnchor.constraint(equalTo: emojiCollectionView.bottomAnchor, constant: 32),
            colorLabel.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor, constant: 28)
        ])
        
        colorCollectionView.translatesAutoresizingMaskIntoConstraints = false
        colorCollectionView.delegate = self
        contentView.addSubview(colorCollectionView)
        
        NSLayoutConstraint.activate([
            colorCollectionView.topAnchor.constraint(equalTo: colorLabel.bottomAnchor, constant: 24),
            colorCollectionView.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            colorCollectionView.trailingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.trailingAnchor, constant: -16),
        ])
        
        let cancelButton = UIButton()
        cancelButton.setTitle(L10n.Cancel.button, for: .normal)
        cancelButton.setTitleColor(.ypRed, for: .normal)
        cancelButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        cancelButton.layer.cornerRadius = 16
        cancelButton.layer.borderWidth = 1
        cancelButton.layer.borderColor = UIColor.ypRed.cgColor
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(cancelButton)
        
        NSLayoutConstraint.activate([
            cancelButton.topAnchor.constraint(equalTo: colorCollectionView.bottomAnchor, constant: 16),
            cancelButton.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            cancelButton.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.44),
            cancelButton.heightAnchor.constraint(equalToConstant: 60)
        ])
        
        let saveButton = UIButton()
        saveButton.backgroundColor = .dynamicButtonBackground
        saveButton.setTitle("Сохранить", for: .normal)
        saveButton.setTitleColor(.dynamicButtonTitle, for: .normal)
        saveButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        saveButton.layer.cornerRadius = 16
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(saveButton)
        
        NSLayoutConstraint.activate([
            saveButton.topAnchor.constraint(equalTo: colorCollectionView.bottomAnchor, constant: 16),
            saveButton.trailingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            saveButton.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.44),
            saveButton.heightAnchor.constraint(equalToConstant: 60),
            
            saveButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
        ])
        
        cancelButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
        saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
    }
    
    // MARK: - Actions
    
    @objc
    func textFieldDidChange() {
        trackerName = textField.text?.trimmingCharacters(in: .whitespaces)
    }
    
    @objc
    func cancelTapped() {
        AnalyticsService.shared.logEvent(.click(screen: "EditTracker", item: "cancel"))
        dismiss(animated: true)
    }
    
    @objc
    func saveTapped() {
        AnalyticsService.shared.logEvent(.click(screen: "EditTracker", item: "save"))
        guard let name = trackerName ?? tracker?.name,
              let categoryTitle = selectedCategory ?? category?.title,
              let color = selectedColor ?? tracker?.color,
              let emoji = selectedEmoji ?? tracker?.emoji else {
                  return
              }
        
        guard var tracker = tracker else {
            return
        }
        
        tracker = Tracker(
            id: tracker.id,
            name: name,
            color: color,
            emoji: emoji,
            schedule: selectedDays,
            creationDate: tracker.creationDate
        )
        
        do {
            try trackerStore.updateTracker(tracker, toCategoryWithTitle: categoryTitle)
            
            delegate?.didUpdateTracker(tracker, categoryTitle: categoryTitle)
            
            if let tabBarController = UIApplication.shared.windows.first?.rootViewController as? AppTabBarController {
                tabBarController.selectedIndex = 0
            }
            
            UserDefaults.standard.removeObject(forKey: "savedDays")
            UserDefaults.standard.synchronize()
            
            dismiss(animated: true, completion: nil)
        } catch {
            print("Ошибка при создании трекера: \(error)")
        }
    }
    
    // MARK: - Helper Methods
    
    private func populateFields() {
        UserDefaults.standard.removeObject(forKey: "savedDays")
        
        guard let tracker = tracker else { return }
        guard let category = category else { return }

        let allRecords = try? trackerRecordStore.fetchAllRecords()
        let completedDays = allRecords?.filter { $0.trackerId == tracker.id }.count ?? 0
        
        selectedCategory = category.title
        optionsTableView.updateCategorySubtitle(category.title)
        
        textField.text = tracker.name
        
        dayLabel.text = L10n.Day.count(completedDays)
        
        selectedDays.removeAll()
        selectedDays = tracker.schedule
        
        let stringDays: String
        if selectedDays.count == 7 {
            stringDays = L10n.everyday
        } else {
            let dayNames = selectedDays.map { weekDay -> String in
                switch weekDay {
                case .monday: return L10n.Short.monday
                case .tuesday: return L10n.Short.tuesday
                case .wednesday: return L10n.Short.wednesday
                case .thursday: return L10n.Short.thursday
                case .friday: return L10n.Short.friday
                case .saturday: return L10n.Short.saturday
                case .sunday: return L10n.Short.sunday
                }
            }
            stringDays = dayNames.joined(separator: ", ")
        }
        optionsTableView.updateScheduleSubtitle(stringDays)
        
        selectedEmoji = tracker.emoji
        emojiCollectionView.preselectEmoji(selectedEmoji)

        selectedColor = tracker.color
        colorCollectionView.preselectColor(selectedColor)
    }
    
    // MARK: - TrackerOptionsTableViewDelegate
    
    func didSelectOption(at index: Int) {
        AnalyticsService.shared.logEvent(.click(screen: "EditTracker", item: "option_\(index)"))
        switch index {
        case 0:
            let collectionTableVC = CollectionTableViewController()
            collectionTableVC.delegate = self
            collectionTableVC.selectedCategoryTitle = selectedCategory
            navigationController?.pushViewController(collectionTableVC, animated: true)
        case 1:
            let scheduleTableVC = ScheduleTableViewController()
            scheduleTableVC.delegate = self
            scheduleTableVC.selectedWeekDays = selectedDays
            navigationController?.pushViewController(scheduleTableVC, animated: true)
        default:
            break
        }
    }
    
    // MARK: - CollectionTableViewControllerDelegate
    
    func didSelectOption(_ category: String?) {
        selectedCategory = category
        optionsTableView.updateCategorySubtitle(category)
    }
    
    // MARK: - ScheduleTableViewControllerDelegate
    
    func didSelectDays(_ days: [WeekDay]) {
        selectedDays = days
        let stringDays: String
        if days.count == 7 {
            stringDays = L10n.everyday
        } else {
            let dayNames = days.map { weekDay -> String in
                switch weekDay {
                case .monday: return L10n.Short.monday
                case .tuesday: return L10n.Short.tuesday
                case .wednesday: return L10n.Short.wednesday
                case .thursday: return L10n.Short.thursday
                case .friday: return L10n.Short.friday
                case .saturday: return L10n.Short.saturday
                case .sunday: return L10n.Short.sunday
                }
            }
            stringDays = dayNames.joined(separator: ", ")
        }
        optionsTableView.updateScheduleSubtitle(stringDays)
    }
    
    // MARK: - EmojiSelectionDelegate
    
    func didSelectEmoji(_ emoji: String?) {
        selectedEmoji = emoji
    }
    
    // MARK: - ColorSelectionDelegate
    
    func didSelectColor(_ color: UIColor?) {
        selectedColor = color
    }
}
