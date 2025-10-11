import UIKit

// MARK: - ScheduleTableViewCell

class ScheduleTableViewCell: UITableViewCell {
    
    // MARK: - Properties
    
    static let reuseIdentifier = "ScheduleTableViewCell"
    
    let dayLabel = UILabel()
    let daySwitch = UISwitch()
    
    var switchChanged: ((Bool) -> Void)?
    
    // MARK: - Initialization
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = .clear // Ячейка прозрачная, чтобы виден был серый фон таблицы
        
        dayLabel.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        dayLabel.textColor = .ypBlack
        dayLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(dayLabel)
        
        daySwitch.translatesAutoresizingMaskIntoConstraints = false
        daySwitch.onTintColor = .systemBlue // Устанавливаем синий цвет для переключателя
        contentView.addSubview(daySwitch)
        
        NSLayoutConstraint.activate([
            dayLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            dayLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            daySwitch.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            daySwitch.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
        
        daySwitch.addTarget(self, action: #selector(switchValueChanged), for: .valueChanged)
    }
    
    // MARK: - Actions
    
    @objc
    func switchValueChanged() {
        switchChanged?(daySwitch.isOn)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
