import Foundation

struct PackingTrip: Identifiable, Codable, Equatable, Hashable {
    var id: UUID
    var title: String
    var destinationId: UUID?
    var items: [PackingItem]

    init(id: UUID = UUID(), title: String, destinationId: UUID? = nil, items: [PackingItem] = []) {
        self.id = id
        self.title = title
        self.destinationId = destinationId
        self.items = items
    }

    var packedCount: Int {
        items.filter(\.packed).count
    }

    var completion: Double {
        guard !items.isEmpty else { return 0 }
        return Double(packedCount) / Double(items.count)
    }
}
