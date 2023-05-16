import UIKit
import CoreData

final class TrackerStore: NSObject {
    private let context: NSManagedObjectContext
    private let uiColorMarshalling = UIColorMarshalling()
    private let weekDaysMarshalling = WeekDaysMarshalling()
    private var insertedIndexes: IndexSet?
    private var deletedIndexes: IndexSet?
    private var updatedIndexes: IndexSet?
    private var movedIndexes: Set<StoreUpdate.Move>?
    
    convenience override init() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        self.init(context: context)
    }
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCoreData> = {
        let fetchRequest = NSFetchRequest<TrackerCoreData>(entityName: "TrackerCoreData")
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \TrackerCoreData.trackerColorHex, ascending: true)
        ]
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        try? fetchedResultsController.performFetch()
        
        return fetchedResultsController
    }()
    
    var trackers: [Tracker] {
        guard
            let objects = self.fetchedResultsController.fetchedObjects,
            let trackers = try? objects.map({ try self.fetchTrackers(from: $0) })
        else { return [] }
        return trackers
    }
    
    func fetchTrackers(from trackerCoreData: TrackerCoreData) throws -> Tracker {
        guard let id = trackerCoreData.trackerId else {
            throw StoreError.decodingErrorInvalidId
        }
        guard let text = trackerCoreData.trackerText else {
            throw StoreError.decodingErrorInvalidText
        }
        guard let emoji = trackerCoreData.trackerEmoji else {
            throw StoreError.decodingErrorInvalidEmoji
        }
        guard let colorHex = trackerCoreData.trackerColorHex else {
            throw StoreError.decodingErrorInvalidColorHex
        }
        guard let schedule = trackerCoreData.trackerSchedule else {
            throw StoreError.decodingErrorInvalidSchedule
        }
        return Tracker(
            trackerId: id,
            trackerText: text,
            trackerEmoji: emoji,
            trackerColor: uiColorMarshalling.color(from: colorHex),
            trackerSchedule: weekDaysMarshalling.convertStringToWeekDays(schedule)
        )
    }
    
    func makeTracker(from tracker: Tracker) throws -> TrackerCoreData {
        let trackerCoreData = TrackerCoreData(context: context)
        trackerCoreData.trackerId = tracker.trackerId
        trackerCoreData.trackerText = tracker.trackerText
        trackerCoreData.trackerEmoji = tracker.trackerEmoji
        trackerCoreData.trackerColorHex = uiColorMarshalling.hexString(from: tracker.trackerColor)
        if let schedule = tracker.trackerSchedule {
            trackerCoreData.trackerSchedule = weekDaysMarshalling.convertWeekDaysToString(schedule)
        }
        
        return trackerCoreData
    }
    
    func fetchTracker(with id: UUID) throws -> TrackerCoreData? {
        let request = fetchedResultsController.fetchRequest
        request.predicate = NSPredicate(format: "%K == %@", "trackerId", id.uuidString)
        
        do {
            let record = try context.fetch(request).first
            return record
        } catch {
            throw StoreError.decodingErrorInvalidTracker
        }
    }
}

extension TrackerStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            guard let indexPath = newIndexPath else { fatalError() }
            insertedIndexes?.insert(indexPath.item)
        case .delete:
            guard let indexPath = indexPath else { fatalError() }
            deletedIndexes?.insert(indexPath.item)
        case .update:
            guard let indexPath = indexPath else { fatalError() }
            updatedIndexes?.insert(indexPath.item)
        case .move:
            guard let oldIndexPath = indexPath, let newIndexPath = newIndexPath else { fatalError() }
            movedIndexes?.insert(.init(oldIndex: oldIndexPath.item, newIndex: newIndexPath.item))
        @unknown default:
            fatalError()
        }
    }
}
