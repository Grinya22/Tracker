import UIKit

// MARK: - TrackerCreationDelegate

protocol TrackerCreationDelegate: AnyObject {
    func didCreateTracker(_ tracker: Tracker, categoryTitle: String)
}

// MARK: - CreatingHabitViewController

final class CreatingHabitViewController: UIViewController, TrackerOptionsTableViewDelegate, CollectionTableViewControllerDelegate, ScheduleTableViewControllerDelegate, EmojiSelectionDelegate, ColorSelectionDelegate {
    
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
    
    private let optionsTableView: TrackerOptionsTableView
    private let emojiCollectionView: EmojiCollectionView
    private let colorCollectionView: ColorCollectionView
    
    private let textField = UITextField()
    
    private var selectedCategory: String?
    private var selectedDays: [WeekDay] = []
    private var selectedEmoji: String?
    private var selectedColor: UIColor?
    private var trackerName: String?
    
    weak var delegate: TrackerCreationDelegate?
    weak var dataProvider: TrackerDataProvider?

    
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
        
        updateCreateButtonState()
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
        
        navigationItem.title = L10n.New.Habit.title
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
            textField.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 28),
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
        
        let createButton = UIButton()
        createButton.setTitle(L10n.Create.button, for: .normal)
        createButton.setTitleColor(.dynamicButtonTitle, for: .normal)
        createButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        createButton.layer.cornerRadius = 16
        createButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(createButton)
        
        NSLayoutConstraint.activate([
            createButton.topAnchor.constraint(equalTo: colorCollectionView.bottomAnchor, constant: 16),
            createButton.trailingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            createButton.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.44),
            createButton.heightAnchor.constraint(equalToConstant: 60),
            
            createButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
        ])
        
        cancelButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
        createButton.addTarget(self, action: #selector(createTapped), for: .touchUpInside)
    }
    
    // MARK: - Actions
    
    @objc
    func textFieldDidChange() {
        trackerName = textField.text?.trimmingCharacters(in: .whitespaces)
        updateCreateButtonState()
    }
    
    @objc
    func cancelTapped() {
        UserDefaults.standard.removeObject(forKey: "savedDays")
        UserDefaults.standard.synchronize()
        
        navigationController?.popViewController(animated: true)
    }
    
    @objc
    func createTapped() {
        guard let name = trackerName,
              let categoryTitle = selectedCategory,
              let color = selectedColor,
              let emoji = selectedEmoji else {
            return
        }
        
        let tracker = Tracker(
            id: UUID(),
            name: name,
            color: color,
            emoji: emoji,
            schedule: selectedDays,
            creationDate: Date()
        )
        
        do {
            guard let dataProvider = dataProvider else {
                return
            }
            
            // Добавляем трекер через исправленный TrackerDataProvider.
            try dataProvider.addTracker(tracker, to: categoryTitle)
            // Зачем: Чтобы трекер сохранился в Core Data и был связан с категорией.
            // Почему так: TrackerDataProvider использует исправленный addTracker.

            // Уведомляем делегата.
            delegate?.didCreateTracker(tracker, categoryTitle: categoryTitle)
            // Зачем: Чтобы TrackersViewController обновил UI.
            // Почему так: Это часть твоей архитектуры.
            
            // Переключаемся на TrackersViewController.
            if let tabBarController = UIApplication.shared.windows.first?.rootViewController as? AppTabBarController {
                tabBarController.selectedIndex = 0
            }
            // Зачем: Для перехода на главный экран.
            // Почему так: Это твоя логика навигации.
            
            // Очищаем UserDefaults.
            UserDefaults.standard.removeObject(forKey: "savedDays")
            UserDefaults.standard.synchronize()
            // Зачем: Чтобы сбросить временные данные.
            // Почему так: Это часть твоего кода.
            
            // Закрываем контроллер.
            dismiss(animated: true, completion: nil)
        } catch {
            print("Ошибка при создании трекера: \(error)")
        }
    }
    
    // MARK: - Helper Methods
    
    private func updateCreateButtonState() {
        let isFormValid = trackerName?.isEmpty == false &&
                        selectedCategory != nil &&
                        !selectedDays.isEmpty &&
                        selectedColor != nil &&
                        selectedEmoji != nil
        let createButton = contentView.subviews.first(where: { $0 is UIButton && ($0 as? UIButton)?.titleLabel?.text == L10n.Create.button }) as? UIButton
        createButton?.isEnabled = isFormValid
        createButton?.backgroundColor = isFormValid ? .dynamicButtonBackground : .ypGray
    }
    
    // MARK: - TrackerOptionsTableViewDelegate
    
    func didSelectOption(at index: Int) {
        switch index {
        case 0:
            let collectionTableVC = CollectionTableViewController()
            collectionTableVC.delegate = self
            navigationController?.pushViewController(collectionTableVC, animated: true)
        case 1:
            let scheduleTableVC = ScheduleTableViewController()
            scheduleTableVC.delegate = self
            navigationController?.pushViewController(scheduleTableVC, animated: true)
        default:
            break
        }
    }
    
    // MARK: - CollectionTableViewControllerDelegate
    
    func didSelectOption(_ category: String?) {
        selectedCategory = category
        optionsTableView.updateCategorySubtitle(category)
        updateCreateButtonState()
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
        updateCreateButtonState()
    }
    
    // MARK: - EmojiSelectionDelegate
    
    func didSelectEmoji(_ emoji: String?) {
        selectedEmoji = emoji
        updateCreateButtonState()
    }
    
    // MARK: - ColorSelectionDelegate
    
    func didSelectColor(_ color: UIColor?) {
        selectedColor = color
        updateCreateButtonState()
    }
}
