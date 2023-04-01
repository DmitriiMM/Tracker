import UIKit

final class SupplementaryView: UICollectionReusableView {
    let titleLabel = UILabel()
     
     override init(frame: CGRect) {
         super.init(frame: frame)
         
         titleLabel.font = UIFont.appFont(.bold, withSize: 19)
         titleLabel.textColor = .ypBlack
         addSubview(titleLabel)
         titleLabel.translatesAutoresizingMaskIntoConstraints = false
         
         NSLayoutConstraint.activate([
             titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 28),
             titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
             titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
         ])
     }
     
     required init?(coder: NSCoder) {
         fatalError("init(coder:) has not been implemented")
     }
}
