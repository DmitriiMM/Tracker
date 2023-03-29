import UIKit

class TrackerViewController: UIViewController {
    let currentDate = Date()
    var trackCards = ["a", "b", "c", "d", "e", "f", "g"]
    var sectionTwotrackCards = ["aaa", "bbb", "ccc", "ddd", "eee", "fff", "ggg"]
    
    
    private lazy var topBar: UIView = {
        let view = UIView()
        view.backgroundColor = .ypWhite
        
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.appFont(.bold, withSize: 34)
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
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yy"
        let formattedDate = dateFormatter.string(from: currentDate)
        
        button.setTitle(formattedDate, for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.appFont(.regular, withSize: 17)
        
        return button
    }()
    
    private lazy var searchField: UISearchTextField = {
        let search = UISearchTextField()
        search.placeholder = "Поиск"
       
        
        return search
    }()
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: UICollectionViewFlowLayout()
        )
        collectionView.register(TrackerCollectionViewCell.self, forCellWithReuseIdentifier: TrackerCollectionViewCell().identifier)
        
        return collectionView
    }()
   
    private lazy var emptyCollectionImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "star")
//        imageView.isHidden = true
        
        return imageView
    }()
    
    private lazy var emptyCollectionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.appFont(.medium, withSize: 12)
        label.text = "Что будем отслеживать?"
        label.textColor = .ypBlack
        label.textAlignment = .center
//        label.isHidden = true
        
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .ypWhite
        
        
        collectionView.register(SupplementaryView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")

        collectionView.backgroundColor = .ypWhite
        collectionView.allowsMultipleSelection = false
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        addSubviews()
        addConstraints()
    }
    
    @objc private func addTrackerButtonTapped() {
        let typeNewTrackerVC = TypeNewTrackerViewController()
        present(typeNewTrackerVC, animated: true)
    }
    
    func addSubviews() {
        view.addSubview(topBar)
        view.addSubview(emptyCollectionImageView)
        view.addSubview(emptyCollectionLabel)
        view.addSubview(collectionView)
        topBar.addSubview(titleLabel)
        topBar.addSubview(addTrackerButton)
        topBar.addSubview(datePickerButton)
        topBar.addSubview(searchField)
    }
    
    func addConstraints() {
        topBar.translatesAutoresizingMaskIntoConstraints = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        emptyCollectionImageView.translatesAutoresizingMaskIntoConstraints = false
        emptyCollectionLabel.translatesAutoresizingMaskIntoConstraints = false
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
            datePickerButton.widthAnchor.constraint(equalToConstant: 80),
            
            emptyCollectionImageView.centerYAnchor.constraint(equalTo: topBar.bottomAnchor, constant: (view.safeAreaLayoutGuide.layoutFrame.height - topBar.frame.height)/3),
            emptyCollectionImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyCollectionImageView.heightAnchor.constraint(equalToConstant: 80),
            emptyCollectionImageView.widthAnchor.constraint(equalToConstant: 80),
            
            emptyCollectionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyCollectionLabel.topAnchor.constraint(equalTo: emptyCollectionImageView.bottomAnchor, constant: 8),
            
            collectionView.topAnchor.constraint(equalTo: topBar.bottomAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
}

extension TrackerViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
           let cell = collectionView.cellForItem(at: indexPath) as? TrackerCollectionViewCell
//           cell?.titleLabel.font = UIFont.boldSystemFont(ofSize: 32)
       }

    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as? TrackerCollectionViewCell
//        cell?.titleLabel.font = UIFont.systemFont(ofSize: 17, weight: .regular)
    }
    
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
}

extension TrackerViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0: return trackCards.count
        case 1: return sectionTwotrackCards.count
        default: return 0
        }
        
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackerCollectionViewCell().identifier, for: indexPath)
        
        guard let collectionCell = cell as? TrackerCollectionViewCell else { return UICollectionViewCell() }
        
        switch indexPath.section {
        case 0:
            collectionCell.trackCardLabel.text = trackCards[indexPath.row]
        case 1:
            collectionCell.trackCardLabel.text = sectionTwotrackCards[indexPath.row]
        default:
            break
        }
        
        
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath) as? SupplementaryView
        guard let view = view else { return UICollectionReusableView() }
        
        switch indexPath.section {
        case 0:
            view.titleLabel.text = "Категория"
        case 1:
            view.titleLabel.text = "Вторая Категория"
        default:
            break
        }
        

        return view
    }
}

extension TrackerViewController: UICollectionViewDelegateFlowLayout {
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
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width / 2 - 16 - 4.5, height: 132)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 9
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }
}
