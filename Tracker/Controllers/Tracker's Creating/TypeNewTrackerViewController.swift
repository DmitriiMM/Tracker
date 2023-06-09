import UIKit

enum TypeTracker {
case repeatingTracker
case onetimeTracker
}

protocol TypeNewTrackerViewControllerDelegate: AnyObject {
    func create(newTracker: Tracker?)
    func create(newCategory: String?)
    func editTracker()
}

final class TypeNewTrackerViewController: UIViewController {
    weak var delegate: TypeNewTrackerViewControllerDelegate?
    var categories: [String]?
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.appFont(.medium, withSize: 16)
        label.textColor = .ypBlack
        label.text = "Создание трекера"
        
        return label
    }()
    
    private lazy var repeatingTrackerButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Привычка", for: .normal)
        button.setTitleColor(.ypWhite, for: .normal)
        button.titleLabel?.font = UIFont.appFont(.medium, withSize: 16)
        button.backgroundColor = .ypBlack
        button.layer.cornerRadius = 16
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(repeatingTrackerButtonTapped), for: .touchUpInside)
        
        return button
    }()
    
    private lazy var onetimeTrackerButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Нерегулярные событие", for: .normal)
        button.setTitleColor(.ypWhite, for: .normal)
        button.titleLabel?.font = UIFont.appFont(.medium, withSize: 16)
        button.backgroundColor = .ypBlack
        button.layer.cornerRadius = 16
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(onetimeTrackerButtonTapped), for: .touchUpInside)
        
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .ypWhite
        
        addSubviews()
        addConstraints()
    }
    
    @objc private func repeatingTrackerButtonTapped() {
        let newTrackerVC = NewTrackerViewController(isEditTracker: false)
        newTrackerVC.typeOfNewTracker = .repeatingTracker
        newTrackerVC.delegate = self
        present(newTrackerVC, animated: true)
    }
    
    @objc private func onetimeTrackerButtonTapped() {
        let newTrackerVC = NewTrackerViewController(isEditTracker: false)
        newTrackerVC.typeOfNewTracker = .onetimeTracker
        newTrackerVC.delegate = self
        present(newTrackerVC, animated: true)
    }
    
    private func addSubviews() {
        view.addSubview(titleLabel)
        view.addSubview(repeatingTrackerButton)
        view.addSubview(onetimeTrackerButton)
    }
    
    private func addConstraints() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        repeatingTrackerButton.translatesAutoresizingMaskIntoConstraints = false
        onetimeTrackerButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: view.topAnchor, constant: 40),
            
            repeatingTrackerButton.bottomAnchor.constraint(equalTo: view.centerYAnchor),
            repeatingTrackerButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            repeatingTrackerButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            repeatingTrackerButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            repeatingTrackerButton.heightAnchor.constraint(equalToConstant: 60),
            
            onetimeTrackerButton.leadingAnchor.constraint(equalTo: repeatingTrackerButton.leadingAnchor),
            onetimeTrackerButton.trailingAnchor.constraint(equalTo: repeatingTrackerButton.trailingAnchor),
            onetimeTrackerButton.heightAnchor.constraint(equalToConstant: 60),
            onetimeTrackerButton.topAnchor.constraint(equalTo: repeatingTrackerButton.bottomAnchor, constant: 16)
        ])
    }
}

extension TypeNewTrackerViewController: NewTrackerViewControllerDelegate {
    func editTracker() {
        delegate?.editTracker()
    }
    
    func create(newTracker: Tracker?) {
        delegate?.create(newTracker: newTracker)
    }
    
    func create(newCategory: String?) {
        delegate?.create(newCategory: newCategory)
    }
    
    func dismiss() {
        dismiss(animated: true)
    }
}
