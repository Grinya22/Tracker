import UIKit

// MARK: - TrackerCollectionViewCellDelegate

protocol TrackerCollectionViewCellDelegate: AnyObject {
    func didTapTrackerPlusButton(trackerId: UUID, date: Date, isCompleted: Bool)
}

// MARK: - TrackerCollectionViewCell

class TrackerCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Properties
    
    private let topView = UIView()
    private let circleViewEmoji = UIView()
    private let emojiLabel = UILabel()
    private let titleLabel = UILabel()
    
    private let bottomView = UIView()
    private let dayCountLabel = UILabel()
    private let plusButton = UIButton(type: .custom)
    
    private var isCompletedPlusButton = false
    private var completedDays = 0
    private var currentDate: Date = Date()
    private var color: UIColor = .ypWhite
    private var trackerID: UUID = UUID()
    
    weak var delegate: TrackerCollectionViewCellDelegate?
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setUpUI()
        setUpConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup UI
    
    func setUpUI() {
        // Настройка topView
        topView.layer.cornerRadius = 16
        topView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(topView)
        
        circleViewEmoji.layer.cornerRadius = 12
        circleViewEmoji.backgroundColor = UIColor.ypLightGray.withAlphaComponent(0.5)
        circleViewEmoji.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(circleViewEmoji)
        
        emojiLabel.font = .systemFont(ofSize: 14)
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(emojiLabel)
        
        titleLabel.font = .systemFont(ofSize: 12, weight: .medium)
        titleLabel.numberOfLines = 2
        titleLabel.textColor = .ypWhite
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)
        
        // Настройка bottomView
        bottomView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(bottomView)
        
        dayCountLabel.font = .systemFont(ofSize: 12)
        dayCountLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(dayCountLabel)
        
        plusButton.layer.cornerRadius = 17
        plusButton.clipsToBounds = true
        plusButton.tintColor = .white
        let config = UIImage.SymbolConfiguration(pointSize: 12, weight: .semibold)
        plusButton.setImage(UIImage(systemName: "plus", withConfiguration: config), for: .normal)
        plusButton.addTarget(self, action: #selector(didTapPlusButton(_:)), for: .touchUpInside)
        plusButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(plusButton)

    }
    
    func setUpConstraints() {
        NSLayoutConstraint.activate([
            // Настройка topView
            topView.topAnchor.constraint(equalTo: contentView.topAnchor),
            topView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            topView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            topView.heightAnchor.constraint(equalToConstant: 90),
            
            circleViewEmoji.topAnchor.constraint(equalTo: topView.topAnchor, constant: 12),
            circleViewEmoji.leadingAnchor.constraint(equalTo: topView.leadingAnchor, constant: 12),
            circleViewEmoji.heightAnchor.constraint(equalToConstant: 24),
            circleViewEmoji.widthAnchor.constraint(equalToConstant: 24),
            
            emojiLabel.centerYAnchor.constraint(equalTo: circleViewEmoji.centerYAnchor),
            emojiLabel.centerXAnchor.constraint(equalTo: circleViewEmoji.centerXAnchor),
            
            titleLabel.leadingAnchor.constraint(equalTo: topView.leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: topView.trailingAnchor, constant: -12),
            titleLabel.bottomAnchor.constraint(equalTo: topView.bottomAnchor, constant: -12),
            
            // Настройка bottomView
            bottomView.topAnchor.constraint(equalTo: topView.bottomAnchor),
            bottomView.leadingAnchor.constraint(equalTo: topView.leadingAnchor),
            bottomView.trailingAnchor.constraint(equalTo: topView.trailingAnchor),
            bottomView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            bottomView.heightAnchor.constraint(equalToConstant: 58),
            
            dayCountLabel.topAnchor.constraint(equalTo: bottomView.topAnchor, constant: 16),
            dayCountLabel.leadingAnchor.constraint(equalTo: bottomView.leadingAnchor, constant: 12),
            
            plusButton.centerYAnchor.constraint(equalTo: dayCountLabel.centerYAnchor),
            plusButton.trailingAnchor.constraint(equalTo: bottomView.trailingAnchor, constant: -12),
            plusButton.heightAnchor.constraint(equalToConstant: 34),
            plusButton.widthAnchor.constraint(equalToConstant: 34)
            

        ])
    }
    
    // MARK: - Configuration
    
    func configure(emoji: String, title: String, completedDays: Int, isCompletedToday: Bool, date: Date, color: UIColor, trackerID: UUID) {
        emojiLabel.text = emoji
        titleLabel.text = title
        dayCountLabel.text = "\(completedDays) \(pluralForm(for: completedDays))"
        
        self.completedDays = completedDays
        self.isCompletedPlusButton = isCompletedToday
        self.currentDate = date
        self.color = color
        self.trackerID = trackerID
        
        topView.backgroundColor = color
        plusButton.backgroundColor = color
        
        if isCompletedToday {
            plusButton.setImage(UIImage(named: "ChekMark"), for: .normal)
            plusButton.backgroundColor = color.withAlphaComponent(0.3)
        } else {
            let config = UIImage.SymbolConfiguration(pointSize: 12, weight: .semibold)
            let plusImage = UIImage(systemName: "plus", withConfiguration: config)
            plusButton.setImage(plusImage, for: .normal)
            plusButton.backgroundColor = color
        }
    }
    
    // MARK: - Helper Methods
    
    private func pluralForm(for count: Int) -> String {
        let remainder10 = count % 10
        let remainder100 = count % 100
        if remainder100 >= 11 && remainder100 <= 14 {
            return "дней"
        }
        switch remainder10 {
        case 1: return "день"
        case 2...4: return "дня"
        default: return "дней"
        }
    }
    
    // MARK: - Actions
    
    @objc
    func didTapPlusButton(_ sender: UIButton) {
        guard Calendar.current.isDateInToday(currentDate) || currentDate < Date() else {
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.error)
            return
        }

        UIView.animate(withDuration: 0.1,
                       animations: {
            sender.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }, completion: { _ in
            UIView.animate(withDuration: 0.1) {
                sender.transform = .identity
            }
        })

        isCompletedPlusButton.toggle()
        
        delegate?.didTapTrackerPlusButton(trackerId: trackerID, date: currentDate, isCompleted: isCompletedPlusButton)

        if isCompletedPlusButton {
            completedDays += 1
            plusButton.setImage(UIImage(named: "ChekMark"), for: .normal)
            plusButton.backgroundColor = color.withAlphaComponent(0.3)
        } else {
            completedDays = max(0, completedDays - 1)
            let config = UIImage.SymbolConfiguration(pointSize: 12, weight: .semibold)
            let plusImage = UIImage(systemName: "plus", withConfiguration: config)
            plusButton.setImage(plusImage, for: .normal)
            plusButton.backgroundColor = color
        }

        dayCountLabel.text = "\(completedDays) \(pluralForm(for: completedDays))"
    }
}

