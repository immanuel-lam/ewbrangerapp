import Foundation

struct PatrolChecklistItem: Codable, Identifiable {
    let id: UUID
    var label: String
    var isComplete: Bool
    var completedAt: Date?
    var timeEstimateMins: Int

    init(id: UUID = UUID(), label: String, isComplete: Bool = false, completedAt: Date? = nil, timeEstimateMins: Int = 10) {
        self.id = id
        self.label = label
        self.isComplete = isComplete
        self.completedAt = completedAt
        self.timeEstimateMins = timeEstimateMins
    }
}
