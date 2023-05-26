import UIKit

enum Weekday: String, CaseIterable {
    case monday = "Понедельник"
    case tuesday = "Вторник"
    case wednesday = "Среда"
    case thursday = "Четверг"
    case friday = "Пятница"
    case saturday = "Суббота"
    case sunday = "Воскресенье"

    var shortName: String {
        switch self {
        case .monday:
            return "Пн"
        case .tuesday:
            return "Вт"
        case .wednesday:
            return "Ср"
        case .thursday:
            return "Чт"
        case .friday:
            return "Пт"
        case .saturday:
            return "Сб"
        case .sunday:
            return "Вс"
        }
    }
    
    var indexDay: Int {
        switch self {
        case .monday:
            return 1
        case .tuesday:
            return 2
        case .wednesday:
            return 3
        case .thursday:
            return 4
        case .friday:
            return 5
        case .saturday:
            return 6
        case .sunday:
            return 7
        }
    }
}


protocol ScheduleViewControllerDelegate: AnyObject {
    func didSelect(schedule: [Weekday]?)
}

final class ScheduleViewController: UIViewController {
    private let days: [Weekday] = Weekday.allCases
    private var schedule: [Weekday] = []
    weak var delegate: ScheduleViewControllerDelegate?
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.appFont(.medium, withSize: 16)
        label.textColor = .ypBlack
        label.text = "Расписание"
        
        return label
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.layer.cornerRadius = 16
        tableView.clipsToBounds = true
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.separatorColor = .ypGray
        tableView.backgroundColor = .ypWhite
        tableView.isScrollEnabled = false

        return tableView
    }()
    
    private lazy var doneButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Готово", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.appFont(.medium, withSize: 16)
        button.backgroundColor = .ypGray
        button.layer.cornerRadius = 16
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        button.isEnabled = false
        
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .ypWhite
        
        addSubviews()
        addConstraints()
    }
    
    @objc private func doneButtonTapped() {
        delegate?.didSelect(schedule: schedule)
        dismiss(animated: true)
    }
    
    private func addSubviews() {
        view.addSubview(titleLabel)
        view.addSubview(tableView)
        view.addSubview(doneButton)
    }
    
    private func addConstraints() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: view.topAnchor, constant: 40),
            
            tableView.topAnchor.constraint(equalTo: view.topAnchor, constant: 73),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: 524),

            doneButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50),
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            doneButton.heightAnchor.constraint(equalToConstant: 60),
        ])
    }
}

extension ScheduleViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    }
}

extension ScheduleViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        days.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let switcher = UISwitch()
        switcher.onTintColor = .ypBlue
        switcher.tag = indexPath.row
        switcher.addTarget(self, action: #selector(switchTap(_:)), for: .valueChanged)
        
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        cell.selectionStyle = .none
        cell.backgroundColor = .ypBackground
        cell.textLabel?.text = days[indexPath.row].rawValue
        cell.textLabel?.font = UIFont.appFont(.regular, withSize: 17)
        cell.accessoryView = switcher
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    @objc func switchTap(_ sender: UISwitch) {
        if sender.isOn {
            doneButton.backgroundColor = .ypBlack
            doneButton.setTitleColor(.ypWhite, for: .normal)
            doneButton.isEnabled = true
            
            switch sender.tag {
            case 0: schedule.append(.monday)
            case 1: schedule.append(.tuesday)
            case 2: schedule.append(.wednesday)
            case 3: schedule.append(.thursday)
            case 4: schedule.append(.friday)
            case 5: schedule.append(.saturday)
            case 6: schedule.append(.sunday)
            default: break
            }
        } else {
            switch sender.tag {
            case 0: schedule.removeAll { $0 == .monday }
            case 1: schedule.removeAll { $0 == .tuesday }
            case 2: schedule.removeAll { $0 == .wednesday }
            case 3: schedule.removeAll { $0 == .thursday }
            case 4: schedule.removeAll { $0 == .friday }
            case 5: schedule.removeAll { $0 == .saturday }
            case 6: schedule.removeAll { $0 == .sunday }
            default: break
            }
        }
    }
}
