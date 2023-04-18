import UIKit
import CoreData

final class TrackerRecordStore: NSObject {
    private let context: NSManagedObjectContext
    private var insertedIndexes: IndexSet?
    private var deletedIndexes: IndexSet?
    private var updatedIndexes: IndexSet?
    private var movedIndexes: Set<StoreUpdate.Move>?
    private let trackerStore = TrackerStore()
    
    convenience override init() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistantConteiner.viewContext
        self.init(context: context)
    }
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerRecordCoreData> = {
        let fetchRequest = NSFetchRequest<TrackerRecordCoreData>(entityName: "TrackerRecordCoreData")
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \TrackerRecordCoreData.trackerRecordDate, ascending: true)
        ]
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        try? fetchedResultsController.performFetch()
        
        return fetchedResultsController
    }()
    
    var records: NSSet {
        guard
            let objects = self.fetchedResultsController.fetchedObjects,
            let recordsArray = try? objects.map({ try self.fetchRecords(from: $0) })
        else { return [] }
        let records = NSSet(array: recordsArray)
        return records
    }
    
    func fetchRecords(from trackerRecordCoreData: TrackerRecordCoreData) throws -> TrackerRecord {
        guard let date = trackerRecordCoreData.trackerRecordDate else {
            throw StoreError.decodingErrorInvalidRecordDate
        }
        guard let id = trackerRecordCoreData.tracker?.trackerId else {
            throw StoreError.decodingErrorInvalidRecordTrackerID
        }
        
        print("🍊\(TrackerRecord(trackerId: id, date: date))🍊")
        
        return TrackerRecord(
            trackerId: id,
            date: date
        )
    }
    
    func fetchRecord(for date: String, with id: UUID) throws -> TrackerRecordCoreData? {
        let request = fetchedResultsController.fetchRequest
        request.predicate = NSPredicate(format: "%K == %@ AND %K == %@",
                                        "trackerRecordDate", date,
                                        #keyPath(TrackerRecordCoreData.tracker.trackerId),
                                        /* #keyPath(TrackerCoreData.trackerId), */
                                        id as CVarArg
        )
        print("🔰predicate \(String(describing: request.predicate))🔰")
        //        request.sortDescriptors = [
        //            NSSortDescriptor(keyPath: \TrackerRecordCoreData.trackerRecordDate, ascending: true)
        //        ]
        
        do {
            let record = try context.fetch(request).first
            print("❎record \(String(describing: record))")
            print("❎record.trackers \(record?.tracker)")
            return record
        } catch {
            throw StoreError.decodingErrorInvalidRecordEntity
        }
    }
    
    func removeRecord(tracker: Tracker, to date: String) throws {
        let existingRecord = try fetchRecord(for: date, with: tracker.trackerId)
        print("⚠️⚠️⚠️trackerId \(String(describing: existingRecord?.tracker?.trackerId)) ?= \(tracker.trackerId)⚠️⚠️⚠️")
        if let id = existingRecord?.tracker?.trackerId {
            if id == tracker.trackerId {
                print("DELETErec❌❌❌")
                context.delete(existingRecord!)
            }
        }
        try! context.save()
    }
    
    func saveRecord(tracker: Tracker, to date: String) throws {
        let newRecord = TrackerRecordCoreData(context: context)
        newRecord.tracker = try trackerStore.makeTracker(from: tracker)
        newRecord.trackerRecordDate = TrackerViewController().dateFormatter.string(from: Date())
        print("🍉🍉🍉newRecord \(newRecord)🍉🍉🍉")
        print("🍉  🍉  🍉 \(newRecord.tracker) VS \(tracker)🍉  🍉  🍉")
        
        try! context.save()
    }
    
    //    func saveRecord(tracker: Tracker, to date: String) throws {
    //
    //        let existingRecord = try fetchRecords(for: date)
    //        print("⚠️⚠️⚠️trackerId \(String(describing: existingRecord?.trackers?.trackerId)) ?= \(tracker.trackerId)⚠️⚠️⚠️")
    //        if let id = existingRecord?.trackers?.trackerId, id == tracker.trackerId {
    //            print("⚠️⚠️⚠️trackerId \(String(describing: existingRecord?.trackers?.trackerId)) ?= \(id) ?= \(tracker.trackerId)⚠️⚠️⚠️")
    //
    //            context.delete(existingRecord!)
    //            print("🍊🍊existingRecord \(String(describing: existingRecord))🍊🍊")
    //
    //        } else {
    //            let newRecord = TrackerRecordCoreData(context: context)
    //            print("🍉newRecord \(newRecord)🍉")
    //            newRecord.trackers = try trackerStore.makeTracker(from: tracker)
    //            newRecord.trackerRecordDate = TrackerViewController().dateFormatter.string(from: Date())
    //            print("🍉🍉newRecord \(newRecord)🍉🍉")
    //        }
    //
    //        try! context.save()
    //    }
}

extension TrackerRecordStore: NSFetchedResultsControllerDelegate {
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
