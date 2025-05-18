import UIKit

// MARK: - CreatingIrregularEventViewController

final class CreatingIrregularEventViewContoller: UIViewController, TrackerOptionsTableViewDelegate, CollectionTableViewControllerDelegate, EmojiSelectionDelegate, ColorSelectionDelegate {
    
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
    
    private let optionTableView: TrackerOptionsTableView
    private let emojiCollectionView: EmojiCollectionView
    private let colorCollectionView: ColorCollectionView
    
    private let textField = UITextField()
    
    private var selectedCategory: String?
    private var selectedEmoji: String?
    private var selectedColor: UIColor?
    private var trackerName: String?
    
    weak var delegate: TrackerCreationDelegate?
    
    // MARK: - Initialization
    
    init() {
        optionTableView = TrackerOptionsTableView(itemsOfTableView: ["Категория"])
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
        
        view.backgroundColor = .ypWhite
        
        navigationItem.title = "Новое нерегулярное событие"
        
        setupNavigationBar()
        setUpCreatingTrackerViewController()
        
        updateCreateButtonState()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        optionTableView.deselectSelectedRow()
    }
    
    // MARK: - Setup UI
    
    func setupNavigationBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(backTapped)
        )
            
        navigationItem.leftBarButtonItem?.tintColor = .ypBlack
        navigationItem.backBarButtonItem?.title = ""
        
        navigationItem.title = "Новое нерегулярное событие"
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
        
        textField.textColor = .ypBlack
        textField.attributedPlaceholder = NSAttributedString(
            string: "Введите название трекера",
            attributes: [.foregroundColor: UIColor.ypGray]
        )
        textField.backgroundColor = .ypBackground
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        let leftPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: textField.frame.height))
        textField.leftView = leftPaddingView
        textField.leftViewMode = .always
        
        textField.layer.cornerRadius = 16
        textField.layer.masksToBounds = true
        textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        
        contentView.addSubview(textField)
        
        NSLayoutConstraint.activate([
            textField.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 28),
            textField.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            textField.heightAnchor.constraint(equalToConstant: 75)
        ])
        
        optionTableView.delegate = self
        optionTableView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(optionTableView)
        
        NSLayoutConstraint.activate([
            optionTableView.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 24),
            optionTableView.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            optionTableView.trailingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            optionTableView.heightAnchor.constraint(equalToConstant: 75)
        ])
        
        let emojiLabel = UILabel()
        emojiLabel.text = "Emoji"
        emojiLabel.textColor = .ypBlack
        emojiLabel.font = UIFont.systemFont(ofSize: 19)
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(emojiLabel)
        
        NSLayoutConstraint.activate([
            emojiLabel.topAnchor.constraint(equalTo: optionTableView.bottomAnchor, constant: 32),
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
        colorLabel.text = "Цвет"
        colorLabel.textColor = .ypBlack
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
        cancelButton.setTitle("Отменить", for: .normal)
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
        cancelButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        
        let createButton = UIButton()
        createButton.setTitle("Создать", for: .normal)
        createButton.setTitleColor(.ypWhite, for: .normal)
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
        createButton.addTarget(self, action: #selector(createTapped), for: .touchUpInside)
    }
    
    // MARK: - Actions
    
    @objc
    func textFieldDidChange() {
        trackerName = textField.text?.trimmingCharacters(in: .whitespaces)
        updateCreateButtonState()
    }
    
    @objc
    func backTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc
    func createTapped() {
        guard let name = trackerName,
              let category = selectedCategory,
              let color = selectedColor,
              let emoji = selectedEmoji else { return }
        
        print("CreatingIrregularEventVC: Делегат \(self.delegate == nil ? "nil" : "установлен")") // <-- ДОБАВЬТЕ ЭТУ СТРОКУ
        
        let tracker = Tracker(id: UUID(),
                              name: name,
                              color: color,
                              emoji: emoji,
                              schedule: [],
                              creationDate: Date()
        )
        print("Создан трекер в CreatingIrregularEventViewContoller: \(tracker)")
        delegate?.didCreateTracker(tracker, categoryTitle: category)
        
        if let tabBarController = UIApplication.shared.windows.first?.rootViewController as? AppTabBarController {
            tabBarController.selectedIndex = 0
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Helper Methods
    
    func updateCreateButtonState() {
        let isFormValid = trackerName?.isEmpty == false &&
                        selectedCategory != nil &&
                        selectedColor != nil &&
                        selectedEmoji != nil
        let creatButton = contentView.subviews.first(where: { $0 is UIButton && ($0 as? UIButton)?.titleLabel?.text == "Создать" }) as? UIButton
        creatButton?.isEnabled = isFormValid
        creatButton?.backgroundColor = isFormValid ? .ypBlack : .ypGray
    }
    
    // MARK: - TrackerOptionsTableViewDelegate
    
    func didSelectOption(at index: Int) {
        switch index {
        case 0:
            let collectionTableVC = CollectionTableViewController()
            collectionTableVC.delegate = self
            navigationController?.pushViewController(collectionTableVC, animated: true)
        default:
            break
        }
    }
    
    // MARK: - CollectionTableViewControllerDelegate
    
    func didSelectOption(_ category: String?) {
        selectedCategory = category
        optionTableView.updateCategorySubtitle(selectedCategory)
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
 
