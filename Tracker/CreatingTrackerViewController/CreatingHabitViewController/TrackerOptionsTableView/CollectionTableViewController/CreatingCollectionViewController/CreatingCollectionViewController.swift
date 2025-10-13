import UIKit

protocol CreatingCollectionDelegate: AnyObject {
    func didCreateNewCategory(_ name: String)
}

class CreatingCollectionViewController: UIViewController {
    private let buttonDoneCollection = UIButton()
    private let textField = UITextField()
    
    weak var delegate: CreatingCollectionDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .ypWhite
        
        setupNavigationBar()
        setUpCreatingCollectionTableViewController()
    }
    
    func setupNavigationBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(backTapped)
        )
        
        navigationItem.leftBarButtonItem?.tintColor = .ypBlack
        navigationItem.leftBarButtonItem?.title = ""
        
        navigationItem.title = "Новая категория"
    }
    
    func setUpCreatingCollectionTableViewController() {
        textField.textColor = .ypBlack
        textField.attributedPlaceholder = NSAttributedString(
            string: "Введите название категории",
            attributes: [.foregroundColor: UIColor.ypGray]
        )
        textField.backgroundColor = .ypBackground
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
        
        buttonDoneCollection.setTitle("Готово", for: .normal)
        buttonDoneCollection.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        buttonDoneCollection.setTitleColor(.ypWhite, for: .normal)
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
    
    @objc
    func backTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc
    func textFieldDidChange() {
        let hasText = !(textField.text ?? "").trimmingCharacters(in: .whitespaces).isEmpty
        buttonDoneCollection.isEnabled = hasText
        buttonDoneCollection.backgroundColor = hasText ? .ypBlack : .ypGray
    }
    
    @objc
    func buttonDoneCollectionTapped() {
        let categoryName = textField.text?.trimmingCharacters(in: .whitespaces) ?? ""
        delegate?.didCreateNewCategory(categoryName)
        navigationController?.popViewController(animated: true)
    }
}
