import UIKit

protocol CollectionTableViewControllerDelegate: AnyObject {
    func didSelectOption(_ category: String?)
}

final class CollectionTableViewController: UIViewController, CreatingCollectionDelegate, UITableViewDataSource, UITableViewDelegate {
    var tableView = UITableView()
    let placeholderImage = UIImageView()
    let placeholderLabel = UILabel()
    let buttonAddtNewCollection = UIButton()
    
    weak var delegate: CollectionTableViewControllerDelegate?
    
    private var categories: [String] = [] {
        didSet {
            saveCategories()
            updatePlaceholderVisibility()
            tableView.reloadData()
        }
    }
    
    private var selectedCategoryIndex: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .ypWhite
        
        setupNavigationBar()
        loadCategories()
        updatePlaceholderVisibility()
        setUpCollectionTableViewController()
    }
    
    func setupNavigationBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(backTapped)
        )
        
        navigationItem.leftBarButtonItem?.tintColor = .ypBlack
        navigationItem.backBarButtonItem?.title = ""
        
        navigationItem.title = "Категория"
    }
    
    func setUpCollectionTableViewController() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "CategoryCell")
        tableView.layer.cornerRadius = 16
        tableView.backgroundColor = .ypBackground
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.separatorStyle = .singleLine
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 28),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: 75)
        ])
        
        placeholderImage.image = UIImage(named: "TrakerSectionMainImage")
        placeholderImage.contentMode = .scaleAspectFill
        placeholderImage.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(placeholderImage)
        
        NSLayoutConstraint.activate([
            placeholderImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderImage.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            placeholderImage.widthAnchor.constraint(equalToConstant: 80),
            placeholderImage.heightAnchor.constraint(equalToConstant: 80)
        ])
        
        placeholderLabel.text = "Привычки и события можно \n объединить по смыслу"
        placeholderLabel.textAlignment = .center
        placeholderLabel.textColor = .ypBlack
        placeholderLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        placeholderLabel.numberOfLines = 0
        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(placeholderLabel)
        
        NSLayoutConstraint.activate([
            placeholderLabel.topAnchor.constraint(equalTo: placeholderImage.bottomAnchor, constant: 8),
            placeholderLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            placeholderLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16)
        ])
        
        buttonAddtNewCollection.setTitle("Добавить категорию", for: .normal)
        buttonAddtNewCollection.setTitleColor(.ypWhite, for: .normal)
        buttonAddtNewCollection.backgroundColor = .ypBlack
        buttonAddtNewCollection.layer.cornerRadius = 16
        buttonAddtNewCollection.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        buttonAddtNewCollection.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(buttonAddtNewCollection)
    
        NSLayoutConstraint.activate([
            buttonAddtNewCollection.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            buttonAddtNewCollection.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            buttonAddtNewCollection.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            buttonAddtNewCollection.heightAnchor.constraint(equalToConstant: 60)
        ])
        
        buttonAddtNewCollection.addTarget(self, action: #selector(buttonAddtNewCollectionTapped), for: .touchUpInside)
    }
    
    @objc
    func backTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc
    func buttonAddtNewCollectionTapped() {
        let creatingCollectionVC = CreatingCollectionViewController()
        creatingCollectionVC.delegate = self
        navigationController?.pushViewController(creatingCollectionVC, animated: true)
    }
    
    // MARK: - TableView DataSource & Delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        
        cell.textLabel?.text = categories[indexPath.row]
        cell.backgroundColor = .clear
        cell.textLabel?.textColor = .ypBlack
        cell.accessoryType = indexPath.row == selectedCategoryIndex ? .checkmark : .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let lastSectionIndex = tableView.numberOfSections - 1
        let lastRowIndex = tableView.numberOfRows(inSection: lastSectionIndex) - 1
        
        // Убираем разделитель над первой ячейкой
        if indexPath.row == 0 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: tableView.bounds.width)
        }
        // Убираем разделитель под последней ячейкой
        else if indexPath.section == lastSectionIndex && indexPath.row == lastRowIndex {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: tableView.bounds.width)
        }
        // Для единственного элемента тоже убираем разделитель
        else if categories.count == 1 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: tableView.bounds.width)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if selectedCategoryIndex == indexPath.row {
            selectedCategoryIndex = nil
            delegate?.didSelectOption(nil)
        } else {
            selectedCategoryIndex = indexPath.row
            delegate?.didSelectOption(categories[indexPath.row])
        }
        tableView.reloadData()
    }
    
    func deselectSelectedRow() {
        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    func updatePlaceholderVisibility() {
        let shouldShowPlaceholder = categories.isEmpty
        tableView.isHidden = shouldShowPlaceholder
        placeholderImage.isHidden = !shouldShowPlaceholder
        placeholderLabel.isHidden = !shouldShowPlaceholder
        
    }
    
    func didCreateNewCategory(_ name: String) {
        categories.append(name)
        selectedCategoryIndex = categories.count - 1
        updatePlaceholderVisibility()
        tableView.reloadData()
    }
    
    // MARK: - Сохранение и загрузка категорий
    private func saveCategories() {
        UserDefaults.standard.set(categories, forKey: "savedCategories")
    }
    
    private func loadCategories() {
        if let savedCategories = UserDefaults.standard.array(forKey: "savedCategories") as? [String] {
            categories = savedCategories
            
            if let lastIndex = selectedCategoryIndex, lastIndex < categories.count {
                delegate?.didSelectOption(categories[lastIndex])
            }
        }
    }
}




