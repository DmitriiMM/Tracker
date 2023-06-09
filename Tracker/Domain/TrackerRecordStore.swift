import UIKit
import CoreData

final class TrackerRecordStore: NSObject {
    private let context: NSManagedObjectContext
    private let trackerStore = TrackerStore()
    
    convenience override init() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        self.init(context: context)
    }
    
    init(context: NSManagedObjectContext) {
        self.context = context
        super.init()
    }
    
    var records: Set<TrackerRecord> {
        let request = NSFetchRequest<TrackerRecordCoreData>(entityName: "TrackerRecordCoreData")
        request.returnsObjectsAsFaults = false
        guard let objects = try? context.fetch(request) else { return [] }
        let recordsSet = Set(objects.compactMap { try? makeTrackerRecord(from: $0) })
        
        return recordsSet
    }
    
    func add(_ newRecord: TrackerRecord) throws {
        let trackerCoreData = try trackerStore.fetchTracker(with: newRecord.trackerId)
        let trackerRecordCoreData = TrackerRecordCoreData(context: context)
        trackerRecordCoreData.trackerRecordId = newRecord.trackerId
        trackerRecordCoreData.trackerRecordDate = newRecord.date
        trackerRecordCoreData.tracker = trackerCoreData
        
        try context.save()
    }
    
    func remove(_ record: TrackerRecord) throws {
        let request = NSFetchRequest<TrackerRecordCoreData>(entityName: "TrackerRecordCoreData")
        request.predicate = NSPredicate(
            format: "%K == %@",
            #keyPath(TrackerRecordCoreData.trackerRecordId),
            record.trackerId.uuidString
        )
        let records = try context.fetch(request)
        guard let recordToRemove = records.first else { return }
        context.delete(recordToRemove)
        
        try context.save()
    }
    
    private func makeTrackerRecord(from coreData: TrackerRecordCoreData) throws -> TrackerRecord {
        guard
            let id = coreData.trackerRecordId,
            let date = coreData.trackerRecordDate
        else { throw StoreError.decodingErrorInvalidTrackerRecord }
        
        return TrackerRecord(trackerId: id, date: date)
    }
}
