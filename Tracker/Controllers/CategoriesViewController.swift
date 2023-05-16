import UIKit

protocol CategoriesViewControllerDelegate: AnyObject {
    func didSelectCategory(at indexPath: IndexPath?)
    func didSelectCategory(with name: String?)
}

final class CategoriesViewController: UIViewController {
    private var heightTableView: Int = -1
    var checkmarkedCell: IndexPath?
    
    weak var delegate: CategoriesViewControllerDelegate?
    var viewModel: CategoriesViewModel
    
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
        label.text = "Привычки и события можно объединить по смыслу"
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
    
    init(viewModel: CategoriesViewModel, lastCategory: IndexPath?) {
        self.viewModel = viewModel
        checkmarkedCell = lastCategory
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.$categories.bind { [weak self] _ in
            guard let self = self else { return }
            
            self.tableView.reloadData()
        }
        
        viewModel.$checkmarkedCell.bind { [weak self] _ in
            guard let self = self else { return }
            self.delegate?.didSelectCategory(at: self.viewModel.checkmarkedCell)
            self.tableView.reloadData()
        }
        
        if self.viewModel.categories?.count != 0 {
            self.heightTableView = self.viewModel.categories!.count * 75 - 1
            self.emptyCategoryLabel.isHidden = true
            self.emptyCategoryImageView.isHidden = true
        }
        
        view.backgroundColor = .ypWhite
        
        addSubviews()
        addConstraints()
        
        guard let checkmarkedCell = checkmarkedCell else { return }
        viewModel.selectCategory(at: checkmarkedCell)
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
    
    private func deleteCategory(_ category: TrackerCategory) {
        let alertModel = AlertModel(
            title: nil,
            message: "Эта категория точно не нужна?",
            buttonText: "Удалить",
            completion: { [weak self] _ in
                self?.viewModel.deleteCategory(category: category)
            },
            cancelText: "Отменить",
            cancelCompletion: nil
        )
        
        AlertPresenter().show(controller: self, model: alertModel)
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
        viewModel.selectCategory(at: indexPath)
        
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        delegate?.didSelectCategory(with: cell.textLabel?.text)
        dismiss(animated: true)
    }
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        guard let category = viewModel.categories?[indexPath.row] else { return nil }
        
        return UIContextMenuConfiguration(actionProvider:  { _ in
            UIMenu(children: [
                UIAction(title: "Редактировать") { [weak self] _ in
                    self?.editCategory(category)
                },
                UIAction(title: "Удалить", attributes: .destructive) { [weak self] _ in
                    self?.deleteCategory(category)
                }
            ])
        })
    }
}

extension CategoriesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return viewModel.categories?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = .ypBackground
        cell.textLabel?.font = UIFont.appFont(.regular, withSize: 17)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell") else { return UITableViewCell() }
        cell.textLabel?.text = viewModel.categories?[indexPath.row].title
        cell.accessoryType = indexPath == viewModel.checkmarkedCell ? .checkmark : .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
}

extension CategoriesViewController: NewCategoryViewControllerDelegate {
    func create(newCategory: String?) {
        guard let category = newCategory else { return }
        viewModel.addNewCategory(with: category)
        
        heightTableView += 75
        
        if let heightConstraint = tableView.constraints.first(where: { $0.firstAttribute == .height && $0.relation == .equal && $0.secondItem == nil && $0.secondAttribute == .notAnAttribute }) {
            heightConstraint.constant = CGFloat(heightTableView)
            tableView.layoutIfNeeded()
        }
        
        emptyCategoryLabel.isHidden = true
        emptyCategoryImageView.isHidden = true
    }
    
    func update(editingCategory: String?, with editedCategory: String?) {
        guard let editingCategory = editingCategory,
              let editedCategory = editedCategory
        else { return }
        
        viewModel.editCategory(from: editingCategory, with: editedCategory)
    }
}
