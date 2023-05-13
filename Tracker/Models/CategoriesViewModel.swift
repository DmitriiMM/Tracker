import UIKit

final class CategoriesViewModel {
    
    @Observable
    private(set) var categories: [TrackerCategory]?
    
    private let categoryStore: TrackerCategoryStore
    private let categoriesViewController = CategoriesViewController()
    
    convenience init() {
        let categoryStore = TrackerCategoryStore(
            context: (UIApplication.shared.delegate as! AppDelegate).persistantConteiner.viewContext
        )
        self.init(categoryStore: categoryStore)
    }
    
    init(categoryStore: TrackerCategoryStore) {
        self.categoryStore = categoryStore
        categories = getCategoriesFromStore()
    }
    
    func addNewCategory(with label: String) {
        do {
            try categoryStore.makeCategory(with: label)
            categories = getCategoriesFromStore()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func editCategory(from existingLabel: String, with label: String) {
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
