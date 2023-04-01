import UIKit

final class NewTrackerViewController: UIViewController {
    private var currentCategory: String?
    private var currentSchedule: [String]?
    private var category: String?
    private var trackerColor: UIColor?
    private var trackerEmoji: String?
    private var trackerText: String?
    private var trackerSchedule: [String]?
    
    private var chosenName = false
    private var chosenCategory = false
    private var chosenSchedule = false
    private var chosenEmoji = false
    private var chosenColor = false
    
    weak var delegateTransition: ScreenTransitionProtocol?
    var categories: [String]?
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.appFont(.medium, withSize: 16)
        label.textColor = .ypBlack
        label.text = "Новая привычка"
        
        return label
    }()
    
    private lazy var scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.backgroundColor = .ypWhite
        scroll.frame = view.bounds
        
        return scroll
    }()
    
    private lazy var textField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Введите название трекера"
        textField.clearButtonMode = .whileEditing
        let leftInsetView = UIView(frame: CGRect(x: 0, y: 0, width: 17, height: 30))
        textField.leftView = leftInsetView
        textField.leftViewMode = .always
        textField.backgroundColor = .ypBackground
        textField.layer.cornerRadius = 16
        textField.clipsToBounds = true
        textField.delegate = self
        
        return textField
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .ypBackground
        tableView.layer.cornerRadius = 16
        tableView.clipsToBounds = true
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.separatorColor = .ypGray
        tableView.isScrollEnabled = false

        return tableView
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Отменить", for: .normal)
        button.setTitleColor(.ypRed, for: .normal)
        button.titleLabel?.font = UIFont.appFont(.medium, withSize: 16)
        button.backgroundColor = .ypWhite
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.ypRed.cgColor
        button.layer.cornerRadius = 16
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        
        return button
    }()
    
    private lazy var createButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Создать", for: .normal)
        button.setTitleColor(.ypWhite, for: .normal)
        button.titleLabel?.font = UIFont.appFont(.medium, withSize: 16)
        button.backgroundColor = .ypGray
        button.layer.cornerRadius = 16
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
        
        return button
    }()
    
    private lazy var collectionView: UICollectionView = {
        let collection = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collection.backgroundColor = .ypWhite
        return collection
    }()
    
    private let helper = SupplementaryCollection()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.register(SupplementaryView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
        
        collectionView.register(SuplementaryCollectionCell.self, forCellWithReuseIdentifier: SuplementaryCollectionCell().identifier)
        
        collectionView.delegate = helper
        collectionView.dataSource = helper
        helper.delegateTransition = self
        
        view.backgroundColor = .ypWhite
        
        addSubviews()
        addConstraints()
    }
    
    private func generateTrackerId() -> UUID {
        return UUID()
    }
    
    @objc private func cancelButtonTapped() {
        delegateTransition?.onTransition(value: "", for: "dismiss")
        dismiss(animated: true)
    }
    
    @objc private func createButtonTapped() {
        guard let trackerText = trackerText,
              let category = category,
              let trackerEmoji = trackerEmoji,
              let trackerColor = trackerColor
        else {
            return
        }
        
        createNewTracker(trackerText: trackerText, category: category, trackerSchedule: trackerSchedule, trackerEmoji: trackerEmoji, trackerColor: trackerColor)
        
        dismiss(animated: true)
    }
    
    private func createNewTracker(trackerText: String, category: String, trackerSchedule: [String]?, trackerEmoji: String, trackerColor: UIColor) {
        guard let trackerSchedule = trackerSchedule,
              trackerText != ""
        else {
            return
        }
        
        let newTracker = Tracker(
            trackerId: generateTrackerId(),
            trackerText: trackerText,
            trackerEmoji: trackerEmoji,
            trackerColor: trackerColor,
            trackerSchedule: trackerSchedule
        )
        delegateTransition?.onTransition(value: newTracker, for: "newTracker")
        delegateTransition?.onTransition(value: category, for: "newCategory")
    }
    
    private func addSubviews() {
        view.addSubview(titleLabel)
        view.addSubview(scrollView)
        scrollView.addSubview(textField)
        scrollView.addSubview(tableView)
        scrollView.addSubview(collectionView)
        scrollView.addSubview(cancelButton)
        scrollView.addSubview(createButton)
    }
    
    private func addConstraints() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        textField.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        createButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: view.topAnchor, constant: 40),
            
            scrollView.widthAnchor.constraint(equalTo: view.widthAnchor),
            scrollView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            textField.topAnchor.constraint(equalTo: scrollView.topAnchor),
            textField.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            textField.heightAnchor.constraint(equalToConstant: 75),
            textField.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -32),
            
            tableView.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: textField.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: textField.trailingAnchor),
            tableView.heightAnchor.constraint(equalToConstant: 149),
            
            collectionView.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 32),
            collectionView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: 484),
            
            createButton.topAnchor.constraint(equalTo: collectionView.bottomAnchor),
            
            cancelButton.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
            cancelButton.trailingAnchor.constraint(equalTo: scrollView.centerXAnchor, constant: -4),
            cancelButton.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -34),
            cancelButton.heightAnchor.constraint(equalToConstant: 60),
            
            createButton.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20),
            createButton.leadingAnchor.constraint(equalTo: scrollView.centerXAnchor, constant: 4),
            createButton.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -34),
            createButton.heightAnchor.constraint(equalToConstant: 60),
        ])
    }
}

extension NewTrackerViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0: // "Категория"
            let categoriesVC = CategoriesViewController()
            categoriesVC.delegateTransition = self
            categoriesVC.categories = categories
            present(categoriesVC, animated: true)
        case 1: // "Расписание"
            let scheduleVC = ScheduleViewController()
            scheduleVC.delegateTransition = self
            present(scheduleVC, animated: true)
        default: break
        }
    }
}

extension NewTrackerViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        cell.accessoryType = .disclosureIndicator
        cell.selectionStyle = .none
        cell.backgroundColor = .clear
        cell.detailTextLabel?.font = .appFont(.regular, withSize: 17)
        cell.detailTextLabel?.textColor = .ypGray
        
        switch indexPath.row {
        case 0:
            cell.textLabel?.text = "Категория"
            cell.detailTextLabel?.text = currentCategory
            
        case 1:
            cell.textLabel?.text = "Расписание"
            if currentSchedule?.count == 7 {
                cell.detailTextLabel?.text = "Каждый день"
            } else {
                let sortedDays = currentSchedule?.sorted { first, second in
                    let orderedDays = ["Пн", "Вт", "Ср", "Чт", "Пт", "Сб", "Вс"]
                    return orderedDays.firstIndex(of: first)! < orderedDays.firstIndex(of: second)!
                }
                
                let days = sortedDays?.joined(separator: ", ")
                cell.detailTextLabel?.text = days
            }
            
        default:
            break
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
}

extension NewTrackerViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        trackerText = textField.text
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if range.location == 0 && string == " " {
            return false
        } else if textField.text?.isEmpty == true && !string.isEmpty {
            chosenName = true
        }
        
        return true
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        if textField.text?.isEmpty == true {
            chosenName = false
        }
    }
}

extension NewTrackerViewController: ScreenTransitionProtocol {
    func onTransition<T>(value: T, for key: String) {
        switch key {
        case "categories":
            categories = value as? [String]
        case "category":
            currentCategory = value as? String
            tableView.reloadData()
            category = value as? String
            chosenCategory = true
        case "color":
            trackerColor = value as? UIColor
            chosenColor = true
        case "emoji":
            trackerEmoji = value as? String
            chosenEmoji = true
        case "schedule":
            currentSchedule = value as? [String]
            tableView.reloadData()
            chosenSchedule = true
            trackerSchedule = value as? [String]
        default:
            break
        }
        
        if chosenName == true && chosenCategory == true && chosenSchedule == true && chosenEmoji == true && chosenColor == true {
            createButton.backgroundColor = .ypBlack
            createButton.setTitleColor(.ypWhite, for: .normal)
        } else {
            createButton.backgroundColor = .ypGray
            createButton.setTitleColor(.white, for: .normal)
        }
    }
}
