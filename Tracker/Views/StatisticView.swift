import UIKit

final class StatisticView: UIView {
    let cardTypeStatistic: Statistic
    
    private let backLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.colors = [UIColor(red: 253/255, green: 76/255, blue: 73/255, alpha: 1).cgColor,
                        UIColor(red: 70/255, green: 230/255, blue: 157/255, alpha: 1).cgColor,
                        UIColor(red: 0, green: 123/255, blue: 250/255, alpha: 1).cgColor]
        layer.locations = [0, 0.5, 1]
        layer.startPoint = CGPoint(x: 0, y: 0)
        layer.endPoint = CGPoint(x: 1, y: 0)
        layer.cornerRadius = 16
        
        return layer
    }()
    
    private let frontLayer: CALayer = {
        let layer = CALayer()
        layer.cornerRadius = 15
        layer.backgroundColor = UIColor.ypWhite.cgColor
        
        return layer
    }()
    
    private lazy var cardCounterLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.appFont(.bold, withSize: 34)
        label.textColor = .ypBlack
        
        return label
    }()
    
    private lazy var cardDescriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.appFont(.medium, withSize: 12)
        label.text = cardTypeStatistic.rawValue
        label.textColor = .ypBlack
        
        return label
    }()
    
    init(cardTypeStatistic: Statistic) {
        self.cardTypeStatistic = cardTypeStatistic
      
        cardDescription = cardTypeStatistic.name
        cardCounter = StatisticStorage().getStatisticCount(for: cardTypeStatistic)
        super.init(frame: UIScreen.main.bounds)
        
        addSubviews()
        addConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateView(with counterValue: Int) {
        cardCounterLabel.text = counterValue != 0 ? String(counterValue) : "—"

    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateColorCards()
    }
    
    private func updateColorCards() {
        layer.sublayers?[1].backgroundColor = UIColor.ypWhite.cgColor
    }
    
    private func addSubviews() {
        layer.addSublayer(backLayer)
        layer.addSublayer(frontLayer)
        
        addSubview(cardCounterLabel)
        addSubview(cardDescriptionLabel)
    }
    
    private func addConstraints() {
        cardCounterLabel.translatesAutoresizingMaskIntoConstraints = false
        cardDescriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            cardCounterLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            cardCounterLabel.bottomAnchor.constraint(equalTo: topAnchor, constant: 44),
            
            cardDescriptionLabel.leadingAnchor.constraint(equalTo: cardCounterLabel.leadingAnchor),
            cardDescriptionLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16)
        ])
    }
}
