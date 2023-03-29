import UIKit

class TrackerCollectionViewCell: UICollectionViewCell {
    let identifier = "cell"
    
    private lazy var cellView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(named: "Color5")
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        
        return view
    }()
    
    private lazy var emojiLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = superview?.backgroundColor?.withAlphaComponent(0.3)
        label.layer.cornerRadius = 12
        label.clipsToBounds = true
        label.text = "🥑"
        
        return label
    }()
    
    lazy var trackCardLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.font = UIFont.appFont(.medium, withSize: 12)
        label.textColor = .white
        label.text = "Поливать растения"
        
        return label
    }()
    
    private lazy var counterLabel: UILabel = {
        let label = UILabel()
        label.adjustsFontSizeToFitWidth = true
        label.font = UIFont.appFont(.medium, withSize: 12)
        label.textColor = .ypBlack
        label.text = "1 день"
        
        return label
    }()
    
    private lazy var plusButton: UIButton = {
        let button = UIButton()
        let image = UIImage(systemName: "plus")
        button.setImage(image, for: .normal)
        button.tintColor = .white
        button.backgroundColor = cellView.backgroundColor
        button.layer.cornerRadius = 17
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(incrementCounter), for: .touchUpInside)
        
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubviews()
        addConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func incrementCounter() {
        
    }
    
    private func addSubviews() {
        contentView.addSubview(cellView)
        contentView.addSubview(counterLabel)
        contentView.addSubview(plusButton)
        cellView.addSubview(emojiLabel)
        cellView.addSubview(trackCardLabel)
    }
    
    private func addConstraints() {
        cellView.translatesAutoresizingMaskIntoConstraints = false
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        trackCardLabel.translatesAutoresizingMaskIntoConstraints = false
        counterLabel.translatesAutoresizingMaskIntoConstraints = false
        plusButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            cellView.topAnchor.constraint(equalTo: contentView.topAnchor),
            cellView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cellView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            cellView.heightAnchor.constraint(equalToConstant: 90),
            
            emojiLabel.topAnchor.constraint(equalTo: cellView.topAnchor, constant: 12),
            emojiLabel.leadingAnchor.constraint(equalTo: cellView.leadingAnchor, constant: 12),
            emojiLabel.heightAnchor.constraint(equalToConstant: 24),
            emojiLabel.widthAnchor.constraint(equalToConstant: 24),
            
            trackCardLabel.leadingAnchor.constraint(equalTo: cellView.leadingAnchor, constant: 12),
            trackCardLabel.trailingAnchor.constraint(equalTo: cellView.trailingAnchor, constant: -12),
            trackCardLabel.bottomAnchor.constraint(equalTo: cellView.bottomAnchor, constant: -12),
            
            plusButton.topAnchor.constraint(equalTo: cellView.bottomAnchor, constant: 8),
            plusButton.trailingAnchor.constraint(equalTo: cellView.trailingAnchor, constant: -12),
            plusButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            plusButton.heightAnchor.constraint(equalToConstant: 34),
            plusButton.widthAnchor.constraint(equalToConstant: 34),
            
            counterLabel.centerYAnchor.constraint(equalTo: plusButton.centerYAnchor),
            counterLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            counterLabel.trailingAnchor.constraint(equalTo: plusButton.trailingAnchor, constant: -8)
        ])
    }
}

