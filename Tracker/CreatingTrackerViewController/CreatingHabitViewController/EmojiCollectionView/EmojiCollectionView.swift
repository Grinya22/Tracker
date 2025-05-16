import UIKit

// Протокол для уведомления о выборе эмодзи
protocol EmojiSelectionDelegate: AnyObject {
    func didSelectEmoji(_ emoji: String?)
}

class EmojiCollectionView: UIView, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
//    private let collectionView: UICollectionView = {
//        let layout = UICollectionViewFlowLayout()
//        layout.minimumLineSpacing = 8
//        layout.minimumInteritemSpacing = 8
//        layout.scrollDirection = .vertical
//        let collectionView = UICollectionView(
//            frame: .zero,
//            collectionViewLayout: layout
//        )
//        collectionView.register(EmojiCollectionViewCell.self, forCellWithReuseIdentifier: EmojiCollectionViewCell.reuseIdentifier)
//        collectionView.backgroundColor = .clear
//        collectionView.tag = 1
//        return collectionView
//    }()
    
    weak var delegate: EmojiSelectionDelegate?
    let collectionView: UICollectionView
    
    override var intrinsicContentSize: CGSize {
        layoutIfNeeded()
        return CGSize(width: UIView.noIntrinsicMetric,
                      height: collectionView.collectionViewLayout.collectionViewContentSize.height)
    }
    
    let emojis: [String] = ["🙂", "😻", "🌺", "🐶", "❤️", "😱", "😇", "😡", "🥶", "🤔", "🙌", "🍔", "🥦", "🏓", "🥇", "🎸", "🏝", "😪"]
    private var selectedIndexPath: IndexPath?
    
    override init(frame: CGRect) {
        self.collectionView = {
            let layout = UICollectionViewFlowLayout()
            layout.minimumLineSpacing = 8
            layout.minimumInteritemSpacing = 8
            layout.scrollDirection = .vertical
            let collectionView = UICollectionView(
                frame: .zero,
                collectionViewLayout: layout
            )
            collectionView.register(EmojiCollectionViewCell.self, forCellWithReuseIdentifier: EmojiCollectionViewCell.reuseIdentifier)
            collectionView.backgroundColor = .clear
            collectionView.tag = 1
            return collectionView
        }()
        super.init(frame: frame)
        setupCollectionView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCollectionView() {
        collectionView.isScrollEnabled = false
        collectionView.allowsMultipleSelection = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    // MARK: - UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return emojis.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EmojiCollectionViewCell.reuseIdentifier, for: indexPath) as! EmojiCollectionViewCell
        cell.emojiLabel.text = emojis[indexPath.row]
        cell.contentView.layer.cornerRadius = 16
        return cell
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 52, height: 52)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Если уже была выбрана — сбросить и выйти
        if selectedIndexPath == indexPath {
            collectionView.deselectItem(at: indexPath, animated: false)
            if let cell = collectionView.cellForItem(at: indexPath) as? EmojiCollectionViewCell {
                UIView.animate(withDuration: 0.2) {
                    cell.contentView.layer.backgroundColor = UIColor.clear.cgColor
                }
            }
            selectedIndexPath = nil
            delegate?.didSelectEmoji(nil)
            return
        }

        // Сброс предыдущего выбора
        if let previous = selectedIndexPath,
           let previousCell = collectionView.cellForItem(at: previous) as? EmojiCollectionViewCell {
            UIView.animate(withDuration: 0.2) {
                previousCell.contentView.layer.backgroundColor = UIColor.clear.cgColor
            }
            collectionView.deselectItem(at: previous, animated: false)
        }

        // Установка нового выбора
        if let cell = collectionView.cellForItem(at: indexPath) as? EmojiCollectionViewCell {
            UIView.animate(withDuration: 0.2) {
                cell.contentView.layer.backgroundColor = UIColor.ypLightGray.cgColor
            }
        }

        selectedIndexPath = indexPath
        let selectedEmoji = emojis[indexPath.item]
        delegate?.didSelectEmoji(selectedEmoji)
    }
}
