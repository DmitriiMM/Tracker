import UIKit
import CoreData

final class TrackerPinStore: NSObject {
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
    
    var pinnedTrackers: [TrackerPin] {
        let request = NSFetchRequest<TrackerPinCoreData>(entityName: "TrackerPinCoreData")
        request.returnsObjectsAsFaults = false
        guard let objects = try? context.fetch(request) else { return [] }
        let result = objects.compactMap { try? makeTrackerPins(from: $0) }
        
        return result
    }
    
    func add(_ newPin: TrackerPin) throws {
        let trackerCoreData = try trackerStore.fetchTracker(with: newPin.trackerId)
        let trackerPinCoreData = TrackerPinCoreData(context: context)
        trackerPinCoreData.trackerId = newPin.trackerId
        trackerPinCoreData.exCategory = newPin.exCategory
        trackerPinCoreData.tracker = trackerCoreData
        
        try context.save()
    }
    
    func remove(_ pin: TrackerPin) throws {
        let request = NSFetchRequest<TrackerPinCoreData>(entityName: "TrackerPinCoreData")
        request.predicate = NSPredicate(
            format: "%K == %@",
            #keyPath(TrackerPinCoreData.trackerId),
            pin.trackerId.uuidString
        )
        let pins = try context.fetch(request)
        guard let pinToRemove = pins.first else { return }
        context.delete(pinToRemove)
        
        try context.save()
    }
    
    private func makeTrackerPins(from coreData: TrackerPinCoreData) throws -> TrackerPin {
        guard
            let trackerId = coreData.tracker?.trackerId,
            let exCategory = coreData.exCategory
        else { throw StoreError.decodingErrorInvalidTrackerRecord }
        
        return TrackerPin(trackerId: trackerId, exCategory: exCategory)
    }
}
