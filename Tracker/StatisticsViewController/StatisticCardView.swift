import UIKit

final class StatisticCardView: UIView {
    
    private let valueLabel = UILabel()
    private let titleLabel = UILabel()
    
    private var gradientLayer: CAGradientLayer?
    
    init(value: Int, title: String) {
        super.init(frame: .zero)
        setupUI(value: value, title: title)
        setupGradientBorder()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    // MARK: - Setup UI
    
    private func setupUI(value: Int, title: String) {
        backgroundColor = .clear
        layer.cornerRadius = 16
        clipsToBounds = true
        
        valueLabel.text = "\(value)"
        valueLabel.font = .systemFont(ofSize: 34, weight: .bold)
        
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 12, weight: .medium)
        titleLabel.textColor = .dynamicButtonBackground
        
        let stack = UIStackView(arrangedSubviews: [valueLabel, titleLabel])
        stack.axis = .vertical
        stack.spacing = 4
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)
        
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12),
            heightAnchor.constraint(equalToConstant: 90)
        ])
    }
    
    // MARK: - Helper Methods
    
    private func setupGradientBorder() {
        let gradient = CAGradientLayer()
        gradient.colors = [
            UIColor.ypRed.cgColor,
            UIColor.ypGreen.cgColor,
            UIColor.ypBlue.cgColor
        ]
        gradient.locations = [0, 0.5, 1]
        gradient.startPoint = CGPoint(x: 0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1, y: 0.5)
        gradient.frame = bounds
        
        let shape = CAShapeLayer()
        shape.path = UIBezierPath(roundedRect: bounds, cornerRadius: 16).cgPath
        shape.lineWidth = 2
        shape.fillColor = UIColor.clear.cgColor
        shape.strokeColor = UIColor.black.cgColor
        
        gradient.mask = shape
        layer.addSublayer(gradient)
        
        self.gradientLayer = gradient
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer?.frame = bounds
        (gradientLayer?.mask as? CAShapeLayer)?.path =
            UIBezierPath(roundedRect: bounds, cornerRadius: 16).cgPath
    }
}
