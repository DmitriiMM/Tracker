import UIKit

protocol TrackerCollectionViewCellCounterDelegate: AnyObject {
    func plusButtonTapped(on cell: TrackerCollectionViewCell)
}

final class TrackerCollectionViewCell: UICollectionViewCell {
    let identifier = "cell"
    weak var delegate: TrackerCollectionViewCellCounterDelegate?
    
    private lazy var cellView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(named: "Color5")
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        
        return view
    }()
    
    private lazy var emojiLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .white.withAlphaComponent(0.3)
        label.layer.cornerRadius = 12
        label.clipsToBounds = true
        label.text = "🥑"
        label.textAlignment = .center
        label.font = .appFont(.medium, withSize: 13)
        
        return label
    }()
    
    private lazy var trackCardLabel: UILabel = {
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
        button.tintColor = .white
        button.backgroundColor = cellView.backgroundColor
        button.layer.cornerRadius = 17
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(plusButtonTapped), for: .touchUpInside)
        
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
    
    @objc private func plusButtonTapped() {
        delegate?.plusButtonTapped(on: self)
    }
    
    func confugureSubviews(with tracker: Tracker) {
        trackCardLabel.text = tracker.trackerText
        cellView.backgroundColor = tracker.trackerColor
        plusButton.backgroundColor = tracker.trackerColor
        emojiLabel.text = tracker.trackerEmoji
    }
    
    func configRecordInfo(days: Int, isDoneToday: Bool) {
        configRecordInfoText(days: days)
        configRecordInfoSymbol(isDone: isDoneToday)
    }
    
    private func configRecordInfoSymbol(isDone: Bool) {
        guard let image: UIImage = (isDone ? UIImage(systemName: "checkmark") : UIImage(systemName: "plus")) else { return }
        plusButton.setImage(image, for: .normal)
        let opacity: Float = isDone ? 0.3 : 1
        plusButton.layer.opacity = opacity
    }
    
    private func configRecordInfoText(days: Int) {
        switch days % 10 {
        case 1:
            counterLabel.text = "\(days) день"
        case 2...4:
            counterLabel.text = "\(days) дня"
        default:
            counterLabel.text = "\(days) дней"
        }
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
            trackCardLabel.heightAnchor.constraint(equalToConstant: 24),
            trackCardLabel.widthAnchor.constraint(equalToConstant: 24),
            
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

