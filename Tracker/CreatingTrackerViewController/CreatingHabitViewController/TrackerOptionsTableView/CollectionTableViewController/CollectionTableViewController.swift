import UIKit

// MARK: - CollectionTableViewControllerDelegate

protocol CollectionTableViewControllerDelegate: AnyObject {
    func didSelectOption(_ category: String?)
}

// MARK: - CollectionTableViewController

final class CollectionTableViewController: UIViewController, CreatingCollectionDelegate, UITableViewDataSource, UITableViewDelegate {
    
    // MARK: - Properties
    
    let tableView = UITableView()
    let placeholderImage = UIImageView()
    let placeholderLabel = UILabel()
    let buttonAddtNewCollection = UIButton()
    
    weak var delegate: CollectionTableViewControllerDelegate?
    
    var categories: [TrackerCategoryCoreData] = []
    private let categoryStore = TrackerCategoryStore()
    private var selectedCategoryIndex: Int?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .ypWhite
        
        setupNavigationBar()
        loadCategories()
        updatePlaceholderVisibility()
        setUpCollectionTableViewController()
    }
    
    // MARK: - Setup UI
    
    func setupNavigationBar() {
        navigationController?.navigationBar.barTintColor = .ypWhite // Убедитесь, что фон навигатора белый
        navigationController?.navigationBar.shadowImage = UIImage() // Убираем разделитель под навигатором
        //        Свойство shadowImage — это изображение, которое используется для рендеринга тени под UINavigationBar. По умолчанию iOS предоставляет стандартное изображение для этой тени.
        //        Когда вы устанавливаете пустое UIImage(), система перестаёт рисовать что-либо в этой области, оставляя только фон NavigationBar (определяемый barTintColor).
        
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
        tableView.tableHeaderView = UIView(frame: .zero)
        tableView.isScrollEnabled = true
        tableView.separatorStyle = .singleLine
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        view.addSubview(buttonAddtNewCollection)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 28),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: buttonAddtNewCollection.topAnchor, constant: -28)
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
        //        view.addSubview(buttonAddtNewCollection)
        
        NSLayoutConstraint.activate([
            buttonAddtNewCollection.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            buttonAddtNewCollection.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            buttonAddtNewCollection.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            buttonAddtNewCollection.heightAnchor.constraint(equalToConstant: 60)
        ])
        
        buttonAddtNewCollection.addTarget(self, action: #selector(buttonAddtNewCollectionTapped), for: .touchUpInside)
    }
    
    // MARK: - Actions
    
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
        guard indexPath.row < categories.count else {
            print("Ошибка: индекс \(indexPath.row) вне границ массива categories")
            let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
            cell.textLabel?.text = "Ошибка"
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        
        cell.textLabel?.text = categories[indexPath.row].title
        cell.backgroundColor = .clear
        cell.textLabel?.textColor = .ypBlack
        cell.accessoryType = indexPath.row == selectedCategoryIndex ? .checkmark : .none
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == categories.count - 1 {
            // Убираем разделитель под последней строкой
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: tableView.bounds.width)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if selectedCategoryIndex == indexPath.row {
            selectedCategoryIndex = nil
            delegate?.didSelectOption(nil)
        } else {
            selectedCategoryIndex = indexPath.row
            delegate?.didSelectOption(categories[indexPath.row].title)
        }
        tableView.reloadData()
    }
    
    internal func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        
        let categoryToDelete = categories[indexPath.row]
        
        return UIContextMenuConfiguration(
            identifier: nil, previewProvider: nil) { [weak self] _ in
                guard let self = self else { return nil }
                
                return UIMenu(children: [
                    UIAction(title: "Редактировать") { _ in
                        
                    },
                    UIAction(title: "Удалить", attributes: .destructive) { _ in
                        self.deselectSelectedRow()
                        self.showDeleteConfirmationAlert(for: categoryToDelete, at: indexPath)
                    }
                ])
            }
    }
    
    // MARK: - Helper Methods
    
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
    
    private func showDeleteConfirmationAlert(for category: TrackerCategoryCoreData, at indexPath: IndexPath) {
        // Проверяем валидность индекса.
        guard indexPath.row < categories.count else {
            print("Ошибка: индекс \(indexPath.row) вне границ массива categories")
            return
        }
        // Зачем: Чтобы избежать ошибок при работе с массивом.
        // Почему так: Индекс может быть неверным из-за асинхронных изменений.
        
        let alert = UIAlertController(
            title: nil,
            message: "Эта категория точно не нужна?",
            preferredStyle: .actionSheet
        )
        
        let deleteConfirmAction = UIAlertAction(title: "Удалить", style: .destructive) { [weak self] _ in
            guard let self = self else { return }
            
            guard indexPath.row < self.categories.count else {
                print("Ошибка: индекс \(indexPath.row) вне границ массива categories")
                return
            }
            
            // Проверяем, есть ли трекеры.
            if let trackers = category.trackers as? Set<TrackerCoreData>, !trackers.isEmpty {
                self.showDeleteConfirmationAlertOfAlert(category: category, at: indexPath)
                return
            } else {
                self.performDelete(category: category, at: indexPath)
            }
        }
        
        let cancelAction = UIAlertAction(title: "Отменить", style: .cancel) { [weak self] _ in
            print("Удаление отменено.")
        }
        
        alert.addAction(deleteConfirmAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    private func showDeleteConfirmationAlertOfAlert(category: TrackerCategoryCoreData, at indexPath: IndexPath) {
        // Проверяем валидность индекса.
        guard indexPath.row < categories.count else {
            print("Ошибка: индекс \(indexPath.row) вне границ массива categories")
            return
        }
        // Зачем: Для безопасности при работе с массивом.
        // Почему так: Защищает от ошибок при быстрых изменениях.
        
        if let trackers = category.trackers as? Set<TrackerCoreData>, !trackers.isEmpty {
            let alert = UIAlertController(
                title: nil,
                message: "Вы уврены что хотите удалить категорию, к ней привязаны трекеры.",
                preferredStyle: .actionSheet
            )
            
            let deleteConfirmAction = UIAlertAction(title: "Удалить", style: .destructive) { [weak self] _ in
                guard let self = self else { return }
                
                guard indexPath.row < self.categories.count else {
                    print("Ошибка: индекс \(indexPath.row) вне границ массива categories")
                    return
                }
                
                do {
                    let trackerStore = TrackerStore()
                    // Удаляем трекеры.
                    try trackerStore.deleteTrackers(for: category)
                    // Удаляем категорию.
                    self.performDelete(category: category, at: indexPath)
                    // Зачем: Реализует вторую алерту для удаления категории с трекерами.
                    // Почему так: Это твоя исходная логика, сохранена без изменений.
                } catch {
                    print("Ошибка при удалении трекеров или категории: \(error)")
                    let errorAlert = UIAlertController(
                        title: "Ошибка",
                        message: "Не удалось удалить категорию или трекеры. Попробуйте снова.",
                        preferredStyle: .alert
                    )
                    errorAlert.addAction(UIAlertAction(title: "ОК", style: .default))
                    self.present(errorAlert, animated: true)
                }
            }
            
            let cancelAction = UIAlertAction(title: "Отменить", style: .cancel) { [weak self] _ in
                print("Удаление отменено.")
            }
            
            alert.addAction(deleteConfirmAction)
            alert.addAction(cancelAction)
            
            present(alert, animated: true, completion: nil)
        }
    }
    
    private func performDelete(category: TrackerCategoryCoreData, at indexPath: IndexPath) {
        // Проверяем валидность индекса.
        guard indexPath.row < categories.count else {
            print("Ошибка: индекс \(indexPath.row) вне границ массива categories")
            return
        }
        // Зачем: Для защиты от ошибок при удалении.
        // Почему так: Массив может измениться асинхронно.
        
        do {
            // Если удаляемая категория была выбрана, сбрасываем выбор
            if selectedCategoryIndex == indexPath.row {
                selectedCategoryIndex = nil
                delegate?.didSelectOption(nil)
            }
            
            // Удаляем категорию через TrackerCategoryStore.
            try categoryStore.deleteCategory(category)
            
            // Удаляем из локального массива.
            categories.remove(at: indexPath.row)
            
            // Обновляем таблицу.
            tableView.performBatchUpdates({
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }, completion: { [weak self] _ in
                self?.updatePlaceholderVisibility()
            })
            // Зачем: Удаляет категорию и обновляет UI.
            // Почему так: Это твоя исходная логика с добавленной проверкой.
            
            print("Категория \"\(category.title ?? "")\" успешно удалена.")
        } catch {
            print("Ошибка при удалении категории: \(error)")
            let alert = UIAlertController(
                title: "Ошибка",
                message: "Не удалось удалить категорию. Попробуйте снова.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "ОК", style: .default))
            present(alert, animated: true)
        }
    }
    
    // MARK: - CreatingCollectionDelegate
    
    func didCreateNewCategory(_ name: String) {
        do {
            try categoryStore.addCategory(name)
            loadCategories() // Перезагружаем категории
            
            // Устанавливаем selectedCategoryIndex для новой категории
            if let newIndex = categories.firstIndex(where: { $0.title == name }) {
                selectedCategoryIndex = newIndex
                delegate?.didSelectOption(name)
                
                if !categories.isEmpty {
                    let indexPath = IndexPath(row: newIndex, section: 0)
                    tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
                }
            }
            
            updatePlaceholderVisibility()
        } catch {
            print("Ошибка добавления категории: \(error)")
        }
    }
    
    // MARK: - Persistence
    
    private func loadCategories() {
        do {
            let oldCount = categories.count
            categories = try categoryStore.fetchCategories()
            
            if let selectedIndex = selectedCategoryIndex, selectedIndex >= categories.count {
                selectedCategoryIndex = nil
                delegate?.didSelectOption(nil)
            }
            
            if oldCount != categories.count {
                tableView.reloadData()
            }
            updatePlaceholderVisibility()

        } catch {
            print("Ошибка загрузки категорий: \(error)")
        }
    }
}
