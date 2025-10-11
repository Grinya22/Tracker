import UIKit

// MARK: - TrackerOptionsTableViewDelegate

protocol TrackerOptionsTableViewDelegate: AnyObject {
    func didSelectOption(at index: Int)
}

// MARK: - TrackerOptionsTableView

class TrackerOptionsTableView: UIView, UITableViewDataSource, UITableViewDelegate {
    
    // MARK: - Properties
    
    private let tableView = UITableView()
    private var itemsOfTableView: [String] = []
    private var categorySubtitle: String?
    private var scheduleSubtitle: String?
    
    weak var delegate: TrackerOptionsTableViewDelegate?
    
    // MARK: - Initialization

    init(itemsOfTableView: [String]) {
        self.itemsOfTableView = itemsOfTableView
        super.init(frame: .zero)
        setupTableView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup UI
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = .ypBackground
        tableView.layer.cornerRadius = 16
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16) // Убираем отступы для разделителей
        tableView.separatorStyle = .singleLine // Оставляем только линии между ячейками
        tableView.isScrollEnabled = false
        addSubview(tableView)
        
        // Ограничения относительно текущего TrackerOptionsTableView
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: self.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemsOfTableView.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "Cell")
        cell.textLabel?.text = itemsOfTableView[indexPath.row]
        cell.textLabel?.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        cell.textLabel?.textColor = .ypBlack
        cell.backgroundColor = .clear
        cell.accessoryType = .disclosureIndicator // Стрелка вправо
        
        if indexPath.row == 0 {
            cell.detailTextLabel?.text = categorySubtitle
            cell.detailTextLabel?.textColor = .ypGray
            cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 17)
        } else if indexPath.row == 1 {
            cell.detailTextLabel?.text = scheduleSubtitle
            cell.detailTextLabel?.textColor = .ypGray
            cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 17)
        } else {
            cell.detailTextLabel?.text = nil
        }
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let lastSectionIndex = tableView.numberOfSections - 1
        let lastRowIndex = tableView.numberOfRows(inSection: lastSectionIndex) - 1
        
        if indexPath.section == lastSectionIndex && indexPath.row == lastRowIndex {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: tableView.bounds.width)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.didSelectOption(at: indexPath.row)
    }
    
    // MARK: - Helper Methods
    
    func deselectSelectedRow() {
        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    func updateCategorySubtitle(_ subtitle: String?) {
        self.categorySubtitle = subtitle
        print("Подзаголовок: \(subtitle ?? "нет")")
        tableView.reloadData()
    }
    
    func updateScheduleSubtitle(_ subtitle: String?) {
        self.scheduleSubtitle = subtitle
        print("Подзаголовок: \(subtitle ?? "нет")")
        tableView.reloadData()
    }
}



