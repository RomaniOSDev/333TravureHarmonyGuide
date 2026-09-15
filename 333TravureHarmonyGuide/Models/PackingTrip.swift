import Foundation

struct KitBayGroup: Identifiable {
    let id: String
    let bay: GearBay
    let pieces: [GearPiece]
}

enum KitBayLayout {
    static func groups(from pieces: [GearPiece]) -> [KitBayGroup] {
        GearBay.allCases.compactMap { bay in
            let items = pieces.filter { $0.bay == bay }
            guard !items.isEmpty else { return nil }
            return KitBayGroup(id: bay.rawValue, bay: bay, pieces: items)
        }
    }
}
