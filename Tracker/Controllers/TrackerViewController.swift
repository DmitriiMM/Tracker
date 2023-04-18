import UIKit

final class TrackerViewController: UIViewController {
    let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .none
        return dateFormatter
    }()
    private var currentDate = String()
    private var categories: [TrackerCategory] = [] //mockTrackers
    private var newTracker: Tracker?
    private var titleNewCategory: String?
    private var memoryTrackerByСategory: [TrackerCategory] = []
    private var searchText = ""
    private var completedTrackers: Set<TrackerRecord> = []
    private var visibleCategories: [TrackerCategory] = []
    
    private let trackerStore = TrackerStore()
    private let trackerCategoryStore = TrackerCategoryStore()
    private let trackerRecordStore = TrackerRecordStore()
    
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
    
    private lazy var datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.preferredDatePickerStyle = .compact
        picker.datePickerMode = .date
        picker.locale = Locale(identifier: "ru_RU")
        picker.calendar.firstWeekday = 2
        picker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)

        return picker
    }()
    
    private lazy var searchField: UISearchBar = {
        let search = UISearchBar()
        search.barTintColor = .ypWhite
        search.placeholder = "Поиск"
        search.delegate = self
        search.searchBarStyle = .minimal
       
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
        
        return imageView
    }()
    
    private lazy var emptyCollectionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.appFont(.medium, withSize: 12)
        label.text = "Что будем отслеживать?"
        label.textColor = .ypBlack
        label.textAlignment = .center
        
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
        
        currentDate = dateFormatter.string(from: Date())
      
        categories = trackerCategoryStore.categories
        completedTrackers = trackerRecordStore.records as! Set<TrackerRecord>
        print("🍏completedTrackers\(completedTrackers)🍏")
        
    }
    
    @objc private func datePickerValueChanged(_ sender: UIDatePicker) {
        let weekday = sender.calendar.component(.weekday, from: sender.date)
        
        var day = "Day"
        switch weekday {
        case 1: day = "Вс"
        case 2: day = "Пн"
        case 3: day = "Вт"
        case 4: day = "Ср"
        case 5: day = "Чт"
        case 6: day = "Пт"
        case 7: day = "Сб"
        default: break
        }
        
        memoryTrackerByСategory = categories
        for category in categories {
            var filterTrackers: [Tracker] = []
            for tracker in category.trackers {
                if let schedule = tracker.trackerSchedule {
                    if schedule.contains(where: { $0 == day }) {
                        filterTrackers.append(tracker)
                    }
                }
            }
            
            let newCategory = TrackerCategory(title: category.title, trackers: filterTrackers)
            if newCategory.title == category.title {
                let index = categories.firstIndex(where: { $0.title == newCategory.title })!
                categories[index] = newCategory
            }
        }
        
        for category in categories {
            if category.trackers.isEmpty {
                let index = categories.firstIndex(where: { $0.trackers.isEmpty })!
                categories.remove(at: index)
            }
        }
        
        collectionView.reloadData()
        dismiss(animated: true) {
            self.categories = self.memoryTrackerByСategory
        }
    }
    
    @objc private func addTrackerButtonTapped() {
        let typeNewTrackerVC = TypeNewTrackerViewController()
        typeNewTrackerVC.delegateTransition = self
        let categories = categories.map { $0.title }
        typeNewTrackerVC.categories = categories
        present(typeNewTrackerVC, animated: true)
    }
    
    private func addSubviews() {
        view.addSubview(topBar)
        view.addSubview(emptyCollectionImageView)
        view.addSubview(emptyCollectionLabel)
        view.addSubview(collectionView)
        topBar.addSubview(titleLabel)
        topBar.addSubview(addTrackerButton)
        topBar.addSubview(datePicker)
        topBar.addSubview(searchField)
    }
    
    private func addConstraints() {
        topBar.translatesAutoresizingMaskIntoConstraints = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        emptyCollectionImageView.translatesAutoresizingMaskIntoConstraints = false
        emptyCollectionLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        addTrackerButton.translatesAutoresizingMaskIntoConstraints = false
        datePicker.translatesAutoresizingMaskIntoConstraints = false
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
            
            datePicker.trailingAnchor.constraint(equalTo: searchField.trailingAnchor),
            datePicker.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            datePicker.topAnchor.constraint(equalTo: topBar.topAnchor, constant: 91),
            datePicker.widthAnchor.constraint(equalToConstant: 120),
            
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

extension TrackerViewController: UISearchBarDelegate, UITextFieldDelegate {
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.setShowsCancelButton(true, animated: true)
        memoryTrackerByСategory = categories
        
        return true
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        var filteredCategories = categories
        if self.searchText.count < searchBar.text?.count ?? 0 {
            self.searchText = searchText.lowercased()
            for (index, char) in searchText.enumerated() {
                let charString = String(char).lowercased()
                filteredCategories = filteredCategories.compactMap { category in
                    let filteredTrackers = category.trackers.filter { tracker in
                        guard let trackerChar = tracker.trackerText.lowercased().prefix(index+1).last else { return false }
                        return String(trackerChar) == charString
                    }
                    return filteredTrackers.isEmpty ? nil : TrackerCategory(title: category.title, trackers: filteredTrackers)
                }
            }
        } else if self.searchText.count > searchBar.text?.count ?? 0 {
            categories = memoryTrackerByСategory
            self.searchText = searchText.lowercased()
            let newFilteredCategories = categories.compactMap { category in
                let filteredTrackers = category.trackers.filter { tracker in
                    let trackerText = tracker.trackerText.lowercased()
                    
                    return trackerText.prefix(searchText.count) == searchText.lowercased()
                }
                
                return filteredTrackers.isEmpty ? nil : TrackerCategory(title: category.title, trackers: filteredTrackers)
            }
            
            filteredCategories = newFilteredCategories
        }
        
        categories = filteredCategories
        collectionView.reloadData()
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        categories = memoryTrackerByСategory
        collectionView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.endEditing(true)
        searchBar.setShowsCancelButton(false, animated: true)
    }
}

extension TrackerViewController: TrackerCollectionViewCellCounterDelegate {
    func plusButtonTapped(on cell: TrackerCollectionViewCell) {
        let indexPath: IndexPath = collectionView.indexPath(for: cell) ?? IndexPath()
        let tracker = categories[indexPath.section].trackers[indexPath.row]
        let id = categories[indexPath.section].trackers[indexPath.row].trackerId
        var daysCount = completedTrackers.filter { $0.trackerId == id }.count
        
        
        if !completedTrackers.contains(where: { $0.trackerId == id && $0.date == currentDate }) {
//            completedTrackers.insert(TrackerRecord(trackerId: id, date: currentDate))
            try! trackerRecordStore.saveRecord(tracker: tracker, to: currentDate)
            daysCount += 1
            cell.configRecordInfo(days: daysCount, isDoneToday: true)
        } else {
//            completedTrackers.remove(TrackerRecord(trackerId: id, date: currentDate))
            try! trackerRecordStore.removeRecord(tracker: tracker, to: currentDate)
            daysCount -= 1
            cell.configRecordInfo(days: daysCount, isDoneToday: false)
        }
        
        completedTrackers = trackerRecordStore.records as! Set<TrackerRecord>
        print("🍏completedTrackers\(completedTrackers)🍏")
    }
}

extension TrackerViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        collectionView.isHidden = categories.count == 0 ? true : false
        
        return categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        categories[section].trackers.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackerCollectionViewCell().identifier, for: indexPath) as? TrackerCollectionViewCell else { return UICollectionViewCell() }
        
        let tracker = categories[indexPath.section].trackers[indexPath.row]
        let daysCount = completedTrackers.filter { $0.trackerId == tracker.trackerId }.count
        let isDoneToday = completedTrackers.contains(where: { $0.trackerId == tracker.trackerId && $0.trackerId == tracker.trackerId }) ? true : false
        cell.confugureSubviews(with: tracker)
        cell.configRecordInfo(days: daysCount, isDoneToday: isDoneToday)
        cell.delegate = self
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath) as? SupplementaryView
        guard let view = view else { return UICollectionReusableView() }
        
        view.titleLabel.text = categories[indexPath.section].title

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

extension TrackerViewController: ScreenTransitionProtocol {
    func onTransition<T>(value: T, for key: String) {
        dismiss(animated: true)
        
        switch key {
        case "newTracker":
            newTracker = value as? Tracker
        case "newCategory":
            titleNewCategory = value as? String
        default:
            break
        }
        
        addNewTracker()
    }
    
    func addNewTracker() {
        guard let newTracker = newTracker, let titleNewCategory = titleNewCategory else { return }
        
        try! trackerCategoryStore.saveTracker(tracker: newTracker, to: titleNewCategory)
        categories = trackerCategoryStore.categories
        
        collectionView.reloadData()
        self.newTracker = nil
        self.titleNewCategory = nil
    }
}
