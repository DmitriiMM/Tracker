import UIKit

protocol NewCategoryViewControllerDelegate: AnyObject {
    func create(newCategory: String?)
    func update(editingCategory: String, with editedCategory: String)
}

final class NewCategoryViewController: UIViewController {
    weak var delegate: NewCategoryViewControllerDelegate?
    var editingCategory: TrackerCategory?
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.appFont(.medium, withSize: 16)
        label.textColor = .ypBlack
        label.text = "Новая категория"
        
        return label
    }()
    
    private lazy var textField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Введите название категории"
        let leftInsetView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 30))
        textField.leftView = leftInsetView
        textField.leftViewMode = .always
        textField.backgroundColor = .ypBackground
        textField.layer.cornerRadius = 16
        textField.clipsToBounds = true
        textField.delegate = self
        
        return textField
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
        
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .ypWhite
        textField.delegate = self
        
        textField.text = editingCategory?.title
        
        addSubviews()
        addConstraints()
    }
    
    @objc private func doneButtonTapped() {
        if textField.hasText {
            if let category = textField.text {
                if editingCategory == nil {
                    delegate?.create(newCategory: category)
                } else if let editingCategory = editingCategory {
                    delegate?.update(editingCategory: editingCategory.title, with: category)
                    self.editingCategory = nil
                }
                dismiss(animated: true)
            }
        }
    }
    
    private func addSubviews() {
        view.addSubview(titleLabel)
        view.addSubview(textField)
        view.addSubview(doneButton)
    }
    
    private func addConstraints() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        textField.translatesAutoresizingMaskIntoConstraints = false
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: view.topAnchor, constant: 40),
            
            textField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 38),
            textField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            textField.heightAnchor.constraint(equalToConstant: 75),
            textField.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -32),
            
            doneButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50),
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            doneButton.heightAnchor.constraint(equalToConstant: 60),
        ])
    }
}

extension NewCategoryViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
       
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if range.location == 0 && string == " " {
            return false
        } else if textField.text?.isEmpty == true && !string.isEmpty {
            doneButton.backgroundColor = .ypBlack
            doneButton.setTitleColor(.ypWhite, for: .normal)
        }
        
        return true
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        if textField.text?.isEmpty == true {
            doneButton.backgroundColor = .ypGray
            doneButton.setTitleColor(.white, for: .normal)
        }
    }
}
