import Foundation

enum GearBay: String, CaseIterable, Identifiable, Codable {
    case bootBag = "Boot bag"
    case cabin = "Cabin"
    case hold = "Hold / roof"
    case car = "Car cache"

    var id: String { rawValue }

    var symbol: String {
        switch self {
        case .bootBag: return "figure.skiing.downhill"
        case .cabin: return "backpack.fill"
        case .hold: return "shippingbox.fill"
        case .car: return "car.fill"
        }
    }
}

struct GearPiece: Identifiable, Codable, Equatable, Hashable {
    var id: UUID
    var name: String
    var bay: GearBay
    var why: String
    var stowed: Bool

    init(
        id: UUID = UUID(),
        name: String,
        bay: GearBay,
        why: String,
        stowed: Bool = false
    ) {
        self.id = id
        self.name = name
        self.bay = bay
        self.why = why
        self.stowed = stowed
    }
}

enum KitFactory {
    static func build(travel: TravelMode, snow: SnowWindow, nights: Int) -> [GearPiece] {
        var pieces: [GearPiece] = [
            GearPiece(name: "Ski/board boots", bay: .bootBag, why: "Keep them in the cabin or boot bag so they stay dry and warm overnight."),
            GearPiece(name: "Helmet", bay: .bootBag, why: "Pad it between socks so the shell does not crack in transit."),
            GearPiece(name: "Goggles — bright lens", bay: .bootBag, why: "Hardpack and corn need a high-contrast sunny lens."),
            GearPiece(name: "Liner gloves + shells", bay: .bootBag, why: "Swap liners at lunch; shells stay in the bag if palms soak."),
            GearPiece(name: "Two ski-sock pairs", bay: .bootBag, why: "One on, one drying. Never reuse a soaked pair on day two."),
            GearPiece(name: "Merino base top + bottom", bay: .cabin, why: "Sleep in the spare set on storm nights so the riding set dries."),
            GearPiece(name: "Insulated vest or light mid", bay: .cabin, why: "The piece you add on the first chair, not in the parking lot."),
            GearPiece(name: "Lift pass / ID sleeve", bay: .cabin, why: "Keep it with the phone, not in a jacket you might leave in the lodge."),
            GearPiece(name: "SPF lip + face stick", bay: .cabin, why: "Windburn starts before you notice sun on a cold ridge."),
            GearPiece(name: "Phone brick + short cable", bay: .cabin, why: "Cold kills batteries by first lunch if you shoot video.")
        ]

        if nights >= 3 {
            pieces.append(GearPiece(name: "Second midlayer", bay: .hold, why: "A dry fleece for day three after two dump days."))
        }

        switch snow {
        case .dump:
            pieces.append(contentsOf: [
                GearPiece(name: "Low-light goggle lens", bay: .bootBag, why: "Storm light goes flat; a rose/amber lens keeps trees readable."),
                GearPiece(name: "Shell pants + taped jacket", bay: .hold, why: "Softshell soaks through by run four in a true dump."),
                GearPiece(name: "Neck tube, not a scarf", bay: .bootBag, why: "A scarf ices and pulls. A tube stays under the helmet."),
                GearPiece(name: "Spare gloves", bay: .hold, why: "Dump days soak one pair before noon.")
            ])
        case .groomer:
            pieces.append(contentsOf: [
                GearPiece(name: "Thin hardpack gloves", bay: .bootBag, why: "Bulky dump mittens overheat on icy groomers."),
                GearPiece(name: "Edge-tune reminder card", bay: .cabin, why: "Hardpack punishes dull edges more than any other window."),
                GearPiece(name: "Hip-flask tea flask", bay: .cabin, why: "Warm drink at 11am when the wind strips heat on open pistes.")
            ])
        case .corn:
            pieces.append(contentsOf: [
                GearPiece(name: "Light shell only", bay: .bootBag, why: "Corn days spike fast; a heavy insulated jacket becomes a burden."),
                GearPiece(name: "Sunhat for the lift", bay: .cabin, why: "Helmet-off laps still burn. Pack a brim."),
                GearPiece(name: "Water bottle, not just a bar", bay: .cabin, why: "Spring snow dehydrates harder than storm days.")
            ])
        case .mixed:
            pieces.append(contentsOf: [
                GearPiece(name: "Zip-off extra layer", bay: .bootBag, why: "Mixed windows swing 8–10°C between first chair and last."),
                GearPiece(name: "Both goggle lenses", bay: .bootBag, why: "Clouds roll; you will swap at 10:30 more often than you think.")
            ])
        }

        switch travel {
        case .fly:
            pieces.append(contentsOf: [
                GearPiece(name: "Boot bag as carry-on", bay: .cabin, why: "Boots in the hold get delayed. You can rent skis, not a fitted boot."),
                GearPiece(name: "Fold-flat helmet bag", bay: .cabin, why: "Most airlines treat a helmet as a second personal item if padded."),
                GearPiece(name: "Ski-bag zipper locks", bay: .hold, why: "Stops the bag exploding on the belt, not theft theatre."),
                GearPiece(name: "Paper backup of lodging", bay: .cabin, why: "Mountain cell service dies in the valley. Screenshot is not enough if the phone is cold-dead.")
            ])
        case .drive:
            pieces.append(contentsOf: [
                GearPiece(name: "Windshield ice kit", bay: .car, why: "Lot ice is thicker than home ice. Scraper plus de-icer."),
                GearPiece(name: "Blanket + extra water", bay: .car, why: "Dawn lots close in. This is the wait-out-the-chain kit."),
                GearPiece(name: "Boot dryer or dry towels", bay: .car, why: "Drive nights: dry boots in the car with doors cracked, not in a wet tub."),
                GearPiece(name: "Microspikes or lot traction", bay: .car, why: "The walk from car to lodge injures more people than run one.")
            ])
        }

        return pieces
    }
}
