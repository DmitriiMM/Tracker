import Foundation

enum StoreError: Error {
    case decodingErrorInvalidId
    case decodingErrorInvalidText
    case decodingErrorInvalidEmoji
    case decodingErrorInvalidColorHex
    case decodingErrorInvalidSchedule
    case decodingErrorInvalidCategoryTitle
    case decodingErrorInvalidTrackers
    case decodingErrorInvalidCategoryEntity
    case failedToSaveContext
    case decodingErrorInvalidRecordDate
    case decodingErrorInvalidRecordTrackerID
    case decodingErrorInvalidRecordEntity
}
