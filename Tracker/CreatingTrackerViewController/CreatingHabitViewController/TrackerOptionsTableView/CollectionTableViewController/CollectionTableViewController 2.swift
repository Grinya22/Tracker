import UIKit

// MARK: - CollectionTableViewControllerDelegate

protocol CollectionTableViewControllerDelegate: AnyObject {
    func didSelectOption(_ category: String?)
}

// MARK: - CollectionTableViewController

final class CollectionTableViewController: UIViewController, CreatingCollectionDelegate, UITableViewDataSource, UITableViewDelegate, UICollectionViewDelegate {
    
    // MARK: - Properties
    
    let tableView = UITableView()
    let placeholderImage = UIImageView()
    let placeholderLabel = UILabel()
    let buttonAddtNewCollection = UIButton()
    
    weak var delegate: CollectionTableViewControllerDelegate?
    
    var categories: [TrackerCategoryCoreData] = []
    private let categoryStore = TrackerCategoryStore()
    private var selectedCategoryIndex: Int?
    
    var selectedCategoryTitle: String?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .dynamicBackground
        
        setupNavigationBar()
        loadCategories()
        updatePlaceholderVisibility()
        setUpCollectionTableViewController()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //AnalyticsService.shared.logEvent(.open(screen: "CategorySelection"))
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        //AnalyticsService.shared.logEvent(.close(screen: "CategorySelection"))
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
        navigationItem.backBarButtonItem?.title = ""
        
        navigationItem.title = L10n.category
    }
    
    func setUpCollectionTableViewController() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "CategoryCell")
        tableView.layer.cornerRadius = 16
        tableView.backgroundColor = .dynamicTextFieldOrTableViewBackgroundColor
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.separatorColor = .ypGray
        tableView.tableHeaderView = UIView(frame: .zero)
        tableView.separatorStyle = .singleLine
        tableView.isScrollEnabled = false
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        view.addSubview(buttonAddtNewCollection)
        
        let heightConstraint = tableView.heightAnchor.constraint(equalToConstant: 0)
        heightConstraint.priority = .defaultHigh
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 28),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            heightConstraint
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
        
        placeholderLabel.text = L10n.Empty.category
        placeholderLabel.textAlignment = .center
        placeholderLabel.textColor = .dynamicTitleColor
        placeholderLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        placeholderLabel.numberOfLines = 0
        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(placeholderLabel)
        
        NSLayoutConstraint.activate([
            placeholderLabel.topAnchor.constraint(equalTo: placeholderImage.bottomAnchor, constant: 8),
            placeholderLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            placeholderLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16)
        ])
        
        buttonAddtNewCollection.backgroundColor = .dynamicButtonBackground
        buttonAddtNewCollection.setTitle(L10n.AddCategory.button, for: .normal)
        buttonAddtNewCollection.setTitleColor(.dynamicButtonTitle, for: .normal)
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
        
        updateTableViewHeight()
    }
    
    // MARK: - Actions
    
    @objc
    func backTapped() {
        //AnalyticsService.shared.logEvent(.click(screen: "CategorySelection", item: "back"))
        navigationController?.popViewController(animated: true)
    }
    
    @objc
    func buttonAddtNewCollectionTapped() {
        //AnalyticsService.shared.logEvent(.click(screen: "CategorySelection", item: "add_category"))
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
            let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
            cell.textLabel?.text = L10n.error
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        
        cell.textLabel?.text = categories[indexPath.row].title
        cell.backgroundColor = .clear
        cell.textLabel?.textColor = .dynamicTitleColor
        cell.accessoryType = indexPath.row == selectedCategoryIndex ? .checkmark : .none
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //AnalyticsService.shared.logEvent(.click(screen: "CategorySelection", item: "category_\(indexPath.row)"))
        if selectedCategoryIndex == indexPath.row {
            selectedCategoryIndex = nil
            selectedCategoryTitle = nil
            delegate?.didSelectOption(nil)
        } else {
            selectedCategoryIndex = indexPath.row
            selectedCategoryTitle = categories[indexPath.row].title
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
                    UIAction(title: L10n.Edit.button) { _ in
                        //AnalyticsService.shared.logEvent(.click(screen: "CategorySelection", item: "edit"))
                        let editCollectionVC = EditCollectionViewController()
                        editCollectionVC.delegate = self
                        editCollectionVC.categoryToEdit = categoryToDelete
                        self.navigationController?.pushViewController(editCollectionVC, animated: true)
                    },
                    UIAction(title: L10n.Delete.button, attributes: .destructive) { _ in
                        //AnalyticsService.shared.logEvent(.click(screen: "CategorySelection", item: "delete"))
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
    
    private func updateTableViewHeight() {
        let rowHeight: CGFloat = 75
        let numberOfRows = CGFloat(categories.count)
        let totalHeight = rowHeight * numberOfRows
        let maxHeight = view.safeAreaLayoutGuide.layoutFrame.height - 28 - 60 - 44 - 16
        
        tableView.isScrollEnabled = totalHeight > maxHeight
        
        if let existingConstraint = tableView.constraints.first(where: { $0.firstAnchor == tableView.heightAnchor }) {
            existingConstraint.constant = min(totalHeight, maxHeight)
        } else {
            let heightConstraint = tableView.heightAnchor.constraint(equalToConstant: min(totalHeight, maxHeight))
            heightConstraint.isActive = true
        }

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
        
        let deleteConfirmAction = UIAlertAction(title: L10n.Delete.button, style: .destructive) { [weak self] _ in
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
        
        let cancelAction = UIAlertAction(title: L10n.Cancel.button, style: .cancel) { [weak self] _ in
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
                message: L10n.Error.Warning.message,
                preferredStyle: .actionSheet
            )
            
            let deleteConfirmAction = UIAlertAction(title: L10n.Delete.button, style: .destructive) { [weak self] _ in
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
                        title: L10n.error,
                        message: L10n.Error.Message.categoryortracker,
                        preferredStyle: .alert
                    )
                    errorAlert.addAction(UIAlertAction(title: L10n.Ok.button, style: .default))
                    self.present(errorAlert, animated: true)
                }
            }
            
            let cancelAction = UIAlertAction(title: L10n.Cancel.button, style: .cancel) { [weak self] _ in
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
            
        } catch {
            print("Ошибка при удалении категории: \(error)")
            let alert = UIAlertController(
                title: L10n.error,
                message: L10n.Error.Message.category,
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "ОК", style: .default))
            present(alert, animated: true)
        }
        
        updateTableViewHeight()
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
        
        updateTableViewHeight()
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
        
        if let selectedTitle = selectedCategoryTitle,
           let index = categories.firstIndex(where: { $0.title == selectedTitle }) {
            selectedCategoryIndex = index
        } else {
            selectedCategoryIndex = nil
        }
        
        tableView.reloadData()
    }
}

extension CollectionTableViewController: EditCollectionDelegate {
    func didUpdateCategory(_ category: TrackerCategoryCoreData, newName: String) {
        category.title = newName
        CoreDataStack.shared.saveContext()
        tableView.reloadData()
    }
}
