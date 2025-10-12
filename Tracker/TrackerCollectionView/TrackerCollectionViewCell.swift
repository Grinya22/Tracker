import UIKit

// MARK: - TrackerCollectionViewCellDelegate

protocol TrackerCollectionViewCellDelegate: AnyObject {
    func didTapTrackerPlusButton(trackerId: UUID, date: Date, isCompleted: Bool)
    func didTapPinButton(trackerId: UUID)
    func didTapEditButton(trackerId: UUID)
    func didTapDeleteButton(trackerId: UUID)
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
    private var isPinnedMark = UIImageView()
    private var completedDays = 0
    private var currentDate: Date = Date()
    private var color: UIColor = .ypWhite
    private var trackerID: UUID = UUID()
    
    weak var delegate: TrackerCollectionViewCellDelegate?
    
    private var isPinned = false
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setUpUI()
        setUpConstraints()
        setUpContextMenuInteraction()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        // анимка лагала
        // Сброс визуальных элементов
        emojiLabel.text = nil
        titleLabel.text = nil
        dayCountLabel.text = nil
        topView.backgroundColor = nil
        plusButton.backgroundColor = nil
        plusButton.setImage(nil, for: .normal)
        plusButton.transform = .identity
        
        // Сброс локальных переменных
        isCompletedPlusButton = false
        completedDays = 0
        currentDate = Date()
        color = .ypWhite
        trackerID = UUID()
        isPinned = false
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
        topView.addSubview(circleViewEmoji)
        
        emojiLabel.font = .systemFont(ofSize: 14)
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        topView.addSubview(emojiLabel)
        
        isPinnedMark.image = UIImage(named: "PinMark")
        isPinnedMark.contentMode = .scaleAspectFill
        isPinnedMark.translatesAutoresizingMaskIntoConstraints = false
        topView.addSubview(isPinnedMark)
        
        titleLabel.font = .systemFont(ofSize: 12, weight: .medium)
        titleLabel.numberOfLines = 2
        titleLabel.textColor = .ypWhite
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        topView.addSubview(titleLabel)
        
        // Настройка bottomView
        bottomView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(bottomView)
        
        dayCountLabel.font = .systemFont(ofSize: 12)
        dayCountLabel.translatesAutoresizingMaskIntoConstraints = false
        bottomView.addSubview(dayCountLabel)
        
        plusButton.layer.cornerRadius = 17
        plusButton.clipsToBounds = true
        plusButton.tintColor = .white
        let config = UIImage.SymbolConfiguration(pointSize: 12, weight: .semibold)
        plusButton.setImage(UIImage(systemName: "plus", withConfiguration: config), for: .normal)
        plusButton.addTarget(self, action: #selector(didTapPlusButton(_:)), for: .touchUpInside)
        plusButton.translatesAutoresizingMaskIntoConstraints = false
        bottomView.addSubview(plusButton)
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
            
            isPinnedMark.centerYAnchor.constraint(equalTo: circleViewEmoji.centerYAnchor),
            isPinnedMark.trailingAnchor.constraint(equalTo: topView.trailingAnchor, constant: -4),
            
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
    
    func configure(emoji: String, title: String, completedDays: Int, isCompletedToday: Bool, date: Date, color: UIColor, trackerID: UUID, isPinned: Bool) {
        emojiLabel.text = emoji
        titleLabel.text = title
        dayCountLabel.text = L10n.Day.count(completedDays)

        self.completedDays = completedDays
        self.isCompletedPlusButton = isCompletedToday
        self.currentDate = date
        self.color = color
        self.trackerID = trackerID
        self.isPinned = isPinned
        
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
        
        updatePinVisibility()
    }
    
    // MARK: - Actions
    
    @objc
    func didTapPlusButton(_ sender: UIButton) {
        //AnalyticsService.shared.logEvent(.click(screen: "TrackerCell", item: "plus_button"))
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
    }
    
    // MARK: Helper Methods

    func updatePinVisibility() {
        isPinnedMark.isHidden = !isPinned
    }
}

extension TrackerCollectionViewCell: UIContextMenuInteractionDelegate {
    func setUpContextMenuInteraction() {
        let interaction = UIContextMenuInteraction(delegate: self)
        topView.addInteraction(interaction)
    }
    
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(
            identifier: nil,
            previewProvider: nil
        ) { _ in
            let pinTitle = self.isPinned ? "Открепить" : "Закрепить"

            let pinAction = UIAction(title: pinTitle) { [weak self] _ in
                guard let self = self else { return }
                self.delegate?.didTapPinButton(trackerId: self.trackerID)
            }
            
            let editAction = UIAction(title: "Редактировать") { [weak self] _ in
                //AnalyticsService.shared.logEvent(.click(screen: "TrackerCell", item: "edit"))
                guard let self = self else { return }
                self.delegate?.didTapEditButton(trackerId: self.trackerID)
            }
            
            let deleteAction = UIAction(title: "Удалить", attributes: .destructive) { [weak self] _ in
                //AnalyticsService.shared.logEvent(.click(screen: "TrackerCell", item: "delete"))
                guard let self = self else { return }
                self.delegate?.didTapDeleteButton(trackerId: self.trackerID)
            }
            
            return UIMenu(title: "", children: [pinAction, editAction, deleteAction])
        }
    }
    
}
