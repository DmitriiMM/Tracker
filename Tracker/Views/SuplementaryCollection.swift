import UIKit

final class SupplementaryCollection: NSObject {
    
    private let params = GeometricParams(
        cellCount: 6,
        leftInset: 25,
        rightInset: 25,
        cellSpacing: 5
    )
    
    private let emoji: [String] = ["❤️", "🧠", "👑", "🐶", "🍀", "🌎", "🥑", "🍾", "🏀", "🏆", "🚗", "✈️", "🏔️", "💻", "💵", "🚬", "🏗️", "🇺🇸"]
    
    private var colors: [UIColor] = []
    
    override init() {
        super.init()
        
        for i in 1...18 {
            colors.append(UIColor(named: "Color\(i)") ?? .red)
        }
        print("❤️❤️❤️\(colors)")
    }
    
//    private let colors: [UIColor] = [
//        UIColor(named: "Color1")!, UIColor(named: "Color2")!, UIColor(named: "Color3")!,
//        UIColor(named: "Color4")!, UIColor(named: "Color5")!, UIColor(named: "Color6")!,
//        UIColor(named: "Color7")!, UIColor(named: "Color8")!, UIColor(named: "Color9")!,
//        UIColor(named: "Color10")!, UIColor(named: "Color11")!, UIColor(named: "Color12")!,
//        UIColor(named: "Color13")!, UIColor(named: "Color14")!, UIColor(named: "Color15")!,
//        UIColor(named: "Color16")!, UIColor(named: "Color17")!, UIColor(named: "Color18")!
//    ]
}
    
extension SupplementaryCollection: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return emoji.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SuplementaryCollectionCell().identifier,for: indexPath)
        
        guard let collectionCell = cell as? SuplementaryCollectionCell else { return UICollectionViewCell() }
        
        collectionCell.layer.cornerRadius = 16
        collectionCell.layer.masksToBounds = true
        
        switch indexPath.section {
        case 0:
            collectionCell.layer.cornerRadius = 16
            collectionCell.label.text = emoji[indexPath.row]
        case 1:
            collectionCell.layer.cornerRadius = 13
            collectionCell.label.text = ""
           
            collectionCell.contentView.backgroundColor = colors[indexPath.row]
            
        default:
            break
        }
        
        
        collectionCell.prepareForReuse()
        
        return collectionCell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath) as? SupplementaryView
        guard let view = view else { return UICollectionReusableView() }
        
        switch indexPath.section {
        case 0:
            view.titleLabel.text = "Emoji"
        case 1:
            view.titleLabel.text = "Colors"
        default:
            break
        }
    
        return view
    }
}

extension SupplementaryCollection: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let indexPath = IndexPath(row: 0, section: section)
        let headerView = self.collectionView(collectionView, viewForSupplementaryElementOfKind: UICollectionView.elementKindSectionHeader, at: indexPath)

        return headerView.systemLayoutSizeFitting(
            CGSize(
                width: collectionView.frame.width,
                height: UIView.layoutFittingExpandedSize.height),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let availableWidth = collectionView.frame.width - params.paddingWidth
        let cellWidth =  availableWidth / CGFloat(params.cellCount)
        
        return CGSize(width: cellWidth, height: cellWidth)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return UIEdgeInsets(top: 25, left: params.leftInset, bottom: 25, right: params.rightInset)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        return params.cellSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        
        return params.cellSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) {
            
            switch indexPath.section {
            case 0:
                for cell in collectionView.visibleCells {
                    cell.backgroundColor = .clear
                }
                
                cell.backgroundColor = .ypLightGray
            case 1:
                for cell in collectionView.visibleCells {
                    cell.backgroundColor = .clear
                    cell.layer.borderWidth = 0
                }
                
                cell.layer.borderColor = cell.contentView.backgroundColor?.withAlphaComponent(0.3).cgColor
                cell.layer.borderWidth = 3
                
            default:
                break
            }
        }
    }
}

struct GeometricParams {
    let cellCount: Int
    let leftInset: CGFloat
    let rightInset: CGFloat
    let cellSpacing: CGFloat
    let paddingWidth: CGFloat
    
    init(cellCount: Int, leftInset: CGFloat, rightInset: CGFloat, cellSpacing: CGFloat) {
        self.cellCount = cellCount
        self.leftInset = leftInset
        self.rightInset = rightInset
        self.cellSpacing = cellSpacing
        self.paddingWidth = leftInset + rightInset + CGFloat(cellCount - 1) * cellSpacing
    }
}
