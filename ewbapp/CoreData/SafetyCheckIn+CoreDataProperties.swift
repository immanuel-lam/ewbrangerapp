import CoreData
import Foundation

extension SafetyCheckIn {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<SafetyCheckIn> {
        return NSFetchRequest<SafetyCheckIn>(entityName: "SafetyCheckIn")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var startTime: Date?
    @NSManaged public var intervalMinutes: Int16
    @NSManaged public var lastCheckInTime: Date?
    @NSManaged public var isActive: Bool
    @NSManaged public var notes: String?
}
