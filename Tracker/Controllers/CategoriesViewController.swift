import UIKit

final class CategoriesViewController: UIViewController {
    private var heightTableView: Int = -1
    weak var delegateTransition: ScreenTransitionProtocol?
    var categories: [String]?
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.appFont(.medium, withSize: 16)
        label.textColor = .ypBlack
        label.text = "Категория"
        
        return label
    }()
    
    private lazy var emptyCategoryImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "star")
        
        return imageView
    }()
    
    private lazy var emptyCategoryLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.appFont(.medium, withSize: 12)
        label.text = """
                    Привычки и события можно
                    объединить по смыслу
                    """
        label.textColor = .ypBlack
        label.textAlignment = .center
        
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

        return tableView
    }()
    
    private lazy var addCategoryButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Добавить категорию", for: .normal)
        button.setTitleColor(.ypWhite, for: .normal)
        button.titleLabel?.font = UIFont.appFont(.medium, withSize: 16)
        button.backgroundColor = .ypBlack
        button.layer.cornerRadius = 16
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(addCategoryButtonTapped), for: .touchUpInside)
        
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if categories?.count != 0 {
            heightTableView = categories!.count * 75 - 1
            emptyCategoryLabel.isHidden = true
            emptyCategoryImageView.isHidden = true
        }
        
        view.backgroundColor = .ypWhite
        
        addSubviews()
        addConstraints()
    }
    
    @objc private func addCategoryButtonTapped() {
        let newCategoryVC = NewCategoryViewController()
        newCategoryVC.delegateTransition = self
        present(newCategoryVC, animated: true)
    }
    
    private func addSubviews() {
        view.addSubview(titleLabel)
        view.addSubview(emptyCategoryImageView)
        view.addSubview(emptyCategoryLabel)
        view.addSubview(tableView)
        view.addSubview(addCategoryButton)
    }
    
    private func addConstraints() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        emptyCategoryImageView.translatesAutoresizingMaskIntoConstraints = false
        emptyCategoryLabel.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        addCategoryButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: view.topAnchor, constant: 40),
            
            emptyCategoryLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyCategoryLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            emptyCategoryImageView.bottomAnchor.constraint(equalTo: emptyCategoryLabel.topAnchor, constant: -8),
            emptyCategoryImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyCategoryImageView.heightAnchor.constraint(equalToConstant: 80),
            emptyCategoryImageView.widthAnchor.constraint(equalToConstant: 80),
            
            tableView.topAnchor.constraint(equalTo: view.topAnchor, constant: 73),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: CGFloat(heightTableView)),

            addCategoryButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50),
            addCategoryButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addCategoryButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addCategoryButton.heightAnchor.constraint(equalToConstant: 60),
        ])
    }
}

extension CategoriesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        cell.accessoryType = .checkmark
        dismiss(animated: true) {
            self.delegateTransition?.onTransition(value: cell.textLabel?.text, for: "category")
            self.delegateTransition?.onTransition(value: self.categories, for: "categories")
        }
    }
}

extension CategoriesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return categories?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell") else { return UITableViewCell() }
       
        cell.backgroundColor = .ypBackground
        
        cell.textLabel?.text = categories?[indexPath.row]
        cell.textLabel?.font = UIFont.appFont(.regular, withSize: 17)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
}

extension CategoriesViewController: ScreenTransitionProtocol {
    func onTransition<T>(value: T, for key: String) {
        if let stringValue = value as? String {
            if let notNilCategories = categories {
                if !notNilCategories.contains(where: { $0 == stringValue }) {
                    categories?.append(stringValue)
                    
                    heightTableView += 75
                    
                    if let heightConstraint = tableView.constraints.first(where: { $0.firstAttribute == .height && $0.relation == .equal && $0.secondItem == nil && $0.secondAttribute == .notAnAttribute }) {
                        heightConstraint.constant = CGFloat(heightTableView)
                        tableView.layoutIfNeeded()
                    }
                    
                    emptyCategoryLabel.isHidden = true
                    emptyCategoryImageView.isHidden = true
                    
                    tableView.reloadData()
                }
            } else {
                categories?.append(stringValue)
                
                heightTableView += 75
                
                if let heightConstraint = tableView.constraints.first(where: { $0.firstAttribute == .height && $0.relation == .equal && $0.secondItem == nil && $0.secondAttribute == .notAnAttribute }) {
                    heightConstraint.constant = CGFloat(heightTableView)
                    tableView.layoutIfNeeded()
                }
                
                emptyCategoryLabel.isHidden = true
                emptyCategoryImageView.isHidden = true
                
                tableView.reloadData()
            }
        }
    }
}
