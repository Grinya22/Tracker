import UIKit

// MARK: - ColorSelectionDelegate

// Протокол для уведомления о выборе цвета
protocol ColorSelectionDelegate: AnyObject {
    func didSelectColor(_ color: UIColor?)
}

// MARK: - ColorCollectionView

class ColorCollectionView: UIView, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    // MARK: - Properties
    
    weak var delegate: ColorSelectionDelegate?
    let collectionView: UICollectionView
    
    override var intrinsicContentSize: CGSize {
        layoutIfNeeded()
        return CGSize(width: UIView.noIntrinsicMetric,
                      height: collectionView.collectionViewLayout.collectionViewContentSize.height)
    }
    
    let colors: [UIColor] = [
        .ypRed, .ypOrange, .ypBlue, .ypViolet, .ypGreen, .ypPink, .ypLightBlue, .ypMint,
        .ypDarkViolet, .ypCoral, .ypLightOrange, .ypSoftGreen, .ypDeepBlue, .ypPurple,
        .ypStrongViolet, .ypLightViolet, .ypLightGreen, .ypNeonGreen
    ]
    
    private var selectedIndexPath: IndexPath?
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        self.collectionView = {
            let layout = UICollectionViewFlowLayout()
            layout.minimumLineSpacing = 2
            layout.minimumInteritemSpacing = 2
            layout.scrollDirection = .vertical
            let collectionView = UICollectionView(
                frame: .zero,
                collectionViewLayout: layout
            )
            collectionView.register(ColorCollectionViewCell.self, forCellWithReuseIdentifier: ColorCollectionViewCell.reuseIdentifier)
            collectionView.backgroundColor = .clear
            collectionView.tag = 2
            return collectionView
        }()
        
        super.init(frame: frame)
        setupCollectionView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup UI
    
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
        return colors.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ColorCollectionViewCell.reuseIdentifier, for: indexPath) as! ColorCollectionViewCell
        //let color = colors[indexPath.row]
        cell.colorView.backgroundColor = colors[indexPath.row]
        return cell
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 58, height: 58)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Если уже была выбрана — сбросить и выйти
        if selectedIndexPath == indexPath {
            collectionView.deselectItem(at: indexPath, animated: false)
            if let cell = collectionView.cellForItem(at: indexPath) as? ColorCollectionViewCell {
                UIView.animate(withDuration: 0.2) {
                    cell.borderView.layer.borderWidth = 0
                    cell.borderView.layer.borderColor = UIColor.clear.cgColor
                }
            }
            selectedIndexPath = nil
            delegate?.didSelectColor(nil)
            return
        }

        // Сброс предыдущего выбора
        if let previous = selectedIndexPath,
           let previousCell = collectionView.cellForItem(at: previous) as? ColorCollectionViewCell {
            UIView.animate(withDuration: 0.2) {
                previousCell.borderView.layer.borderWidth = 0
                previousCell.borderView.layer.borderColor = UIColor.clear.cgColor
            }
            collectionView.deselectItem(at: previous, animated: false)
        }

        // Установка нового выбора
        if let cell = collectionView.cellForItem(at: indexPath) as? ColorCollectionViewCell {
            UIView.animate(withDuration: 0.2) {
                cell.borderView.layer.borderWidth = 3
                cell.borderView.layer.borderColor = self.colors[indexPath.row].withAlphaComponent(0.3).cgColor
            }
        }

        selectedIndexPath = indexPath
        let selectedColor = colors[indexPath.item]
        delegate?.didSelectColor(selectedColor)
    }
}
