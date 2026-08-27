import Foundation

enum DaySlot: String, CaseIterable, Identifiable {
    case morning = "Morning"
    case afternoon = "Afternoon"
    case evening = "Evening"
    case anytime = "Anytime"

    var id: String { rawValue }

    static func resolved(_ raw: String?) -> DaySlot {
        DaySlot(rawValue: raw ?? "") ?? .anytime
    }
}

struct PointOfInterest: Identifiable, Codable, Equatable, Hashable {
    var id: UUID
    var destinationId: UUID
    var title: String
    var kind: String
    var sortOrder: Int?
    var slot: String?

    init(
        id: UUID = UUID(),
        destinationId: UUID,
        title: String,
        kind: String,
        sortOrder: Int = 0,
        slot: String = DaySlot.anytime.rawValue
    ) {
        self.id = id
        self.destinationId = destinationId
        self.title = title
        self.kind = kind
        self.sortOrder = sortOrder
        self.slot = slot
    }

    var resolvedSlot: DaySlot { DaySlot.resolved(slot) }
    var resolvedOrder: Int { sortOrder ?? 0 }

    static let kinds = ["Landmark", "Museum", "Park", "Market", "Harbor", "Station", "Temple", "Cafe"]
}
