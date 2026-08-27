import Foundation

struct TravelUnit: Identifiable, Hashable {
    enum Kind: String, CaseIterable, Identifiable {
        case temperature = "Temp"
        case distance = "Distance"
        case mass = "Weight"
        case zones = "Time"

        var id: String { rawValue }
    }

    var id: String { code }
    let code: String
    let displayName: String
    let kind: Kind

    static let catalog: [TravelUnit] = [
        TravelUnit(code: "C", displayName: "Celsius", kind: .temperature),
        TravelUnit(code: "F", displayName: "Fahrenheit", kind: .temperature),
        TravelUnit(code: "km", displayName: "Kilometers", kind: .distance),
        TravelUnit(code: "mi", displayName: "Miles", kind: .distance),
        TravelUnit(code: "kg", displayName: "Kilograms", kind: .mass),
        TravelUnit(code: "lb", displayName: "Pounds", kind: .mass),
        TravelUnit(code: "Pacific/Honolulu", displayName: "Honolulu", kind: .zones),
        TravelUnit(code: "America/Los_Angeles", displayName: "Los Angeles", kind: .zones),
        TravelUnit(code: "America/New_York", displayName: "New York", kind: .zones),
        TravelUnit(code: "America/Mexico_City", displayName: "Mexico City", kind: .zones),
        TravelUnit(code: "America/Sao_Paulo", displayName: "São Paulo", kind: .zones),
        TravelUnit(code: "Europe/London", displayName: "London", kind: .zones),
        TravelUnit(code: "Europe/Paris", displayName: "Paris", kind: .zones),
        TravelUnit(code: "Europe/Istanbul", displayName: "Istanbul", kind: .zones),
        TravelUnit(code: "Africa/Cairo", displayName: "Cairo", kind: .zones),
        TravelUnit(code: "Asia/Dubai", displayName: "Dubai", kind: .zones),
        TravelUnit(code: "Asia/Bangkok", displayName: "Bangkok", kind: .zones),
        TravelUnit(code: "Asia/Tokyo", displayName: "Tokyo", kind: .zones),
        TravelUnit(code: "Australia/Sydney", displayName: "Sydney", kind: .zones),
        TravelUnit(code: "Pacific/Auckland", displayName: "Auckland", kind: .zones)
    ]

    static func unit(for code: String) -> TravelUnit? {
        let trimmed = code.trimmingCharacters(in: .whitespacesAndNewlines)
        return catalog.first { $0.code.caseInsensitiveCompare(trimmed) == .orderedSame }
    }

    static func units(for kind: Kind) -> [TravelUnit] {
        catalog.filter { $0.kind == kind }
    }

    static func convert(amount: Double, from: String, to: String) -> Double? {
        guard let source = unit(for: from), let target = unit(for: to), source.kind == target.kind else {
            return nil
        }
        if source.code == target.code { return amount }
        switch source.kind {
        case .temperature:
            let celsius = source.code == "C" ? amount : (amount - 32) * 5 / 9
            return target.code == "C" ? celsius : celsius * 9 / 5 + 32
        case .distance:
            let kilometers = source.code == "km" ? amount : amount * 1.60934
            return target.code == "km" ? kilometers : kilometers / 1.60934
        case .mass:
            let kilograms = source.code == "kg" ? amount : amount / 2.20462
            return target.code == "kg" ? kilograms : kilograms * 2.20462
        case .zones:
            return nil
        }
    }

    static func clockTime(in identifier: String, from date: Date = Date()) -> String {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(identifier: identifier) ?? .current
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        return formatter.string(from: date)
    }

    static func convertClock(_ date: Date, from fromID: String, to toID: String) -> Date? {
        guard let fromZone = TimeZone(identifier: fromID), TimeZone(identifier: toID) != nil else {
            return nil
        }
        var fromCalendar = Calendar(identifier: .gregorian)
        fromCalendar.timeZone = fromZone
        let clock = Calendar.current.dateComponents([.hour, .minute], from: date)
        var parts = fromCalendar.dateComponents([.year, .month, .day], from: Date())
        parts.hour = clock.hour
        parts.minute = clock.minute
        parts.second = 0
        return fromCalendar.date(from: parts)
    }
}
