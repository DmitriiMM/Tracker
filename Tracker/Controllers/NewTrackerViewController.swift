import UIKit

protocol NewTrackerViewControllerDelegate: AnyObject {
    func dismiss()
    func create(newTracker: Tracker?)
    func create(newCategory: String?)
}

final class NewTrackerViewController: UIViewController {
    private var currentCategory: String?
    private var trackerColor: UIColor?
    private var trackerEmoji: String?
    private var trackerText: String?
    private var trackerSchedule: [Weekday]?
    
    private var chosenName = false
    private var chosenCategory = false
    private var chosenSchedule = false
    private var chosenEmoji = false
    private var chosenColor = false
    
    weak var delegate: NewTrackerViewControllerDelegate?
    var lastCategory: IndexPath?
    var typeOfNewTracker: TypeTracker?
    private var heightTableView: Int = 74
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.appFont(.medium, withSize: 16)
        label.textColor = .ypBlack
        switch typeOfNewTracker {
        case .repeatingTracker: label.text = "Новая привычка"
        case .onetimeTracker: label.text = "Новое нерегулярное событие"
        case .none: break
        }
        
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
        
        switch typeOfNewTracker {
        case .repeatingTracker: heightTableView = 149
        case .onetimeTracker: heightTableView = 74
        case .none: break
        }
        
        collectionView.delegate = helper
        collectionView.dataSource = helper
        helper.delegate = self
        
        view.backgroundColor = .ypWhite
        
        addSubviews()
        addConstraints()
    }
    
    private func generateTrackerId() -> UUID {
        return UUID()
    }
    
    @objc private func cancelButtonTapped() {
        dismiss(animated: true)
        delegate?.dismiss()
    }
    
    @objc private func createButtonTapped() {
        guard let trackerText = trackerText,
              let category = currentCategory,
              let trackerEmoji = trackerEmoji,
              let trackerColor = trackerColor
        else {
            return
        }
        
        switch typeOfNewTracker {
        case .onetimeTracker:
            createNewTracker(trackerText: trackerText, category: category, trackerSchedule: nil, trackerEmoji: trackerEmoji, trackerColor: trackerColor)
            
        case .repeatingTracker:
            guard let trackerSchedule = trackerSchedule else { return }
            createNewTracker(trackerText: trackerText, category: category, trackerSchedule: trackerSchedule, trackerEmoji: trackerEmoji, trackerColor: trackerColor)
           
        case .none: break
        }
        
        dismiss(animated: true)
    }
    
    private func createNewTracker(trackerText: String, category: String, trackerSchedule: [Weekday]?, trackerEmoji: String, trackerColor: UIColor) {
        guard trackerText != "" else { return }
        let newTracker = Tracker(
            trackerId: generateTrackerId(),
            trackerText: trackerText,
            trackerEmoji: trackerEmoji,
            trackerColor: trackerColor,
            trackerSchedule: trackerSchedule
        )
        
        delegate?.create(newTracker: newTracker)
        delegate?.create(newCategory: category)
    }
    
    private func makeCreateButtonEnabled() {
        switch typeOfNewTracker {
        case .repeatingTracker:
            if chosenName == true && chosenCategory == true && chosenSchedule == true && chosenEmoji == true && chosenColor == true {
                createButton.backgroundColor = .ypBlack
                createButton.setTitleColor(.ypWhite, for: .normal)
            } else {
                createButton.backgroundColor = .ypGray
                createButton.setTitleColor(.white, for: .normal)
            }
        case .onetimeTracker:
            if chosenName == true && chosenCategory == true && chosenEmoji == true && chosenColor == true {
                createButton.backgroundColor = .ypBlack
                createButton.setTitleColor(.ypWhite, for: .normal)
            } else {
                createButton.backgroundColor = .ypGray
                createButton.setTitleColor(.white, for: .normal)
            }
        case .none: break
        }
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
            tableView.heightAnchor.constraint(equalToConstant: CGFloat(heightTableView)),
            
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
            guard let categoriesVC = CategoryCoordinator.assemble() as? CategoriesViewController else { return }
            categoriesVC.delegate = self
            categoriesVC.viewModel.checkmarkAt = lastCategory
            present(categoriesVC, animated: true)
        case 1: // "Расписание"
            let scheduleVC = ScheduleViewController()
            scheduleVC.delegate = self
            present(scheduleVC, animated: true)
        default: break
        }
    }
}

extension NewTrackerViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch typeOfNewTracker {
        case .repeatingTracker: return 2
        case .onetimeTracker: return 1
        case .none: return 0
        }
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
            if trackerSchedule == Weekday.allCases {
                cell.detailTextLabel?.text = "Каждый день"
            } else {
                if let trackerSchedule = trackerSchedule {
                    cell.detailTextLabel?.text = trackerSchedule
                        .map { $0.shortName }
                        .joined(separator: ", ")
                }
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

extension NewTrackerViewController: CategoriesViewControllerDelegate {
    func didSelectCategory(at indexPath: IndexPath?) {
        lastCategory = indexPath
    }
    
    func didSelectCategory(with name: String?) {
        currentCategory = name
        chosenCategory = true
        makeCreateButtonEnabled()
        tableView.reloadData()
    }
}

extension NewTrackerViewController: ScheduleViewControllerDelegate {
    func didSelect(schedule: [Weekday]?) {
        trackerSchedule = schedule
        chosenSchedule = true
        makeCreateButtonEnabled()
        tableView.reloadData()
    }
}

extension NewTrackerViewController: SupplementaryCollectionDelegate {
    func didSelect(emoji: String?) {
        trackerEmoji = emoji
        chosenEmoji = true
        makeCreateButtonEnabled()
    }
    
    func didSelect(color: UIColor?) {
        trackerColor = color
        chosenColor = true
        makeCreateButtonEnabled()
    }
}
