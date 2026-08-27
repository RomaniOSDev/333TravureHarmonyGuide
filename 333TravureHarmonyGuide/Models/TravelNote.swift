import Foundation

struct TravelNote: Identifiable, Codable, Equatable, Hashable {
    var id: UUID
    var destinationId: UUID
    var text: String
    var day: Date?

    init(id: UUID = UUID(), destinationId: UUID, text: String, day: Date? = nil) {
        self.id = id
        self.destinationId = destinationId
        self.text = text
        self.day = day
    }

    var dayStamp: Date? {
        guard let day else { return nil }
        return Calendar.current.startOfDay(for: day)
    }
}
