import UIKit

// MARK: - TrackerCollectionView

final class TrackerCollectionView: UIView {
    
    // MARK: - Properties
    
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    
    // MARK: - Setup UI
    
    func setUpCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 8 // Отступ между ячейками в строке
        layout.minimumLineSpacing = 0 // Отступ между строками
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0) // Отступы по краям
        collectionView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 49, right: 0)
        collectionView.scrollIndicatorInsets = collectionView.contentInset
        collectionView.isScrollEnabled = true
        collectionView.collectionViewLayout = layout
        addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        collectionView.register(TrackerCollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        
        collectionView.register(SupplementaryView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: "Header")

        collectionView.allowsMultipleSelection = false
    }
}
