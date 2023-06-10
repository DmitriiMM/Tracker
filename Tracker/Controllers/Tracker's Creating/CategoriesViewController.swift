import UIKit

protocol CategoriesViewControllerDelegate: AnyObject {
    func didSelectCategory(with name: String?)
}

final class CategoriesViewController: UIViewController {
    private var heightTableView: Int = -1
    private var tableViewHeightConstraint: NSLayoutConstraint?
    
    weak var delegate: CategoriesViewControllerDelegate?
    var viewModel: CategoriesViewModel
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.appFont(.medium, withSize: 16)
        label.textColor = .ypBlack
        label.text = "CATEGORY".localized
        
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
        label.text = "ZERO_CATEGORIES".localized
        label.numberOfLines = 2
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
        tableView.alwaysBounceVertical = false
        tableView.bounces = false
        
        return tableView
    }()
    
    private lazy var addCategoryButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("ADD_CATEGORY".localized, for: .normal)
        button.setTitleColor(.ypWhite, for: .normal)
        button.titleLabel?.font = UIFont.appFont(.medium, withSize: 16)
        button.backgroundColor = .ypBlack
        button.layer.cornerRadius = 16
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(addCategoryButtonTapped), for: .touchUpInside)
        
        return button
    }()
    
    init(viewModel: CategoriesViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.$selectedCategoryName.bind { [weak self] _ in
            guard let self = self else { return }
            self.delegate?.didSelectCategory(with: self.viewModel.selectedCategoryName)
            self.tableView.reloadData()
        }
        
        viewModel.$categories.bind { [weak self] _ in
            guard let self = self else { return }
            if self.viewModel.categories?.count != 0 {
                self.tableView.isHidden = false
                self.emptyCategoryLabel.isHidden = true
                self.emptyCategoryImageView.isHidden = true
            } else {
                self.tableView.isHidden = true
                self.emptyCategoryLabel.isHidden = false
                self.emptyCategoryImageView.isHidden = false
            }
            
            self.tableView.reloadData()
            DispatchQueue.main.async {
                self.tableViewHeightConstraint?.constant = self.tableView.contentSize.height - 1
            }
        }
        
        viewModel.$alertModel.bind { [weak self] alertModel in
            guard let self, let alertModel else { return }
            AlertPresenter().show(controller: self, model: alertModel)
        }
        
        if let categories = viewModel.categories?.filter({ $0.title != "PINNED".localized }),
            categories.count != 0 {
           heightTableView = categories.count * 75 - 1
           emptyCategoryLabel.isHidden = true
           emptyCategoryImageView.isHidden = true
        }
        
        view.backgroundColor = .ypWhite
        
        addSubviews()
        addConstraints()
        
        tableViewHeightConstraint = tableView.heightAnchor.constraint(equalToConstant: CGFloat(heightTableView))
        tableViewHeightConstraint?.priority = .defaultLow
        tableViewHeightConstraint?.isActive = true
    }
    
    @objc private func addCategoryButtonTapped() {
        let newCategoryVC = NewCategoryViewController()
        newCategoryVC.delegate = self
        present(newCategoryVC, animated: true)
    }
    
    private func editCategory(_ category: TrackerCategory) {
        let newCategoryVC = NewCategoryViewController()
        newCategoryVC.delegate = self
        newCategoryVC.editingCategory = category
        
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
            emptyCategoryLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            emptyCategoryLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            emptyCategoryImageView.bottomAnchor.constraint(equalTo: emptyCategoryLabel.topAnchor, constant: -8),
            emptyCategoryImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyCategoryImageView.heightAnchor.constraint(equalToConstant: 80),
            emptyCategoryImageView.widthAnchor.constraint(equalToConstant: 80),
            
            tableView.topAnchor.constraint(equalTo: view.topAnchor, constant: 73),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(lessThanOrEqualTo: addCategoryButton.topAnchor, constant: -16),
            
            addCategoryButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50),
            addCategoryButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addCategoryButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addCategoryButton.heightAnchor.constraint(equalToConstant: 60),
        ])
    }
}

extension CategoriesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath),
              let categoryName = cell.textLabel?.text else { return }
        viewModel.selectCategory(with: categoryName)
        
        dismiss(animated: true)
    }
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        guard let category = viewModel.categories?[indexPath.row] else { return nil }
        
        return UIContextMenuConfiguration(actionProvider:  { _ in
            UIMenu(children: [
                UIAction(title: "EDIT".localized) { [weak self] _ in
                    self?.editCategory(category)
                },
                UIAction(title: "DELETE".localized, attributes: .destructive) { [weak self] _ in
                    self?.viewModel.showAlertToDelete(category)
                }
            ])
        })
    }
}

extension CategoriesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return viewModel.categories?.filter({ $0.title != "PINNED".localized }).count ?? 0
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = .ypBackground
        cell.textLabel?.font = UIFont.appFont(.regular, withSize: 17)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell"),
            let categories = viewModel.categories?.filter({ $0.title != "PINNED".localized })
        else {
            return UITableViewCell()
        }

        cell.textLabel?.text = categories[indexPath.row].title
        cell.accessoryType = cell.textLabel?.text == viewModel.selectedCategoryName ? .checkmark : .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
}

extension CategoriesViewController: NewCategoryViewControllerDelegate {
    func create(newCategory: String?) {
        viewModel.addNewCategory(with: newCategory)
    }
    
    func update(editingCategory: String, with editedCategory: String) {
        viewModel.editCategory(from: editingCategory, with: editedCategory)
    }
}
