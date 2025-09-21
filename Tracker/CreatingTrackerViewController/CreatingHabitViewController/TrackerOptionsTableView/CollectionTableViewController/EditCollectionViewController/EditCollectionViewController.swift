import UIKit

// MARK: - EditCollectionDelegate

protocol EditCollectionDelegate: AnyObject {
    func didUpdateCategory(_ category: TrackerCategoryCoreData, newName: String)

}

// MARK: - EditCollectionViewController

class EditCollectionViewController: UIViewController {
    
    // MARK: - Properties
    
    private let buttonDoneCollection = UIButton()
    private let textField = UITextField()
    
    weak var delegate: EditCollectionDelegate?
    
    var categoryToEdit: TrackerCategoryCoreData?
    
    let trackerCategoryStore = TrackerCategoryStore()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .dynamicBackground
        
        setupNavigationBar()
        setUpCreatingCollectionTableViewController()
        
        textField.becomeFirstResponder()
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
        
        navigationItem.title = "Редактирование категории"
    }
    
    func setUpCreatingCollectionTableViewController() {
        textField.text = categoryToEdit?.title
        
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
        buttonDoneCollection.backgroundColor = .dynamicButtonBackground
        buttonDoneCollection.layer.cornerRadius = 16
        buttonDoneCollection.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(buttonDoneCollection)
        
        NSLayoutConstraint.activate([
            buttonDoneCollection.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            buttonDoneCollection.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            buttonDoneCollection.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            buttonDoneCollection.heightAnchor.constraint(equalToConstant: 60)
        ])
        
        buttonDoneCollection.addTarget(self, action: #selector(buttonDoneCollectionTapped), for: .touchUpInside)
    }
    
    // MARK: - Actions
    
    @objc
    func backTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc
    func buttonDoneCollectionTapped() {
        let newCategoryName = textField.text?.trimmingCharacters(in: .whitespaces) ?? ""
        guard let categoryToEdit = categoryToEdit else { return }
        delegate?.didUpdateCategory(categoryToEdit, newName: newCategoryName)
        navigationController?.popViewController(animated: true)
    }
}
