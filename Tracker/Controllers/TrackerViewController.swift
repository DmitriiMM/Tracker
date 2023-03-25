import UIKit

class TrackerViewController: UIViewController {
    private lazy var topBar: UIView = {
        let view = UIView()
        view.backgroundColor = .ypWhite
        
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 34, weight: .bold) //UIFont.appFont(.bold, withSize: 34)
        label.text = "Трекеры"
        label.textColor = .ypBlack
        
        return label
    }()
    
    private lazy var addTrackerButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(systemName: "plus")
        button.setImage(image, for: .normal)

        button.tintColor = .ypBlack
        button.addTarget(self, action: #selector(addTrackerButtonTapped), for: .touchUpInside)
        
        return button
    }()
    
    private lazy var datePickerButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .ypBackgroundGray
        button.layer.cornerRadius = 8
        button.clipsToBounds = true
        
        let today = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yy"
        let formattedDate = dateFormatter.string(from: today)
        
        button.setTitle(formattedDate, for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17) //UIFont(name: "SF-Pro-Text-Regular", size: 30) //UIFont.appFont(.regular, withSize: 17)
        
        return button
    }()
    
    private lazy var searchField: UISearchTextField = {
        let search = UISearchTextField()
        search.placeholder = "Поиск"
       
        
        return search
    }()
    
//    private lazy var collectionView: UICollectionView = {
//        let collection = UICollectionView()
//        collection.register(EmojiCollectionViewCell.self, forCellWithReuseIdentifier: "cell")
//        collection.register(SupplementaryView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
//        collection.register(SupplementaryView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "footer")
//        collection.delegate = self
//        collection.dataSource = self
//        collection.backgroundColor = .ypWhite
//
//        collection.allowsMultipleSelection = false
//
//        return collectionView
//    }()
    
    private lazy var emptyTableLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(descriptor: UIFontDescriptor(name: "SFProText-Regular", size: 0), size: 16)
        label.text = "Таких контактов нет, выберите другие фильтры"
        label.textColor = .white
        label.numberOfLines = 2
        label.textAlignment = .center
        label.isHidden = true
        
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .ypWhite
        
        addSubviews()
        addConstraints()
    }
    
    @objc private func addTrackerButtonTapped() {
//        let filterVC = FilterViewController()
//        filterVC.delegate = self
//        filterVC.filterArray = filterSettings
//        present(filterVC, animated: true)
    }
    
    func addSubviews() {
        view.addSubview(topBar)
//        view.addSubview(collectionView)
        view.addSubview(emptyTableLabel)
        topBar.addSubview(titleLabel)
        topBar.addSubview(addTrackerButton)
        topBar.addSubview(datePickerButton)
        topBar.addSubview(searchField)
    }
    
    func addConstraints() {
        topBar.translatesAutoresizingMaskIntoConstraints = false
//        collectionView.translatesAutoresizingMaskIntoConstraints = false
        emptyTableLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        addTrackerButton.translatesAutoresizingMaskIntoConstraints = false
        datePickerButton.translatesAutoresizingMaskIntoConstraints = false
        searchField.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            topBar.topAnchor.constraint(equalTo: view.topAnchor),
            topBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            topBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            addTrackerButton.topAnchor.constraint(equalTo: topBar.topAnchor, constant: 57),
            addTrackerButton.leadingAnchor.constraint(equalTo: topBar.leadingAnchor, constant: 18),
            addTrackerButton.widthAnchor.constraint(equalToConstant: 19),
            addTrackerButton.heightAnchor.constraint(equalToConstant: 18),
            
            titleLabel.leadingAnchor.constraint(equalTo: addTrackerButton.leadingAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: addTrackerButton.bottomAnchor, constant: 54),
            
            searchField.leadingAnchor.constraint(equalTo: addTrackerButton.leadingAnchor),
            searchField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 7),
            searchField.bottomAnchor.constraint(equalTo: topBar.bottomAnchor, constant: -10),
            searchField.trailingAnchor.constraint(equalTo: topBar.trailingAnchor, constant: -16),
            
            datePickerButton.trailingAnchor.constraint(equalTo: searchField.trailingAnchor),
            datePickerButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            datePickerButton.topAnchor.constraint(equalTo: topBar.topAnchor, constant: 91),
            datePickerButton.widthAnchor.constraint(equalToConstant: 80)
            
//            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
//            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
//            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
}

//extension TrackerViewController: UICollectionViewDelegate {
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//           let cell = collectionView.cellForItem(at: indexPath) as? EmojiCollectionViewCell
//           cell?.titleLabel.font = UIFont.boldSystemFont(ofSize: 32)
//       }
//
//    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
//        let cell = collectionView.cellForItem(at: indexPath) as? EmojiCollectionViewCell
//        cell?.titleLabel.font = UIFont.systemFont(ofSize: 17, weight: .regular)
//    }
//
//    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemsAt indexPaths: [IndexPath], point: CGPoint) -> UIContextMenuConfiguration? {
//            guard indexPaths.count > 0 else {
//                return nil
//            }
//
//            let indexPath = indexPaths[0]
//
//            return UIContextMenuConfiguration(actionProvider: { actions in
//                return UIMenu(children: [
//                    UIAction(title: "Bold") { [weak self] _ in
//                        self?.makeBold(indexPath: indexPath)
//                    },
//                    UIAction(title: "Italic") { [weak self] _ in
//                        self?.makeItalic(indexPath: indexPath)
//                    },
//                ])
//            })
//        }
//}
//
//extension TrackerViewController: UICollectionViewDataSource {
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        0
//    }
//
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
//
//        guard let collectionCell = cell as? EmojiCollectionViewCell else { return UICollectionViewCell() }
//
////        collectionCell.titleLabel.text = letters[indexPath.row]
//        return cell
//    }
//
//    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
//        var id: String
//        switch kind {
//        case UICollectionView.elementKindSectionHeader:
//            id = "header"
//        case UICollectionView.elementKindSectionFooter:
//            id = "footer"
//        default:
//            id = ""
//        }
//
//        let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: id, for: indexPath) as? SupplementaryView
//        guard let view = view else { return UICollectionReusableView() }
//        view.titleLabel.text = "Здесь находится Supplementary view"
//
//        return view
//    }
//}
//
//extension TrackerViewController: UICollectionViewDelegateFlowLayout {
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
//        let indexPath = IndexPath(row: 0, section: section)
//        let headerView = self.collectionView(collectionView, viewForSupplementaryElementOfKind: UICollectionView.elementKindSectionHeader, at: indexPath)
//
//        return headerView.systemLayoutSizeFitting(
//            CGSize(
//                width: collectionView.frame.width,
//                height: UIView.layoutFittingExpandedSize.height),
//            withHorizontalFittingPriority: .required,
//            verticalFittingPriority: .fittingSizeLevel
//        )
//    }
//
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
//        let indexPath = IndexPath(row: 0, section: section)
//        let footerView = self.collectionView(collectionView, viewForSupplementaryElementOfKind: UICollectionView.elementKindSectionFooter, at: indexPath)
//
//        return footerView.systemLayoutSizeFitting(
//            CGSize(
//                width: collectionView.frame.width,
//                height: UIView.layoutFittingExpandedSize.height),
//            withHorizontalFittingPriority: .required,
//            verticalFittingPriority: .fittingSizeLevel
//        )
//    }
//
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        return CGSize(width: collectionView.bounds.width / 2, height: 50)
//    }
//
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
//            return 0
//        }
//}
