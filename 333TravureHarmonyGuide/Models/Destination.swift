import Foundation

enum TravelMode: String, CaseIterable, Identifiable, Codable {
    case fly = "Fly"
    case drive = "Drive"

    var id: String { rawValue }

    var symbol: String {
        switch self {
        case .fly: return "airplane"
        case .drive: return "car.fill"
        }
    }
}

enum SnowWindow: String, CaseIterable, Identifiable, Codable {
    case dump = "Storm dump"
    case groomer = "Hardpack"
    case corn = "Spring corn"
    case mixed = "Mixed"

    var id: String { rawValue }

    var symbol: String {
        switch self {
        case .dump: return "cloud.snow.fill"
        case .groomer: return "thermometer.snowflake"
        case .corn: return "sun.haze.fill"
        case .mixed: return "cloud.sun.fill"
        }
    }
}

struct SkiDrop: Identifiable, Codable, Equatable, Hashable {
    var id: UUID
    var title: String
    var ridgeId: String
    var firstChairAt: Date
    var nights: Int
    var travel: TravelMode
    var snow: SnowWindow
    var chairTempC: Int
    var kit: [GearPiece]
    var dawnDone: [String]
    var createdAt: Date

    init(
        id: UUID = UUID(),
        title: String,
        ridgeId: String,
        firstChairAt: Date,
        nights: Int = 3,
        travel: TravelMode = .drive,
        snow: SnowWindow = .mixed,
        chairTempC: Int = -4,
        kit: [GearPiece] = [],
        dawnDone: [String] = [],
        createdAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.ridgeId = ridgeId
        self.firstChairAt = firstChairAt
        self.nights = max(1, min(nights, 14))
        self.travel = travel
        self.snow = snow
        self.chairTempC = chairTempC
        self.kit = kit
        self.dawnDone = dawnDone
        self.createdAt = createdAt
    }

    var ridge: RidgeBrief {
        RidgeCatalog.brief(id: ridgeId)
    }

    var packedCount: Int {
        kit.filter(\.stowed).count
    }

    var kitProgress: Double {
        guard !kit.isEmpty else { return 0 }
        return Double(packedCount) / Double(kit.count)
    }

    var dawnProgress: Double {
        let beats = DawnScript.beats
        guard !beats.isEmpty else { return 0 }
        return Double(dawnDone.count) / Double(beats.count)
    }

    var secondsUntilChair: TimeInterval {
        firstChairAt.timeIntervalSinceNow
    }

    var isLive: Bool {
        secondsUntilChair > -6 * 60 * 60
    }

    var countdownLabel: String {
        let remaining = secondsUntilChair
        if remaining < -6 * 60 * 60 {
            return "Drop complete"
        }
        if remaining <= 0 {
            return "Lifts in play"
        }
        let total = Int(remaining)
        let days = total / 86_400
        let hours = (total % 86_400) / 3_600
        let minutes = (total % 3_600) / 60
        if days > 0 {
            return "\(days)d \(hours)h to first chair"
        }
        if hours > 0 {
            return "\(hours)h \(minutes)m to first chair"
        }
        return "\(minutes)m to first chair"
    }

    var chairClockLabel: String {
        firstChairAt.formatted(date: .abbreviated, time: .shortened)
    }

    func isDawnDone(_ beatId: String) -> Bool {
        dawnDone.contains(beatId)
    }
}
