import UIKit
//
//struct SomeConfiguration {
//    let lastCategory: IndexPath?
//}
//
//final class SomeCoordinator {
//    static func start(with configuration: SomeConfiguration) -> UIViewController {
//        let viewController = assemble(with: configuration)
//        return viewController
//    }
//
//    private static func assemble(with configuration: SomeConfiguration) -> UIViewController {
//        let categoryStore = TrackerCategoryStore(context: (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext)
//        let viewModel = CategoriesViewModel(categoryStore: categoryStore)
//        let viewController = CategoriesViewController(viewModel: viewModel, lastCategory: configuration.lastCategory)
//        return viewController
//    }
//}

final class CategoryCoordinator {
//    static func start() -> UIViewController {
//        let viewController = assemble()
//        return viewController
//    }
    
    static func assemble() -> UIViewController {
        let categoryStore = TrackerCategoryStore(context: (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext)
        let viewModel = CategoriesViewModel(categoryStore: categoryStore)
        let viewController = CategoriesViewController(viewModel: viewModel)
        return viewController
    }
}
