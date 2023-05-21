import Foundation

final class CategoriesViewModel {
    
    @Observable
    private(set) var categories: [TrackerCategory]?
    
    @Observable
    private(set) var alertModel: AlertModel?
    
    var checkmarkAt: IndexPath?
    private let categoryStore: TrackerCategoryStore
    
    init(categoryStore: TrackerCategoryStore) {
        self.categoryStore = categoryStore
        categories = getCategoriesFromStore()
    }
    
    func deleteCategory(at indexPath: IndexPath) {
        let deletingCategory = categoryStore.categories[indexPath.row]
        let alertModel = AlertModel(
            title: nil,
            message: "Эта категория точно не нужна?",
            buttonText: "Удалить",
            completion: { [weak self] _ in
                self?.deleteCategory(category: deletingCategory)
            },
            cancelText: "Отменить",
            cancelCompletion: nil
        )
        
        self.alertModel = alertModel
    }
    
    func selectCategory(at indexPath: IndexPath) {
        checkmarkAt = indexPath
    }
    
    func addNewCategory(with label: String) {
        do {
            try categoryStore.makeCategory(with: label)
            categories = getCategoriesFromStore()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func editCategory(from existingLabel: String?, with label: String?) {
        guard let existingLabel = existingLabel,
              let label = label
        else { return }
        
        do {
            try categoryStore.editCategory(from: existingLabel, with: label)
        } catch {
            print(error.localizedDescription)
        }
        categories = getCategoriesFromStore()
    }
    
    func deleteCategory(category: TrackerCategory) {
        do {
            try categoryStore.deleteCategory(with: category)
            categories = getCategoriesFromStore()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    private func getCategoriesFromStore() -> [TrackerCategory] {
        return categoryStore.categories.map {
            TrackerCategory(title: $0.title, trackers: $0.trackers)
        }
    }
}

extension CategoriesViewModel: TrackerCategoryStoreDelegate {
    func storeDidUpdate(_ store: TrackerCategoryStore) {
        categories = getCategoriesFromStore()
    }
}
