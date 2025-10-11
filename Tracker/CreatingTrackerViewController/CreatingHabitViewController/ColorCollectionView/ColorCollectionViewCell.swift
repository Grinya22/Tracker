import UIKit

// MARK: - ColorCollectionViewCell

class ColorCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Properties
    
    static let reuseIdentifier = "ColorCell"
    
    var borderView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 14
        view.layer.masksToBounds = true
        view.layer.borderColor = UIColor.ypWhite.cgColor
        return view
    }()
    
    var colorView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 10
        view.layer.masksToBounds = true
        return view
    }()
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(borderView)
        borderView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            borderView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            borderView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            borderView.widthAnchor.constraint(equalToConstant: 58),
            borderView.heightAnchor.constraint(equalToConstant: 58)
        ])
        
        contentView.addSubview(colorView)
        colorView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            colorView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            colorView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            colorView.widthAnchor.constraint(equalToConstant: 46),
            colorView.heightAnchor.constraint(equalToConstant: 46)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

