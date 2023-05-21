import UIKit

struct CategoryConfiguration {
    let lastCategory: String?
}

final class CategoryCoordinator {
    static func start(with configuration: CategoryConfiguration) -> UIViewController {
        let viewController = assemble(with: configuration)
        return viewController
    }
    
    private static func assemble(with configuration: CategoryConfiguration) -> UIViewController {
        let categoryStore = TrackerCategoryStore(context: (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext)
        let lastCategory = configuration.lastCategory
        let viewModel = CategoriesViewModel(categoryStore: categoryStore, lastCategory: lastCategory)
        let viewController = CategoriesViewController(viewModel: viewModel)
        return viewController
    }
}
