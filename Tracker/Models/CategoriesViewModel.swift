import Foundation

final class CategoriesViewModel {
    
    @Observable
    private(set) var categories: [TrackerCategory]?
    
    @Observable
    private(set) var checkmarkedCell: IndexPath?
    
    private let categoryStore: TrackerCategoryStore
    
    init(categoryStore: TrackerCategoryStore) {
        self.categoryStore = categoryStore
        categories = getCategoriesFromStore()
    }
    
    func selectCategory(at indexPath: IndexPath) {
        checkmarkedCell = indexPath
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
