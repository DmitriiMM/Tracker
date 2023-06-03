import UIKit
import YandexMobileMetrica

final class TrackerViewController: UIViewController {
    private var currentDate = String()
    private var visibleCategories: [TrackerCategory] = []
    private var newTracker: Tracker?
    private var titleNewCategory: String?
    private var memoryTrackerByСategory: [TrackerCategory] = []
    private var searchText = ""
    private var completedTrackers: Set<TrackerRecord>? = []
    private let statisticStorage = StatisticStorage()
    private let trackerCategoryStore = TrackerCategoryStore()
    private let trackerRecordStore = TrackerRecordStore()
    private let trackerPinStore = TrackerPinStore()
    private let trackerStore = TrackerStore()
    private let pinnedCategoryName = "Закрепленные"
    private let analyticsService = AnalyticsService()
    
    private lazy var topBar: UIView = {
        let view = UIView()
        view.backgroundColor = .ypWhite
        
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.appFont(.bold, withSize: 34)
        label.text = NSLocalizedString("trackers", comment: "Title of trackers vc")
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
    
    lazy var datePicker: UIDatePicker = {
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
    
    private lazy var filterButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .ypBlue
        button.layer.cornerRadius = 16
        button.setTitle(NSLocalizedString("filters", comment: "Title on button to filtering trackers"), for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.appFont(.regular, withSize: 17)
        button.addTarget(self, action: #selector(filterButtonTapped), for: .touchUpInside)
        
        return button
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
        
        currentDate = DateHelper().dateFormatter.string(from: Date())
      
        loadTodayTrackers()
        completedTrackers = trackerRecordStore.records
        
        
        print("🔴\(trackerStore.trackers)")
        print("🟠\(trackerCategoryStore.categories)")
        print("🟡\(trackerRecordStore.records)")
        print("🟢\(trackerPinStore.pinnedTrackers)")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        analyticsService.report(event: "open", params: ["screen" : "Main"])
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        analyticsService.report(event: "close", params: ["screen" : "Main"])
        
    }
    
    @objc private func datePickerValueChanged(_ sender: UIDatePicker) {
        let weekday = sender.calendar.component(.weekday, from: sender.date)
        
        guard let day = Weekday.allCases.first(where: { $0.indexDay == weekday }) else { return }
        
        if trackerPinStore.pinnedTrackers != [],
           let pinCategory = trackerCategoryStore.categories.first(where: { $0.title == pinnedCategoryName }) {
            visibleCategories = [pinCategory]
        } else {
            visibleCategories = []
        }
        
        for category in trackerCategoryStore.categories {
            if category.title != pinnedCategoryName {
                let filterTrackers = category.trackers.filter { tracker in
                    tracker.trackerSchedule?.contains { schedule in
                        schedule.rawValue == day.rawValue
                    } ?? false
                }
                let filterCategory = TrackerCategory(title: category.title, trackers: filterTrackers)
                visibleCategories.append(filterCategory)
            }
        }
        
        visibleCategories = visibleCategories.filter { !$0.trackers.isEmpty }
        collectionView.reloadData()
        currentDate = DateHelper().dateFormatter.string(from: sender.date)
        dismiss(animated: true)
    }
    
    @objc private func addTrackerButtonTapped() {
        analyticsService.report(event: "click", params: ["screen" : "Main", "item" : "add_track"])
        
        let typeNewTrackerVC = TypeNewTrackerViewController()
        typeNewTrackerVC.delegate = self
        present(typeNewTrackerVC, animated: true)
    }
    
    @objc private func filterButtonTapped() {
        analyticsService.report(event: "click", params: ["screen" : "Main", "item" : "filter"])
        
        let filterVC = FilterViewController()
        filterVC.delegate = self
        present(filterVC, animated: true)
    }
    
    private func loadTodayTrackers() {
        visibleCategories = trackerCategoryStore.categories.map { category in
            if category.title != pinnedCategoryName {
                let updatedCategory = TrackerCategory(
                    title: category.title,
                    trackers: category.trackers.filter { tracker in
                        if let trackerSchedule = tracker.trackerSchedule {
                            return trackerSchedule.contains { weekday in
                                weekday.indexDay  == Calendar.current.component(.weekday, from: Date())
                            }
                        } else {
                            return true
                        }
                    }
                )
                return updatedCategory
            } else {
                return TrackerCategory(title: "", trackers: [])
            }
        }.filter { !$0.trackers.isEmpty }
        
        if trackerPinStore.pinnedTrackers != [],
           let pinCategory = trackerCategoryStore.categories.first(where: { $0.title == pinnedCategoryName }) {
            visibleCategories.insert(pinCategory, at: 0)
        }
    }
    
    private func addNewTracker() {
        guard let newTracker = newTracker, let titleNewCategory = titleNewCategory else { return }
        do {
            try trackerCategoryStore.save(newTracker, to: titleNewCategory)
        } catch {
            print(error.localizedDescription)
        }
        
        loadTodayTrackers()
        collectionView.reloadData()
        self.newTracker = nil
        self.titleNewCategory = nil
    }
    
    func addNewFixTracker() {
        let newFixTracker = Tracker(
            trackerId: UUID(),
            trackerText: "It's a tracker for screenshot test!",
            trackerEmoji: "📸",
            trackerColor: .ypBlue,
            trackerSchedule: Weekday.allCases
        )
        do {
            try trackerCategoryStore.save(newFixTracker, to: "Test Category")
        } catch {
            print(error.localizedDescription)
        }
        
        loadTodayTrackers()
        collectionView.reloadData()
    }
    
    private func addSubviews() {
        view.addSubview(topBar)
        view.addSubview(emptyCollectionImageView)
        view.addSubview(emptyCollectionLabel)
        view.addSubview(collectionView)
        view.addSubview(filterButton)
        topBar.addSubview(titleLabel)
        topBar.addSubview(addTrackerButton)
        topBar.addSubview(datePicker)
        topBar.addSubview(searchField)
    }
    
    private func addConstraints() {
        topBar.translatesAutoresizingMaskIntoConstraints = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        filterButton.translatesAutoresizingMaskIntoConstraints = false
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
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            filterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            filterButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,constant: -17),
            filterButton.widthAnchor.constraint(equalToConstant: 114),
            filterButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
}

extension TrackerViewController: UISearchBarDelegate, UITextFieldDelegate {
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.setShowsCancelButton(true, animated: true)
        
        return true
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard let searchBarText = searchBar.text else { return }
        loadTodayTrackers()
        var filteredCategories = visibleCategories
        if self.searchText.count < searchBarText.count {
            self.searchText = searchText.lowercased()
            for (index, char) in searchText.enumerated() {
                let charString = String(char).lowercased()
                filteredCategories = filteredCategories.compactMap { category in
                    let filteredTrackers = category.trackers.filter { tracker in
                        guard let trackerChar = tracker.trackerText.lowercased().prefix(index+1).last else { return false }
                        return String(trackerChar) == charString
                    }
                    
                    if filteredTrackers.isEmpty {
                        emptyCollectionLabel.text = "Ничего не найдено"
                        emptyCollectionImageView.image = UIImage(named: "emptySearch")
                        emptyCollectionLabel.isHidden = false
                        emptyCollectionImageView.isHidden = false
                    } else {
                        emptyCollectionLabel.isHidden = true
                        emptyCollectionImageView.isHidden = true
                    }
                    
                    return filteredTrackers.isEmpty ? nil : TrackerCategory(title: category.title, trackers: filteredTrackers)
                }
            }
            visibleCategories = filteredCategories.filter { !$0.trackers.isEmpty }
        } else if self.searchText.count > searchBarText.count {
            self.searchText = searchText.lowercased()
            let newFilteredCategories = trackerCategoryStore.categories.compactMap { category in
                let filteredTrackers = category.trackers.filter { tracker in
                    let trackerText = tracker.trackerText.lowercased()
                    
                    return trackerText.prefix(searchText.count) == searchText.lowercased()
                }
                
                return filteredTrackers.isEmpty ? nil : TrackerCategory(title: category.title, trackers: filteredTrackers)
            }
            
            filteredCategories = newFilteredCategories
            visibleCategories = filteredCategories.filter { !$0.trackers.isEmpty }
        }
        
        if searchBarText != "" {
            visibleCategories = filteredCategories
        } else {
            loadTodayTrackers()
        }
        
        collectionView.reloadData()
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        collectionView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.endEditing(true)
        searchBar.setShowsCancelButton(false, animated: true)
        
        loadTodayTrackers()
        collectionView.reloadData()
    }
}

extension TrackerViewController: TrackerCollectionViewCellCounterDelegate {
    func plusButtonTapped(on cell: TrackerCollectionViewCell) {
        analyticsService.report(event: "click", params: ["screen" : "Main", "item" : "track"])
        
        let indexPath: IndexPath = collectionView.indexPath(for: cell) ?? IndexPath()
        let tracker = visibleCategories[indexPath.section].trackers[indexPath.row]
        let id = tracker.trackerId
        var daysCount = completedTrackers?.filter { $0.trackerId == id }.count ?? 0
        
        if !(completedTrackers?.contains(where: { $0.trackerId == id && $0.date == currentDate }) ?? false) {
            let trackerRecord = TrackerRecord(trackerId: tracker.trackerId, date: currentDate)
            try? trackerRecordStore.add(trackerRecord)
            daysCount += 1
            cell.configRecordInfo(days: daysCount, isDoneToday: true)
        } else {
            if let recordToRemove = completedTrackers?.first(where: { $0.date == currentDate && $0.trackerId == tracker.trackerId }) {
                try? trackerRecordStore.remove(recordToRemove)
            }
            daysCount -= 1
            cell.configRecordInfo(days: daysCount, isDoneToday: false)
        }
        
        statisticStorage.setStatisticCount(
            for: .finishedTrackersCount,
            count: Set(trackerRecordStore.records.map { $0.trackerId }).count
        )
        
        completedTrackers = trackerRecordStore.records
        collectionView.reloadData()
    }
}

extension TrackerViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        collectionView.isHidden = visibleCategories.count == 0 ? true : false
        
        return visibleCategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let index = visibleCategories.firstIndex(where: { $0.title == pinnedCategoryName }) {
            let pinnedCategory = visibleCategories.remove(at: index)
            visibleCategories.insert(pinnedCategory, at: 0)
        }
        
        return visibleCategories[section].trackers.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackerCollectionViewCell().identifier, for: indexPath) as? TrackerCollectionViewCell else { return UICollectionViewCell() }
        
        let tracker = visibleCategories[indexPath.section].trackers[indexPath.row]
        let daysCount = completedTrackers?.filter { $0.trackerId == tracker.trackerId }.count ?? 0
        let isDoneToday = completedTrackers?.contains(where: { $0.trackerId == tracker.trackerId && $0.date == currentDate }) ?? false
        cell.configSubviews(with: tracker)
        cell.configRecordInfo(days: daysCount, isDoneToday: isDoneToday)
        cell.delegate = self
        
        let isPinned = trackerPinStore.pinnedTrackers.contains { $0.trackerId == tracker.trackerId }
        cell.configPin(isPinned: isPinned)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath) as? SupplementaryView
        guard let view = view else { return UICollectionReusableView() }
        
        view.titleLabel.text = visibleCategories[indexPath.section].title

        return view
    }
}

extension TrackerViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, contextMenuConfiguration configuration: UIContextMenuConfiguration, highlightPreviewForItemAt indexPath: IndexPath) -> UITargetedPreview? {

        guard let identifier = configuration.identifier as? IndexPath,
              let cell = collectionView.cellForItem(at: identifier) as? TrackerCollectionViewCell
        else {
            return nil
        }
       
        return UITargetedPreview(view: cell.cellView)
    }
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemsAt indexPaths: [IndexPath], point: CGPoint) -> UIContextMenuConfiguration? {

        guard let indexPath = indexPaths.first else { return nil }
        let tracker = visibleCategories[indexPath.section].trackers[indexPath.row]
        let isPinned = trackerPinStore.pinnedTrackers.contains { $0.trackerId == tracker.trackerId }
        let titlePinAction = isPinned ? "Открепить" : "Закрепить"
        
        let context = UIContextMenuConfiguration(identifier: indexPath as NSCopying, actionProvider: { actions in
            return UIMenu(children: [
                UIAction(title: titlePinAction) { [weak self] _ in
                    self?.fixTracker(at: indexPath)
                },
                UIAction(title: "Редактировать") { [weak self] _ in
                    self?.analyticsService.report(event: "click", params: ["screen" : "Main", "item" : "edit"])
                    self?.editTracker(at: indexPath)
                },
                UIAction(title: "Удалить", attributes: .destructive) { [weak self] _ in
                    self?.analyticsService.report(event: "click", params: ["screen" : "Main", "item" : "edit"])
                    self?.deleteTracker(at: indexPath)
                },
            ])
        })
        
        return context
    }
    
    private func fixTracker(at indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? TrackerCollectionViewCell else { return }
        let tracker = visibleCategories[indexPath.section].trackers[indexPath.row]
        let isPinned = trackerPinStore.pinnedTrackers.contains { $0.trackerId == tracker.trackerId }
        
        if isPinned {
            unPinTracker(from: indexPath)
        } else {
            pinTracker(from: indexPath)
        }
        
        cell.configPin(isPinned: isPinned)
    }
    
    private func pinTracker(from indexPath: IndexPath) {
        // Определяем трекер в выбранной ячейке
        let tracker = visibleCategories[indexPath.section].trackers[indexPath.row]
        
        // Определяем название категории выбранного трекера
        let categoryName = visibleCategories[indexPath.section].title
        
        // Делаем запись в базу данных о закреплении трекера
        let trackerPin = TrackerPin(trackerId: tracker.trackerId, exCategory: categoryName)
        try? trackerPinStore.add(trackerPin)
        
        // Создаем категорию "Закрепленные" если такой нет
        if !trackerCategoryStore.categories.contains(where: { $0.title == pinnedCategoryName }) {
            try? trackerCategoryStore.makeCategory(with: pinnedCategoryName)
        }
        
        // Удаляем трекер из текущей категории
        try? trackerCategoryStore.remove(tracker, from: categoryName)
        
        // Записываем выбранный трекер в категорию "Закрепленные"
        try? trackerCategoryStore.move(tracker, to: pinnedCategoryName)
        
        // Обновляем отображаемые категории и трекеры
        visibleCategories = trackerCategoryStore.categories.filter { !$0.trackers.isEmpty }
        collectionView.reloadData()
    }
    
    private func unPinTracker(from indexPath: IndexPath) {
        // Определяем трекер в выбранной ячейке
        let tracker = visibleCategories[indexPath.section].trackers[indexPath.row]
        
        // Вспоминаем категорию трекера, к которой он принадлежал до закрепления
        guard let categoryToReturn = trackerPinStore.pinnedTrackers.first(where: { $0.trackerId == tracker.trackerId })?.exCategory else { return }
        
        // Получаем категорию "Закрепленные" в качестве объекта CoreData
        guard let pinCategory = try? trackerCategoryStore.fetchCategory(with: pinnedCategoryName) else { return }
        
        // Удаляем запись о закреплении трекера
        guard let trackerPin = trackerPinStore.pinnedTrackers.first(where: { $0.trackerId == tracker.trackerId }) else { return }
        try? trackerPinStore.remove(trackerPin)
        
        // Удаляем трекер из категории "Закрепленные"
        try? trackerCategoryStore.remove(tracker, from: pinnedCategoryName)
        
        // Записываем открепляемый трекер в изначальную категорию данного трекера
        try? trackerCategoryStore.move(tracker, to: categoryToReturn)
        
        // Удаляем категорию "Закрепленные", если закрепленных трекеров нет
        if pinCategory.trackers == [] {
            guard let emptyPinCategoryCD = try? trackerCategoryStore.fetchCategory(with: pinnedCategoryName),
                  let emptyPinCategory = try? trackerCategoryStore.fetchCategories(from: emptyPinCategoryCD)
            else { return }
            try? trackerCategoryStore.deleteCategory(emptyPinCategory)
        }
        
        // Обновляем отображаемые категории и трекеры
        visibleCategories = trackerCategoryStore.categories.filter { !$0.trackers.isEmpty }
        collectionView.reloadData()
    }
    
    private func editTracker(at indexPath: IndexPath) {
        let tracker = visibleCategories[indexPath.section].trackers[indexPath.row]
        let text = tracker.trackerText
        let emoji = tracker.trackerEmoji
        let color = tracker.trackerColor
        
        var category = visibleCategories[indexPath.section].title
        if category == pinnedCategoryName {
            guard let exCategory = trackerPinStore.pinnedTrackers.first(where: { $0.trackerId == tracker.trackerId})?.exCategory else { return }
            category = exCategory
        }
       
        guard let schedule = tracker.trackerSchedule else { return }
        let editTrackerVC = NewTrackerViewController(isEditTracker: true)
        editTrackerVC.typeOfNewTracker = schedule.isEmpty ? .onetimeTracker : .repeatingTracker
        
        guard let records = completedTrackers?.filter({ $0.trackerId == tracker.trackerId }).count else { return }
        editTrackerVC.fillEditingVC(category: category, tracker: tracker, text: text, color: color, emoji: emoji, schedule: schedule, recordsCount: records)
        
        editTrackerVC.delegate = self
        present(editTrackerVC, animated: true)
    }
    
    private func deleteTracker(at indexPath: IndexPath) {
        let tracker = visibleCategories[indexPath.section].trackers[indexPath.row]
        let categoryName = visibleCategories[indexPath.section].title
        
        let alertModel = AlertModel(
            title: nil,
            message: "Уверены что хотите удалить трекер?",
            buttonText: "Удалить",
            completion: { [weak self] _ in
                guard let self else { return }
                try? self.trackerCategoryStore.remove(tracker, from: categoryName)
                
                self.visibleCategories = self.trackerCategoryStore.categories.filter { !$0.trackers.isEmpty }
                self.collectionView.reloadData()
                
                try? self.trackerStore.remove(tracker)
                
                let records = self.trackerRecordStore.records.filter { $0.trackerId == tracker.trackerId }
                records.forEach { record in
                    try? self.trackerRecordStore.remove(record)
                }
                
                guard
                    let pin = self.trackerPinStore.pinnedTrackers.first(where: { $0.trackerId == tracker.trackerId })
                else { return }
                try? self.trackerPinStore.remove(pin)
            },
            cancelText: "Отменить",
            cancelCompletion: nil
        )
        
        AlertPresenter().show(controller: self, model: alertModel)
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
        switch section {
        case collectionView.numberOfSections - 1:
            return UIEdgeInsets(top: 16, left: 16, bottom: 84, right: 16)
        default:
            return UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        }
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

extension TrackerViewController: TypeNewTrackerViewControllerDelegate {
    func create(newTracker: Tracker?) {
        self.newTracker = newTracker
        addNewTracker()
    }
    
    func create(newCategory: String?) {
        titleNewCategory = newCategory
        addNewTracker()
        dismiss(animated: true)
    }
}

extension TrackerViewController: NewTrackerViewControllerDelegate {
    func editTracker() {
        visibleCategories = trackerCategoryStore.categories.filter { !$0.trackers.isEmpty }
        completedTrackers = trackerRecordStore.records
        collectionView.reloadData()
    }
    
    func dismiss() {}
}

extension TrackerViewController: FilterViewControllerDelegate {
    func filterTrackers(by filter: Filters) {
        switch filter {
        case .allTrackers:
            visibleCategories = trackerCategoryStore.categories.filter { !$0.trackers.isEmpty }
            
        case .todayTrackers:
            loadTodayTrackers()
            
        case .finishedTrackers:
            visibleCategories = trackerCategoryStore.categories.map { category in
                if category.title != pinnedCategoryName {
                    let updatedCategory = TrackerCategory(
                        title: category.title,
                        trackers: category.trackers.filter { tracker in
                            trackerRecordStore.records.contains { record in
                                record.trackerId == tracker.trackerId &&
                                record.date == currentDate
                            }
                        }
                    )
                    return updatedCategory
                } else {
                    return TrackerCategory(title: "", trackers: [])
                }
            }.filter { !$0.trackers.isEmpty }
            
            if trackerPinStore.pinnedTrackers != [],
               let pinCategory = trackerCategoryStore.categories.first(where: { $0.title == pinnedCategoryName }) {
                visibleCategories.insert(pinCategory, at: 0)
            }
            
        case .unfinishedTrackers:
            visibleCategories = trackerCategoryStore.categories.map { category in
                if category.title != pinnedCategoryName {
                    let updatedCategory = TrackerCategory(
                        title: category.title,
                        trackers: category.trackers.filter { tracker in
                            !trackerRecordStore.records.contains { record in
                                record.trackerId == tracker.trackerId
                            }
                        }
                    )
                    return updatedCategory
                } else {
                    return TrackerCategory(title: "", trackers: [])
                }
            }.filter { !$0.trackers.isEmpty }
            
            if trackerPinStore.pinnedTrackers != [],
               let pinCategory = trackerCategoryStore.categories.first(where: { $0.title == pinnedCategoryName }) {
                visibleCategories.insert(pinCategory, at: 0)
            }
        }
        
        collectionView.reloadData()
    }
}
