import Combine
import Foundation
import UIKit

final class AppStore: ObservableObject {
    @Published var destinations: [Destination] = []
    @Published var notes: [TravelNote] = []
    @Published var points: [PointOfInterest] = []
    @Published var tripEssentials: [PackingTrip] = []
    @Published var documents: [TripDocument] = []
    @Published var categoryOrder: [String] = AppStore.defaultCategories
    @Published var homeUnitCode: String = "C"
    @Published var destinationUnitCode: String = "F"
    @Published var recentAmounts: [Double] = []
    @Published var lastSyncDate: Date?
    @Published var lastActivityDate: Date?

    static let defaultCategories = ["Clothing", "Toiletries", "Gadgets", "Documents", "Other"]

    private enum Keys {
        static let destinations = "destinations"
        static let notes = "notes"
        static let points = "points"
        static let tripEssentials = "tripEssentials"
        static let documents = "tripDocuments"
        static let categoryOrder = "categoryOrder"
        static let homeUnitCode = "homeUnitCode"
        static let destinationUnitCode = "destinationUnitCode"
        static let recentAmounts = "recentAmounts"
        static let lastSyncDate = "lastSyncDate"
        static let lastActivityDate = "lastActivityDate"

        static let all = [
            destinations, notes, points, tripEssentials, documents, categoryOrder,
            "homeCurrencyCode", "destinationCurrencyCode",
            homeUnitCode, destinationUnitCode, recentAmounts,
            lastSyncDate, lastActivityDate
        ]
    }

    init() {
        load()
    }

    var visitedCount: Int {
        destinations.filter(\.visited).count
    }

    var plannedCount: Int {
        destinations.filter { !$0.visited }.count
    }

    var overallPackingCompletion: Double {
        let all = tripEssentials.flatMap(\.items)
        guard !all.isEmpty else { return 0 }
        return Double(all.filter(\.packed).count) / Double(all.count)
    }

    var climateCounts: [ClimateCount] {
        let grouped = Dictionary(grouping: destinations, by: \.climateKind)
        return ClimateKind.allCases.compactMap { kind in
            let count = grouped[kind]?.count ?? 0
            guard count > 0 else { return nil }
            return ClimateCount(climate: kind, count: count)
        }
    }

    func destination(id: UUID) -> Destination? {
        destinations.first { $0.id == id }
    }

    func notes(for destinationId: UUID) -> [TravelNote] {
        notes.filter { $0.destinationId == destinationId }
    }

    func groupedNotes(for destinationId: UUID) -> [NoteDayGroup] {
        let items = notes(for: destinationId)
        let calendar = Calendar.current
        var buckets: [Date?: [TravelNote]] = [:]
        for note in items {
            let key = note.day.map { calendar.startOfDay(for: $0) }
            buckets[key, default: []].append(note)
        }
        let dated = buckets.keys.compactMap { $0 }.sorted(by: >)
        var groups: [NoteDayGroup] = dated.map { day in
            NoteDayGroup(id: day.timeIntervalSince1970.description, day: day, notes: buckets[day] ?? [])
        }
        if let loose = buckets[nil], !loose.isEmpty {
            groups.append(NoteDayGroup(id: "loose", day: nil, notes: loose))
        }
        return groups
    }

    func points(for destinationId: UUID) -> [PointOfInterest] {
        points
            .filter { $0.destinationId == destinationId }
            .sorted {
                if $0.resolvedOrder == $1.resolvedOrder {
                    return $0.title < $1.title
                }
                return $0.resolvedOrder < $1.resolvedOrder
            }
    }

    func itinerary(for destinationId: UUID) -> [ItinerarySlotGroup] {
        let items = points(for: destinationId)
        return DaySlot.allCases.compactMap { slot in
            let slotItems = items.filter { $0.resolvedSlot == slot }
            guard !slotItems.isEmpty else { return nil }
            return ItinerarySlotGroup(id: slot.rawValue, slot: slot, points: slotItems)
        }
    }

    func documents(for destinationId: UUID) -> [TripDocument] {
        documents.filter { $0.destinationId == destinationId }
    }

    func plannedDestinations() -> [Destination] {
        destinations.filter { !$0.visited }
    }

    func trip(id: UUID) -> PackingTrip? {
        tripEssentials.first { $0.id == id }
    }

    func trip(forDestination destinationId: UUID) -> PackingTrip? {
        tripEssentials.first { $0.destinationId == destinationId }
    }

    func addDestination(_ destination: Destination) {
        var record = destination
        record.regionCode = Self.resolvedRegion(regionCode: destination.regionCode)
        destinations.append(record)
        let trip = PackingTrip(
            title: record.name,
            destinationId: record.id,
            items: PackingItem.suggested(for: record.regionCode, climate: record.climate)
        )
        tripEssentials.append(trip)
        persist()
    }

    func updateDestination(_ destination: Destination) {
        guard let index = destinations.firstIndex(where: { $0.id == destination.id }) else { return }
        var record = destination
        record.regionCode = Self.resolvedRegion(regionCode: destination.regionCode)
        destinations[index] = record
        persist()
    }

    func deleteDestination(id: UUID) {
        let cover = destinations.first(where: { $0.id == id })?.coverPhotoName
        destinations.removeAll { $0.id == id }
        notes.removeAll { $0.destinationId == id }
        points.removeAll { $0.destinationId == id }
        documents.removeAll { $0.destinationId == id }
        if let cover {
            JournalPhotos.delete(named: cover)
        }
        if let tripIndex = tripEssentials.firstIndex(where: { $0.destinationId == id }) {
            tripEssentials[tripIndex].destinationId = nil
        }
        persist()
    }

    func setVisited(id: UUID, visited: Bool) {
        guard let index = destinations.firstIndex(where: { $0.id == id }) else { return }
        destinations[index].visited = visited
        if visited {
            Haptics.success()
        } else {
            Haptics.light()
        }
        persist()
    }

    func addNote(destinationId: UUID, text: String, day: Date?) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        notes.append(TravelNote(destinationId: destinationId, text: trimmed, day: day))
        persist()
    }

    func deleteNote(id: UUID) {
        notes.removeAll { $0.id == id }
        persist()
    }

    func addPoint(destinationId: UUID, title: String, kind: String, slot: String) {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        let resolvedKind = kind.isEmpty ? "Landmark" : kind
        let nextOrder = (points(for: destinationId).map(\.resolvedOrder).max() ?? -1) + 1
        points.append(
            PointOfInterest(
                destinationId: destinationId,
                title: trimmed,
                kind: resolvedKind,
                sortOrder: nextOrder,
                slot: slot
            )
        )
        persist()
    }

    func movePoint(id: UUID, direction: Int) {
        guard let index = points.firstIndex(where: { $0.id == id }) else { return }
        let destinationId = points[index].destinationId
        let slot = points[index].resolvedSlot
        var ordered = points(for: destinationId).filter { $0.resolvedSlot == slot }
        guard let current = ordered.firstIndex(where: { $0.id == id }) else { return }
        let target = current + direction
        guard ordered.indices.contains(target) else { return }
        ordered.swapAt(current, target)
        for (order, item) in ordered.enumerated() {
            if let storeIndex = points.firstIndex(where: { $0.id == item.id }) {
                points[storeIndex].sortOrder = order
            }
        }
        persist()
    }

    func setPointSlot(id: UUID, slot: String) {
        guard let index = points.firstIndex(where: { $0.id == id }) else { return }
        points[index].slot = slot
        persist()
    }

    func deletePoint(id: UUID) {
        points.removeAll { $0.id == id }
        persist()
    }

    func addTrip(title: String, destinationId: UUID? = nil, items: [PackingItem] = []) {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        tripEssentials.append(PackingTrip(title: trimmed, destinationId: destinationId, items: items))
        persist()
    }

    func duplicateTrip(id: UUID) {
        guard let trip = trip(id: id) else { return }
        let copies = trip.items.map { PackingItem(name: $0.name, category: $0.category, packed: false) }
        addTrip(title: "\(trip.title) copy", destinationId: trip.destinationId, items: copies)
    }

    func addDocument(destinationId: UUID, kind: String, title: String, expiryDate: Date?) {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        documents.append(
            TripDocument(
                destinationId: destinationId,
                kind: kind.isEmpty ? "Other" : kind,
                title: trimmed,
                expiryDate: expiryDate
            )
        )
        persist()
    }

    func toggleDocumentReady(id: UUID) {
        guard let index = documents.firstIndex(where: { $0.id == id }) else { return }
        documents[index].ready.toggle()
        Haptics.light()
        persist()
    }

    func deleteDocument(id: UUID) {
        documents.removeAll { $0.id == id }
        persist()
    }

    func setCoverPhoto(destinationId: UUID, data: Data) {
        guard let index = destinations.firstIndex(where: { $0.id == destinationId }) else { return }
        if let previous = destinations[index].coverPhotoName {
            JournalPhotos.delete(named: previous)
        }
        destinations[index].coverPhotoName = JournalPhotos.save(data)
        persist()
    }

    func clearCoverPhoto(destinationId: UUID) {
        guard let index = destinations.firstIndex(where: { $0.id == destinationId }) else { return }
        if let previous = destinations[index].coverPhotoName {
            JournalPhotos.delete(named: previous)
        }
        destinations[index].coverPhotoName = nil
        persist()
    }

    func updateTripTitle(id: UUID, title: String) {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, let index = tripEssentials.firstIndex(where: { $0.id == id }) else { return }
        tripEssentials[index].title = trimmed
        persist()
    }

    func deleteTrip(id: UUID) {
        tripEssentials.removeAll { $0.id == id }
        persist()
    }

    func duplicateItemName(in tripId: UUID, name: String, excluding itemId: UUID?) -> Bool {
        guard let trip = trip(id: tripId) else { return false }
        let needle = name.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !needle.isEmpty else { return false }
        return trip.items.contains { item in
            if let itemId, item.id == itemId { return false }
            return item.name.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() == needle
        }
    }

    @discardableResult
    func addItem(tripId: UUID, name: String, category: String) -> Bool {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return false }
        guard !duplicateItemName(in: tripId, name: trimmed, excluding: nil) else { return false }
        guard let index = tripEssentials.firstIndex(where: { $0.id == tripId }) else { return false }
        let resolvedCategory = category.isEmpty ? "Other" : category
        if !categoryOrder.contains(resolvedCategory) {
            categoryOrder.append(resolvedCategory)
        }
        tripEssentials[index].items.append(PackingItem(name: trimmed, category: resolvedCategory))
        persist()
        return true
    }

    @discardableResult
    func updateItem(tripId: UUID, item: PackingItem) -> Bool {
        let trimmed = item.name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return false }
        guard !duplicateItemName(in: tripId, name: trimmed, excluding: item.id) else { return false }
        guard let tripIndex = tripEssentials.firstIndex(where: { $0.id == tripId }) else { return false }
        guard let itemIndex = tripEssentials[tripIndex].items.firstIndex(where: { $0.id == item.id }) else { return false }
        var updated = item
        updated.name = trimmed
        if updated.category.isEmpty {
            updated.category = "Other"
        }
        if !categoryOrder.contains(updated.category) {
            categoryOrder.append(updated.category)
        }
        tripEssentials[tripIndex].items[itemIndex] = updated
        persist()
        return true
    }

    func deleteItem(tripId: UUID, itemId: UUID) {
        guard let tripIndex = tripEssentials.firstIndex(where: { $0.id == tripId }) else { return }
        tripEssentials[tripIndex].items.removeAll { $0.id == itemId }
        persist()
    }

    func togglePacked(tripId: UUID, itemId: UUID) {
        guard let tripIndex = tripEssentials.firstIndex(where: { $0.id == tripId }) else { return }
        guard let itemIndex = tripEssentials[tripIndex].items.firstIndex(where: { $0.id == itemId }) else { return }
        tripEssentials[tripIndex].items[itemIndex].packed.toggle()
        Haptics.light()
        persist()
    }

    func setHomeUnit(_ code: String) {
        homeUnitCode = code
        persist()
    }

    func setDestinationUnit(_ code: String) {
        destinationUnitCode = code
        persist()
    }

    func logAmount(_ amount: Double) {
        var next = recentAmounts.filter { abs($0 - amount) > 0.0001 }
        next.insert(amount, at: 0)
        if next.count > 12 {
            next = Array(next.prefix(12))
        }
        recentAmounts = next
        persist()
    }

    func resetAllData() {
        for key in Keys.all {
            UserDefaults.standard.removeObject(forKey: key)
        }
        destinations = []
        notes = []
        points = []
        tripEssentials = []
        documents = []
        categoryOrder = AppStore.defaultCategories
        homeUnitCode = "C"
        destinationUnitCode = "F"
        recentAmounts = []
        lastSyncDate = nil
        lastActivityDate = nil
        try? FileManager.default.removeItem(at: JournalPhotos.directory)
        NotificationCenter.default.post(name: Notification.Name("dataReset"), object: nil)
    }

    static func resolvedRegion(regionCode: String) -> String {
        regionCode.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func persist() {
        lastActivityDate = Date()
        lastSyncDate = Date()
        encode(destinations, key: Keys.destinations)
        encode(notes, key: Keys.notes)
        encode(points, key: Keys.points)
        encode(tripEssentials, key: Keys.tripEssentials)
        encode(documents, key: Keys.documents)
        encode(categoryOrder, key: Keys.categoryOrder)
        UserDefaults.standard.set(homeUnitCode, forKey: Keys.homeUnitCode)
        UserDefaults.standard.set(destinationUnitCode, forKey: Keys.destinationUnitCode)
        encode(recentAmounts, key: Keys.recentAmounts)
        if let lastSyncDate {
            UserDefaults.standard.set(lastSyncDate.timeIntervalSince1970, forKey: Keys.lastSyncDate)
        }
        if let lastActivityDate {
            UserDefaults.standard.set(lastActivityDate.timeIntervalSince1970, forKey: Keys.lastActivityDate)
        }
        objectWillChange.send()
    }

    private func load() {
        destinations = decode([Destination].self, key: Keys.destinations) ?? []
        notes = decode([TravelNote].self, key: Keys.notes) ?? []
        points = decode([PointOfInterest].self, key: Keys.points) ?? []
        tripEssentials = decode([PackingTrip].self, key: Keys.tripEssentials) ?? []
        documents = decode([TripDocument].self, key: Keys.documents) ?? []
        categoryOrder = decode([String].self, key: Keys.categoryOrder) ?? AppStore.defaultCategories
        if categoryOrder.isEmpty {
            categoryOrder = AppStore.defaultCategories
        }
        let home = UserDefaults.standard.string(forKey: Keys.homeUnitCode) ?? "C"
        homeUnitCode = TravelUnit.unit(for: home)?.code ?? "C"
        let dest = UserDefaults.standard.string(forKey: Keys.destinationUnitCode) ?? "F"
        destinationUnitCode = TravelUnit.unit(for: dest)?.code ?? "F"
        recentAmounts = decode([Double].self, key: Keys.recentAmounts) ?? []
        let sync = UserDefaults.standard.object(forKey: Keys.lastSyncDate) as? Double
        lastSyncDate = sync.map { Date(timeIntervalSince1970: $0) }
        let activity = UserDefaults.standard.object(forKey: Keys.lastActivityDate) as? Double
        lastActivityDate = activity.map { Date(timeIntervalSince1970: $0) }
    }

    private func encode<T: Encodable>(_ value: T, key: String) {
        if let data = try? JSONEncoder().encode(value) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    private func decode<T: Decodable>(_ type: T.Type, key: String) -> T? {
        guard let data = UserDefaults.standard.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(type, from: data)
    }
}

struct ClimateCount: Identifiable, Hashable {
    let climate: ClimateKind
    let count: Int
    var id: ClimateKind { climate }
}

struct NoteDayGroup: Identifiable {
    let id: String
    let day: Date?
    let notes: [TravelNote]
}

struct ItinerarySlotGroup: Identifiable {
    let id: String
    let slot: DaySlot
    let points: [PointOfInterest]
}

enum JournalPhotos {
    static var directory: URL {
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("Covers", isDirectory: true)
        try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        return url
    }

    static func save(_ data: Data) -> String? {
        guard let image = UIImage(data: data) else { return nil }
        let resized = resized(image, maxDimension: 1400)
        guard let jpeg = resized.jpegData(compressionQuality: 0.72) else { return nil }
        let name = UUID().uuidString + ".jpg"
        try? jpeg.write(to: directory.appendingPathComponent(name), options: .atomic)
        return name
    }

    static func image(named: String) -> UIImage? {
        UIImage(contentsOfFile: directory.appendingPathComponent(named).path)
    }

    static func delete(named: String) {
        try? FileManager.default.removeItem(at: directory.appendingPathComponent(named))
    }

    private static func resized(_ image: UIImage, maxDimension: CGFloat) -> UIImage {
        let longest = max(image.size.width, image.size.height)
        guard longest > maxDimension, longest > 0 else { return image }
        let scale = maxDimension / longest
        let size = CGSize(width: image.size.width * scale, height: image.size.height * scale)
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: size))
        }
    }
}
