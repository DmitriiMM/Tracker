import UIKit

final class SuplementaryCollectionCell: UICollectionViewCell {
    let identifier = "SuplementaryCell"
    lazy var label: UILabel = {
        let label = UILabel()
        label.font = UIFont.appFont(.bold, withSize: 32)

        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(label)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let margins = UIEdgeInsets(top: 6, left: 6, bottom: 6, right: 6)
        contentView.frame = contentView.frame.inset(by: margins)
        contentView.layer.cornerRadius = 8
        contentView.clipsToBounds = true
    }
    
}
