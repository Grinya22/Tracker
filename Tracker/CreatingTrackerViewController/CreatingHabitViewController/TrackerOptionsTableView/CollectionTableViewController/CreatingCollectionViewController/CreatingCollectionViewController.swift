import UIKit

// MARK: - CreatingCollectionDelegate

protocol CreatingCollectionDelegate: AnyObject {
    func didCreateNewCategory(_ name: String)
}

// MARK: - CreatingCollectionViewController

class CreatingCollectionViewController: UIViewController {
    
    // MARK: - Properties
    
    private let buttonDoneCollection = UIButton()
    private let textField = UITextField()
    
    weak var delegate: CreatingCollectionDelegate?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .dynamicBackground
        
        setupNavigationBar()
        setUpCreatingCollectionTableViewController()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //AnalyticsService.shared.logEvent(.open(screen: "CreateCategory"))
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        //AnalyticsService.shared.logEvent(.close(screen: "CreateCategory"))
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
            action: #selector(backTapped)
        )
        
        navigationItem.leftBarButtonItem?.tintColor = .dynamicButtonBackground
        navigationItem.leftBarButtonItem?.title = ""
        
        navigationItem.title = L10n.New.Category.title
    }
    
    func setUpCreatingCollectionTableViewController() {
        textField.textColor = .dynamicTitleColor
        textField.attributedPlaceholder = NSAttributedString(
            string: L10n.SearchBar.nameCategory,
            attributes: [.foregroundColor: UIColor.ypGray]
        )
        textField.backgroundColor = .dynamicTextFieldOrTableViewBackgroundColor
        textField.layer.cornerRadius = 16
        textField.layer.masksToBounds = true
        
        let leftPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: textField.frame.height))
        textField.leftView = leftPaddingView
        textField.leftViewMode = .always
        
        textField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(textField)
        
        NSLayoutConstraint.activate([
            textField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 28),
            textField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            textField.heightAnchor.constraint(equalToConstant: 75)
        ])
        
        buttonDoneCollection.setTitle(L10n.Done.button, for: .normal)
        buttonDoneCollection.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        buttonDoneCollection.setTitleColor(.dynamicButtonTitle, for: .normal)
        buttonDoneCollection.backgroundColor = .ypGray
        buttonDoneCollection.layer.cornerRadius = 16
        buttonDoneCollection.isEnabled = false
        buttonDoneCollection.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(buttonDoneCollection)
        
        NSLayoutConstraint.activate([
            buttonDoneCollection.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            buttonDoneCollection.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            buttonDoneCollection.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            buttonDoneCollection.heightAnchor.constraint(equalToConstant: 60)
        ])
        textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        buttonDoneCollection.addTarget(self, action: #selector(buttonDoneCollectionTapped), for: .touchUpInside)
    }
    
    // MARK: - Actions
    
    @objc
    func backTapped() {
        //AnalyticsService.shared.logEvent(.click(screen: "CreateCategory", item: "back"))
        navigationController?.popViewController(animated: true)
    }
    
    @objc
    func textFieldDidChange() {
        let hasText = !(textField.text ?? "").trimmingCharacters(in: .whitespaces).isEmpty
        buttonDoneCollection.isEnabled = hasText
        buttonDoneCollection.backgroundColor = hasText ? .dynamicButtonBackground : .ypGray
    }
    
    @objc
    func buttonDoneCollectionTapped() {
        //AnalyticsService.shared.logEvent(.click(screen: "CreateCategory", item: "done"))
        let categoryName = textField.text?.trimmingCharacters(in: .whitespaces) ?? ""
        delegate?.didCreateNewCategory(categoryName)
        navigationController?.popViewController(animated: true)
    }
}
