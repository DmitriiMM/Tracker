import UIKit
import CoreData

protocol TrackerCategoryStoreDelegate: AnyObject {
    func storeDidUpdate(_ store: TrackerCategoryStore)
}

final class TrackerCategoryStore: NSObject {
    private let context: NSManagedObjectContext
    private let trackerStore = TrackerStore()
    weak var delegate: TrackerCategoryStoreDelegate?
    
    convenience override init() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        self.init(context: context)
    }
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCategoryCoreData> = {
        let fetchRequest = NSFetchRequest<TrackerCategoryCoreData>(entityName: "TrackerCategoryCoreData")
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \TrackerCategoryCoreData.categoryTitle, ascending: true)
        ]
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        try? fetchedResultsController.performFetch()
        
        return fetchedResultsController
    }()
    
    var categories: [TrackerCategory] {
        guard
            let objects = self.fetchedResultsController.fetchedObjects,
            let categories = try? objects.map({ try self.fetchCategories(from: $0) })
        else { return [] }
        
        return categories
    }
    
    func fetchCategories(from trackerCategoryCoreData: TrackerCategoryCoreData) throws -> TrackerCategory {
        guard let title = trackerCategoryCoreData.categoryTitle else {
            throw StoreError.decodingErrorInvalidCategoryTitle
        }
        guard let trackers = trackerCategoryCoreData.trackers else {
            throw StoreError.decodingErrorInvalidTrackers
        }
        
        return TrackerCategory(
            title: title,
            trackers: trackers.allObjects.compactMap { convert($0 as? TrackerCoreData) }
        )
    }
    
    func convert(_ tracker: TrackerCoreData?) -> Tracker? {
        guard let tracker = tracker,
              let trackerId = tracker.trackerId,
              let trackerText = tracker.trackerText,
              let trackerEmoji = tracker.trackerEmoji,
              let trackerColorHex = tracker.trackerColorHex
        else { return nil }
        
        return Tracker(
            trackerId: trackerId,
            trackerText: trackerText,
            trackerEmoji: trackerEmoji,
            trackerColor: UIColorMarshalling().color(from: trackerColorHex),
            trackerSchedule: WeekDaysMarshalling().convertStringToWeekDays(tracker.trackerSchedule)
        )
    }
    
    func fetchCategory(with name: String) throws -> TrackerCategoryCoreData? {
        let request = fetchedResultsController.fetchRequest
        request.predicate = NSPredicate(format: "%K == %@", argumentArray: ["categoryTitle", name])
        
        do {
            let category = try context.fetch(request).first
            return category
        } catch {
            throw StoreError.decodingErrorInvalidCategoryEntity
        }
    }
    
    func save(_ tracker: Tracker, to categoryName: String) throws {
        let trackerCoreData = try trackerStore.makeTracker(from: tracker)
        
        if let existingCategory = try? fetchCategory(with: categoryName),
           let trackers = existingCategory.trackers,
           var newCoreDataTrackers = trackers.allObjects as? [TrackerCoreData] {
            newCoreDataTrackers.append(trackerCoreData)
            existingCategory.trackers = NSSet(array: newCoreDataTrackers)
        } else {
            let newCategory = TrackerCategoryCoreData(context: context)
            newCategory.categoryTitle = categoryName
            newCategory.trackers = NSSet(array: [trackerCoreData])
        }
        
        try context.save()
    }
    
    func makeCategory(with label: String) throws {
        let category = TrackerCategory(title: label, trackers: [])
        let categoryCoreData = TrackerCategoryCoreData(context: context)
        categoryCoreData.categoryTitle = category.title
        categoryCoreData.trackers = NSSet(array: category.trackers)
        
        try context.save()
    }
    
    func deleteCategory(_ category: TrackerCategory) throws {
        if let category = try fetchCategory(with: category.title) {
            context.delete(category)
        }
        
        try context.save()
    }
    
    func editCategory(from existingLabel: String, with label: String) throws {
        guard let existingCategoryCD = try? fetchCategory(with: existingLabel) else { return }
        try makeCategory(with: label)
        guard let updatedCategoryCD = try? fetchCategory(with: label) else { return }
        
        updatedCategoryCD.trackers = existingCategoryCD.trackers
        try context.save()
        
        guard let category = try? fetchCategories(from: existingCategoryCD) else { return }
        try deleteCategory(category)
    }
    
    func remove(_ tracker: Tracker, from oldCategoryName: String) throws {
        if let oldCategory = try? fetchCategory(with: oldCategoryName),
           let oldCategoryTrackers = oldCategory.trackers,
           var oldTrackersCoreData = oldCategoryTrackers.allObjects as? [TrackerCoreData] {
            oldTrackersCoreData.removeAll(where: { $0.trackerId == tracker.trackerId})
            oldCategory.trackers = NSSet(array: oldTrackersCoreData)
        }
        
        try context.save()
    }
    
    func move(_ tracker: Tracker, to newCategoryName: String) throws {
        guard let trackerCoreData = try trackerStore.fetchTracker(with: tracker.trackerId) else { return }
        
        if let newCategory = try? fetchCategory(with: newCategoryName),
           let newCategoryTrackers = newCategory.trackers,
           var newTrackersCoreData = newCategoryTrackers.allObjects as? [TrackerCoreData] {
            newTrackersCoreData.append(trackerCoreData)
            newCategory.trackers = NSSet(array: newTrackersCoreData)
        }
        
        try context.save()
    }
}

extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.storeDidUpdate(self)
    }
}
