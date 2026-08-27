import Foundation

struct PackingItem: Identifiable, Codable, Equatable, Hashable {
    var id: UUID
    var name: String
    var category: String
    var packed: Bool

    init(id: UUID = UUID(), name: String, category: String, packed: Bool = false) {
        self.id = id
        self.name = name
        self.category = category
        self.packed = packed
    }

    static func suggested(for regionCode: String, climate: String = ClimateKind.temperate.rawValue) -> [PackingItem] {
        let region = regionCode.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        let adapterName: String
        switch region {
        case "EU", "FR", "DE", "IT", "ES", "NL", "PT", "AT", "BE", "GR", "IE":
            adapterName = "Plug adapter Type C"
        case "JP", "JPN":
            adapterName = "Plug adapter Type A/B"
        case "UK", "GB":
            adapterName = "Plug adapter Type G"
        case "AU", "AUS", "NZ":
            adapterName = "Plug adapter Type I"
        case "TH", "THA":
            adapterName = "Plug adapter Type A/C/O"
        case "MX", "MEX", "US", "USA", "CA", "CAN":
            adapterName = "Plug adapter Type A/B"
        case "CN", "CHN":
            adapterName = "Plug adapter Type A/C/I"
        default:
            adapterName = "Universal plug adapter"
        }

        var extras: [PackingItem] = []
        switch region {
        case "JP", "JPN":
            extras.append(PackingItem(name: "Pocket Wi-Fi reminder", category: "Gadgets"))
        case "UK", "GB":
            extras.append(PackingItem(name: "Compact rain jacket", category: "Clothing"))
        case "TH", "THA":
            extras.append(PackingItem(name: "Mosquito repellent", category: "Toiletries"))
        case "AU", "AUS":
            extras.append(PackingItem(name: "High-SPF sunscreen", category: "Toiletries"))
        default:
            break
        }

        switch ClimateKind.resolved(climate) {
        case .tropical:
            extras.append(PackingItem(name: "Light breathable shirts", category: "Clothing"))
            extras.append(PackingItem(name: "Insect repellent", category: "Toiletries"))
        case .desert:
            extras.append(PackingItem(name: "Sun hat", category: "Clothing"))
            extras.append(PackingItem(name: "Reusable water bottle", category: "Other"))
        case .alpine:
            extras.append(PackingItem(name: "Thermal layer", category: "Clothing"))
        case .coastal:
            extras.append(PackingItem(name: "Swimwear", category: "Clothing"))
        case .polar:
            extras.append(PackingItem(name: "Insulated gloves", category: "Clothing"))
        case .urban:
            extras.append(PackingItem(name: "Comfortable city shoes", category: "Clothing"))
        case .temperate:
            break
        }

        return [
            PackingItem(name: adapterName, category: "Gadgets"),
            PackingItem(name: "Portable charger", category: "Gadgets"),
            PackingItem(name: "Phone cable", category: "Gadgets"),
            PackingItem(name: "Comfortable walking shoes", category: "Clothing"),
            PackingItem(name: "Weather-ready jacket", category: "Clothing"),
            PackingItem(name: "Day outfit set", category: "Clothing"),
            PackingItem(name: "Toothbrush & toothpaste", category: "Toiletries"),
            PackingItem(name: "Travel-size shampoo", category: "Toiletries"),
            PackingItem(name: "Sunscreen", category: "Toiletries")
        ] + extras
    }
}

enum PackingTemplate: String, CaseIterable, Identifiable {
    case blank = "Blank"
    case city = "City break"
    case beach = "Beach"
    case hiking = "Hiking"
    case winter = "Winter"

    var id: String { rawValue }

    var items: [PackingItem] {
        switch self {
        case .blank:
            return []
        case .city:
            return [
                PackingItem(name: "Comfortable walking shoes", category: "Clothing"),
                PackingItem(name: "Smart-casual outfit", category: "Clothing"),
                PackingItem(name: "Light jacket", category: "Clothing"),
                PackingItem(name: "Day bag", category: "Other"),
                PackingItem(name: "Portable charger", category: "Gadgets"),
                PackingItem(name: "Transit cards / tickets folder", category: "Documents"),
                PackingItem(name: "Earplugs", category: "Other")
            ]
        case .beach:
            return [
                PackingItem(name: "Swimwear", category: "Clothing"),
                PackingItem(name: "Cover-up / sundress", category: "Clothing"),
                PackingItem(name: "Flip-flops", category: "Clothing"),
                PackingItem(name: "High-SPF sunscreen", category: "Toiletries"),
                PackingItem(name: "After-sun lotion", category: "Toiletries"),
                PackingItem(name: "Dry bag", category: "Other"),
                PackingItem(name: "Reusable water bottle", category: "Other")
            ]
        case .hiking:
            return [
                PackingItem(name: "Trail shoes", category: "Clothing"),
                PackingItem(name: "Moisture-wicking shirts", category: "Clothing"),
                PackingItem(name: "Rain shell", category: "Clothing"),
                PackingItem(name: "Blister kit", category: "Toiletries"),
                PackingItem(name: "Headlamp", category: "Gadgets"),
                PackingItem(name: "Daypack", category: "Other"),
                PackingItem(name: "Trail snacks", category: "Other")
            ]
        case .winter:
            return [
                PackingItem(name: "Insulated coat", category: "Clothing"),
                PackingItem(name: "Thermal base layers", category: "Clothing"),
                PackingItem(name: "Warm socks", category: "Clothing"),
                PackingItem(name: "Gloves and beanie", category: "Clothing"),
                PackingItem(name: "Lip balm", category: "Toiletries"),
                PackingItem(name: "Portable charger", category: "Gadgets"),
                PackingItem(name: "Spare warm layer", category: "Clothing")
            ]
        }
    }
}
