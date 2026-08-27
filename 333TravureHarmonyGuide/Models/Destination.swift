import Foundation

enum ClimateKind: String, CaseIterable, Identifiable, Codable {
    case tropical = "Tropical"
    case temperate = "Temperate"
    case desert = "Desert"
    case alpine = "Alpine"
    case coastal = "Coastal"
    case polar = "Polar"
    case urban = "Urban"

    var id: String { rawValue }

    var symbol: String {
        switch self {
        case .tropical: return "sun.max.fill"
        case .temperate: return "leaf.fill"
        case .desert: return "sun.haze.fill"
        case .alpine: return "triangle.fill"
        case .coastal: return "water.waves"
        case .polar: return "snowflake"
        case .urban: return "building.2.fill"
        }
    }

    static func resolved(_ raw: String) -> ClimateKind {
        ClimateKind(rawValue: raw) ?? .temperate
    }

    static func fromLegacyCurrency(_ code: String?) -> ClimateKind {
        switch code?.trimmingCharacters(in: .whitespacesAndNewlines).uppercased() {
        case "THB": return .tropical
        case "MXN": return .desert
        case "AUD": return .coastal
        case "CAD": return .alpine
        case "GBP": return .coastal
        case "JPY": return .temperate
        case "EUR", "USD": return .temperate
        default: return .temperate
        }
    }

    func seasonalTip(for date: Date) -> String {
        let month = Calendar.current.component(.month, from: date)
        let warmHalf = (5...9).contains(month)
        switch self {
        case .tropical:
            return warmHalf
                ? "Peak humidity — pack breathable layers, extra sunscreen, and a compact rain shell."
                : "Still warm; a light long-sleeve helps with insects and air-conditioned rooms."
        case .temperate:
            return warmHalf
                ? "Mild days, cool evenings — a packable sweater and walking shoes cover most days."
                : "Shoulder or cold season — add a proper jacket and a warm base layer."
        case .desert:
            return warmHalf
                ? "Harsh sun and dry heat — sun hat, electrolytes, and a refillable bottle are essential."
                : "Days can stay bright while nights drop fast — bring a warm layer for after sunset."
        case .alpine:
            return warmHalf
                ? "Valley warmth, mountain chill — pack a thermal layer even in summer."
                : "Snow and ice possible — insulated gloves, traction, and a windproof shell."
        case .coastal:
            return warmHalf
                ? "Sea breeze and glare — swimwear, a dry bag, and high-SPF sunscreen."
                : "Wind off the water feels colder — a light waterproof and a warm mid-layer."
        case .polar:
            return "Expect serious cold year-round — insulated layers, covering accessories, and spare socks."
        case .urban:
            return warmHalf
                ? "City heat and long walks — breathable outfits and very comfortable shoes."
                : "Transit and rain are the wildcards — a compact umbrella and a smart-casual layer."
        }
    }
}

struct Destination: Identifiable, Codable, Equatable, Hashable {
    var id: UUID
    var name: String
    var country: String
    var regionCode: String
    var plannedDate: Date?
    var visited: Bool
    var climate: String
    var coverPhotoName: String?
    var timeZoneIdentifier: String

    var climateKind: ClimateKind {
        ClimateKind.resolved(climate)
    }

    var resolvedTimeZone: TimeZone {
        if timeZoneIdentifier.isEmpty { return .current }
        return TimeZone(identifier: timeZoneIdentifier) ?? .current
    }

    var daysUntil: Int? {
        guard let plannedDate, !visited else { return nil }
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: Date())
        let target = calendar.startOfDay(for: plannedDate)
        return calendar.dateComponents([.day], from: start, to: target).day
    }

    var countdownLabel: String? {
        guard let days = daysUntil else { return nil }
        if days < 0 { return "Date passed" }
        if days == 0 { return "Today" }
        if days == 1 { return "Tomorrow" }
        if days <= 7 { return "This week · \(days)d" }
        if days <= 31 { return "This month · \(days)d" }
        return "\(days) days"
    }

    var localTimeLabel: String {
        let formatter = DateFormatter()
        formatter.timeZone = resolvedTimeZone
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        return formatter.string(from: Date())
    }

    var seasonalTip: String {
        climateKind.seasonalTip(for: plannedDate ?? Date())
    }

    init(
        id: UUID = UUID(),
        name: String,
        country: String,
        regionCode: String,
        plannedDate: Date? = nil,
        visited: Bool = false,
        climate: String,
        coverPhotoName: String? = nil,
        timeZoneIdentifier: String = ""
    ) {
        self.id = id
        self.name = name
        self.country = country
        self.regionCode = regionCode
        self.plannedDate = plannedDate
        self.visited = visited
        self.climate = climate
        self.coverPhotoName = coverPhotoName
        self.timeZoneIdentifier = timeZoneIdentifier
    }

    enum CodingKeys: String, CodingKey {
        case id, name, country, regionCode, plannedDate, visited, climate
        case coverPhotoName, timeZoneIdentifier
        case currencyCode
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        country = try container.decodeIfPresent(String.self, forKey: .country) ?? ""
        regionCode = try container.decodeIfPresent(String.self, forKey: .regionCode) ?? ""
        plannedDate = try container.decodeIfPresent(Date.self, forKey: .plannedDate)
        visited = try container.decodeIfPresent(Bool.self, forKey: .visited) ?? false
        if let stored = try container.decodeIfPresent(String.self, forKey: .climate),
           ClimateKind(rawValue: stored) != nil {
            climate = stored
        } else {
            let legacy = try container.decodeIfPresent(String.self, forKey: .currencyCode)
            climate = ClimateKind.fromLegacyCurrency(legacy).rawValue
        }
        coverPhotoName = try container.decodeIfPresent(String.self, forKey: .coverPhotoName)
        timeZoneIdentifier = try container.decodeIfPresent(String.self, forKey: .timeZoneIdentifier) ?? ""
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(country, forKey: .country)
        try container.encode(regionCode, forKey: .regionCode)
        try container.encodeIfPresent(plannedDate, forKey: .plannedDate)
        try container.encode(visited, forKey: .visited)
        try container.encode(climate, forKey: .climate)
        try container.encodeIfPresent(coverPhotoName, forKey: .coverPhotoName)
        try container.encode(timeZoneIdentifier, forKey: .timeZoneIdentifier)
    }
}

struct TripDocument: Identifiable, Codable, Equatable, Hashable {
    var id: UUID
    var destinationId: UUID
    var kind: String
    var title: String
    var expiryDate: Date?
    var ready: Bool

    init(
        id: UUID = UUID(),
        destinationId: UUID,
        kind: String,
        title: String,
        expiryDate: Date? = nil,
        ready: Bool = false
    ) {
        self.id = id
        self.destinationId = destinationId
        self.kind = kind
        self.title = title
        self.expiryDate = expiryDate
        self.ready = ready
    }

    static let kinds = ["Passport", "Visa", "Insurance", "Tickets", "Other"]

    var expiryLabel: String? {
        guard let expiryDate else { return nil }
        let days = Calendar.current.dateComponents(
            [.day],
            from: Calendar.current.startOfDay(for: Date()),
            to: Calendar.current.startOfDay(for: expiryDate)
        ).day ?? 0
        if days < 0 { return "Expired" }
        if days == 0 { return "Expires today" }
        if days <= 30 { return "Expires in \(days)d" }
        return expiryDate.formatted(date: .abbreviated, time: .omitted)
    }
}
