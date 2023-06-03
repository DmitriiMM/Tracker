import UIKit

final class StatisticViewController: UIViewController {
    private let statisticStorage = StatisticStorage.shared
  
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.appFont(.bold, withSize: 34)
        label.text = NSLocalizedString("statistics", comment: "Title of statistics vc")
        label.textColor = .ypBlack
        
        return label
    }()
    
    private lazy var emptyStatisticImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "emptyStatistic")
        imageView.isHidden = true
        
        return imageView
    }()
    
    private lazy var emptyStatisticLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.appFont(.medium, withSize: 12)
        label.text = NSLocalizedString("emptyStatistic", comment: "Title for empty statistic vc")
        label.textColor = .ypBlack
        label.textAlignment = .center
        label.isHidden = true
        
        return label
    }()
    
    private lazy var cardsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 12
        
        for type in Statistic.allCases {
            let card = StatisticView(cardTypeStatistic: type)
            
            NSLayoutConstraint.activate([
                card.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width),
                card.heightAnchor.constraint(equalToConstant: 90)
            ])
            
            configLayer(for: card)
            
            stackView.addArrangedSubview(card)
        }
        
        return stackView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .ypWhite
        
        addSubviews()
        addConstraints()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        configStatistic()
        showStatistic()
    }
    
    private func configStatistic() {
        for view in cardsStackView.subviews {
            if let card = view as? StatisticView {
                let counterValue = statisticStorage.getStatisticCount(for: card.cardTypeStatistic)
                card.updateView(with: counterValue)
            }
        }
    }
    
    private func showStatistic() {
        for type in Statistic.allCases {
            if statisticStorage.getStatisticCount(for: type) != 0 {
                emptyStatisticImageView.isHidden = true
                emptyStatisticLabel.isHidden = true
                cardsStackView.isHidden = false
                break
            } else {
                emptyStatisticImageView.isHidden = false
                emptyStatisticLabel.isHidden = false
                cardsStackView.isHidden = true
            }
        }
    }

    private func configLayer(for view: StatisticView) {
        if let sublayers = view.layer.sublayers, sublayers.count > 1 {
            let frontLayer = sublayers[1]
            frontLayer.frame = CGRect(x: 1, y: 1, width: view.bounds.width - 34, height: 88)
            let backLayer = sublayers[0]
            backLayer.frame = CGRect(x: 0, y: 0, width: view.bounds.width - 32, height: 90)
        }
    }
    
    private func addSubviews() {
        view.addSubview(titleLabel)
        view.addSubview(emptyStatisticImageView)
        view.addSubview(emptyStatisticLabel)
        view.addSubview(cardsStackView)
    }
    
    private func addConstraints() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        emptyStatisticImageView.translatesAutoresizingMaskIntoConstraints = false
        emptyStatisticLabel.translatesAutoresizingMaskIntoConstraints = false
        cardsStackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor,constant: 16),
            titleLabel.bottomAnchor.constraint(equalTo: view.topAnchor, constant: 129),
            
            emptyStatisticImageView.bottomAnchor.constraint(equalTo: view.centerYAnchor, constant: 64),
            emptyStatisticImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStatisticImageView.heightAnchor.constraint(equalToConstant: 80),
            emptyStatisticImageView.widthAnchor.constraint(equalToConstant: 80),
            
            emptyStatisticLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStatisticLabel.topAnchor.constraint(equalTo: emptyStatisticImageView.bottomAnchor, constant: 8),
            
            cardsStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor,constant: 16),
            cardsStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor,constant: -16),
            cardsStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}
