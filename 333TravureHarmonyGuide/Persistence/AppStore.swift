import Combine
import Foundation

final class AppStore: ObservableObject {
    @Published var drops: [SkiDrop] = []
    @Published var activeDropId: UUID?

    private enum Keys {
        static let drops = "chairline.drops.v1"
        static let activeDropId = "chairline.activeDropId.v1"
        static let legacy = [
            "destinations", "notes", "points", "tripEssentials", "tripDocuments",
            "categoryOrder", "homeUnitCode", "destinationUnitCode", "recentAmounts",
            "lastSyncDate", "lastActivityDate", "homeCurrencyCode", "destinationCurrencyCode"
        ]
    }

    init() {
        load()
    }

    var activeDrop: SkiDrop? {
        if let activeDropId, let match = drop(id: activeDropId) {
            return match
        }
        return nextDrop
    }

    var nextDrop: SkiDrop? {
        drops
            .filter { $0.secondsUntilChair > -6 * 60 * 60 }
            .sorted { $0.firstChairAt < $1.firstChairAt }
            .first ?? drops.sorted { $0.firstChairAt > $1.firstChairAt }.first
    }

    var upcoming: [SkiDrop] {
        drops.sorted { $0.firstChairAt < $1.firstChairAt }
    }

    func drop(id: UUID) -> SkiDrop? {
        drops.first { $0.id == id }
    }

    func setActive(id: UUID) {
        activeDropId = id
        persist()
        Haptics.light()
    }

    func addDrop(_ drop: SkiDrop) {
        var record = drop
        if record.kit.isEmpty {
            record.kit = KitFactory.build(travel: record.travel, snow: record.snow, nights: record.nights)
        }
        drops.append(record)
        activeDropId = record.id
        persist()
        Haptics.success()
    }

    func updateDrop(_ drop: SkiDrop) {
        guard let index = drops.firstIndex(where: { $0.id == drop.id }) else { return }
        var record = drop
        record.nights = max(1, min(record.nights, 14))
        drops[index] = record
        persist()
    }

    func rebuildKit(for id: UUID) {
        guard let index = drops.firstIndex(where: { $0.id == id }) else { return }
        let current = drops[index]
        drops[index].kit = KitFactory.build(travel: current.travel, snow: current.snow, nights: current.nights)
        persist()
        Haptics.medium()
    }

    func applyBrief(_ brief: RidgeBrief, to id: UUID) {
        guard let index = drops.firstIndex(where: { $0.id == id }) else { return }
        drops[index].ridgeId = brief.id
        drops[index].snow = brief.defaultSnow
        drops[index].travel = brief.defaultTravel
        drops[index].kit = KitFactory.build(
            travel: brief.defaultTravel,
            snow: brief.defaultSnow,
            nights: drops[index].nights
        )
        persist()
        Haptics.success()
    }

    func deleteDrop(id: UUID) {
        drops.removeAll { $0.id == id }
        if activeDropId == id {
            activeDropId = nextDrop?.id
        }
        persist()
    }

    func toggleGear(dropId: UUID, pieceId: UUID) {
        guard let dropIndex = drops.firstIndex(where: { $0.id == dropId }) else { return }
        guard let pieceIndex = drops[dropIndex].kit.firstIndex(where: { $0.id == pieceId }) else { return }
        drops[dropIndex].kit[pieceIndex].stowed.toggle()
        Haptics.light()
        persist()
    }

    @discardableResult
    func addGear(dropId: UUID, name: String, bay: GearBay, why: String) -> Bool {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return false }
        guard let index = drops.firstIndex(where: { $0.id == dropId }) else { return false }
        let needle = trimmed.lowercased()
        if drops[index].kit.contains(where: { $0.name.lowercased() == needle }) {
            return false
        }
        drops[index].kit.append(GearPiece(name: trimmed, bay: bay, why: why))
        persist()
        return true
    }

    @discardableResult
    func updateGear(dropId: UUID, piece: GearPiece) -> Bool {
        let trimmed = piece.name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return false }
        guard let dropIndex = drops.firstIndex(where: { $0.id == dropId }) else { return false }
        let needle = trimmed.lowercased()
        if drops[dropIndex].kit.contains(where: { $0.id != piece.id && $0.name.lowercased() == needle }) {
            return false
        }
        guard let pieceIndex = drops[dropIndex].kit.firstIndex(where: { $0.id == piece.id }) else { return false }
        var updated = piece
        updated.name = trimmed
        drops[dropIndex].kit[pieceIndex] = updated
        persist()
        return true
    }

    func deleteGear(dropId: UUID, pieceId: UUID) {
        guard let index = drops.firstIndex(where: { $0.id == dropId }) else { return }
        drops[index].kit.removeAll { $0.id == pieceId }
        persist()
    }

    func toggleDawn(dropId: UUID, beatId: String) {
        guard let index = drops.firstIndex(where: { $0.id == dropId }) else { return }
        if let done = drops[index].dawnDone.firstIndex(of: beatId) {
            drops[index].dawnDone.remove(at: done)
        } else {
            drops[index].dawnDone.append(beatId)
        }
        Haptics.light()
        persist()
    }

    func resetAllData() {
        for key in Keys.legacy + [Keys.drops, Keys.activeDropId] {
            UserDefaults.standard.removeObject(forKey: key)
        }
        drops = []
        activeDropId = nil
        NotificationCenter.default.post(name: Notification.Name("dataReset"), object: nil)
    }

    private func persist() {
        encode(drops, key: Keys.drops)
        if let activeDropId {
            UserDefaults.standard.set(activeDropId.uuidString, forKey: Keys.activeDropId)
        } else {
            UserDefaults.standard.removeObject(forKey: Keys.activeDropId)
        }
        objectWillChange.send()
    }

    private func load() {
        drops = decode([SkiDrop].self, key: Keys.drops) ?? []
        if let raw = UserDefaults.standard.string(forKey: Keys.activeDropId), let id = UUID(uuidString: raw) {
            activeDropId = id
        }
        if activeDropId == nil {
            activeDropId = nextDrop?.id
        }
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
