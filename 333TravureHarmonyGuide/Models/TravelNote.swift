import Foundation

struct RidgeBrief: Identifiable, Hashable {
    let id: String
    let name: String
    let range: String
    let symbol: String
    let snowRead: String
    let layering: String
    let packingDelta: String
    let firstChair: String
    let mistake: String
    let defaultSnow: SnowWindow
    let defaultTravel: TravelMode
}

enum RidgeCatalog {
    static let all: [RidgeBrief] = [
        RidgeBrief(
            id: "cedar-dump",
            name: "Cedar Dump Line",
            range: "Coastal evergreens, heavy snow",
            symbol: "tree.fill",
            snowRead: "Wet, dense snow loads trees and fills tracks in under an hour. Visibility collapses in the trees before it does on the open face. If you cannot see the next trunk gap, you are already late to switch to the amber lens.",
            layering: "Breathable base, one grid fleece, a fully taped shell. Skip the puffy under the shell — you will cook on the cat-track skate and then freeze when you unzip.",
            packingDelta: "Add a second pair of gloves, a low-light lens, and a neck tube. Leave the cotton hoodie at home; it will not dry overnight in a coastal lodge.",
            firstChair: "Be in boots 50 minutes before the lift. Wet lots eat time. Fog the goggles in the car with the heater, not with spit on the chair.",
            mistake: "Starting in a puffy because the parking lot feels arctic. The lot is wind; the trees are a steam room.",
            defaultSnow: .dump,
            defaultTravel: .drive
        ),
        RidgeBrief(
            id: "basalt-hardpack",
            name: "Basalt Hardpack",
            range: "High desert, groomed corduroy",
            symbol: "triangle.fill",
            snowRead: "Overnight freeze sets a glaze that lasts until 11. Edges matter more than flotation. The snow does not get softer with more runs — it gets louder and faster.",
            layering: "Thin merino, light fleece, wind shell. Hands go numb on the first chair then overheat. Pack liner gloves you can actually dexterity with.",
            packingDelta: "Bring the bright lens, a tune reminder, and tea. Dump mittens and fat powder skis are dead weight here.",
            firstChair: "Tune or at least check edges the night before. First chair is the best snow and the worst place to discover a dull ski.",
            mistake: "Dressing for a storm that is not coming. Hardpack days punish bulk and reward a quiet, cold start.",
            defaultSnow: .groomer,
            defaultTravel: .drive
        ),
        RidgeBrief(
            id: "apricot-corn",
            name: "Apricot Corn Bench",
            range: "South-facing spring benches",
            symbol: "sun.max.fill",
            snowRead: "Supportive overnight freeze, then a 90-minute corn window after the sun hits. Miss it and you are in mashed potatoes with no exit speed.",
            layering: "Base layer only under a light shell by 11. Start with a vest you can stow. Sun on the neck is the real hazard, not the cold.",
            packingDelta: "Water, brim hat, high-SPF stick, and a pack that can swallow the vest. Heavy insulated pants will wreck the afternoon.",
            firstChair: "Do not rush the 8am chair if the aspect is still frozen. The brief is to hit the bench when the surface sugars, not when the lot opens.",
            mistake: "Skiing the same pitch all morning. Corn moves around the mountain with the sun. Chase aspect, not vertical.",
            defaultSnow: .corn,
            defaultTravel: .drive
        ),
        RidgeBrief(
            id: "krummholz-freeze",
            name: "Krummholz Freeze",
            range: "Treeline wind, rime, thin air",
            symbol: "wind",
            snowRead: "Wind scours the face and dumps a slab behind every rib. The temperature you feel in the village is not the temperature on the ridge. Add 15 km/h of wind and you have a different kit.",
            layering: "Windproof shell is non-negotiable. A vest under the shell beats a thick puffy. Cover the face; rime on eyelashes is a real stop.",
            packingDelta: "Goggle cloth, spare gloves, and a shell with a usable hood under the helmet. A fashion beanie is useless above treeline.",
            firstChair: "Warm the boots in the room, not on the windy deck. Once they freeze, they stay frozen through lunch.",
            mistake: "Checking the town weather app and packing for that number. The ridge is a different climate.",
            defaultSnow: .mixed,
            defaultTravel: .drive
        ),
        RidgeBrief(
            id: "windcut-bowl",
            name: "Windcut Bowl",
            range: "Alpine bowl, long traverse",
            symbol: "mountain.2.fill",
            snowRead: "The bowl holds snow after the front is scraped. The cost is a long, cold traverse with no bail. If the wind is up, the traverse is the day, not the turns.",
            layering: "You need a layer you can vent on the climb-out skate without stopping. Zippers you can work with gloves on.",
            packingDelta: "Spare lens, a small vis-snack, and a real wind layer. Leave extra denim and city boots in the lodging.",
            firstChair: "If you want the bowl untracked, you are not sipping coffee. Boots on, pass out, move. The window is the first two chairs, then it is tracked to the ribs.",
            mistake: "Taking a lazy warm-up run 'just one groomer'. That is the bowl window gone.",
            defaultSnow: .dump,
            defaultTravel: .fly
        ),
        RidgeBrief(
            id: "soft-bag-flight",
            name: "Soft-Bag Flight",
            range: "Any hill you reach by air",
            symbol: "airplane",
            snowRead: "The snow at the destination is unknown until you land. Pack the lens kit and the glove kit for two windows, not one forecast screenshot.",
            layering: "Wear the midlayer on the plane. Checked puffies get compressed and take a night to loft.",
            packingDelta: "Boots in the cabin. Helmet padded as personal item. One ski-bag with both boards/skis and pants. Paper lodging backup. Do not check the only warm gloves.",
            firstChair: "Do not book a first-chair alarm for the morning you land unless the flight is a night-before arrival. Land, dry, sleep, then chase the chair.",
            mistake: "Checking the ski bag and the boot bag. Delayed boots end the trip. Delayed skis are a rental morning.",
            defaultSnow: .mixed,
            defaultTravel: .fly
        ),
        RidgeBrief(
            id: "cabin-lot-dawn",
            name: "Cabin-to-Lot Dawn",
            range: "Drive-up, dark lot, cold start",
            symbol: "car.fill",
            snowRead: "The lot tells the truth: glazed puddles mean a refreeze; slush at 6am means a short corn day. Scrape the windshield and read the lot before you read the app.",
            layering: "Dress in the car with the engine on. Walking from cabin to car in half-kit is how gloves start the day wet.",
            packingDelta: "Ice kit, blanket, water, boot towels, traction for the walk. A lodge locker is not a plan if you arrive at rope-drop.",
            firstChair: "Wheels rolling 70 minutes before the chair if the road has a chain control. Coffee is for the lot, not the kitchen table.",
            mistake: "Leaving boots in a cold car overnight 'to save time'. You just packed two ice bricks.",
            defaultSnow: .groomer,
            defaultTravel: .drive
        ),
        RidgeBrief(
            id: "glade-buffer",
            name: "Glade Buffer Day",
            range: "Tight trees, low light, variable",
            symbol: "leaf.fill",
            snowRead: "The glade is a buffer when the face is blown or icy. Speed is the enemy. You are looking for pockets, not a fall line.",
            layering: "Range of motion over warmth. A bulky puffy catches branches and soaks. Grid fleece plus shell.",
            packingDelta: "Amber lens, thinner gloves you can pole with, and a whistle on the pass sleeve. Fat mittens belong on the open face, not in the trees.",
            firstChair: "Let the first groomer crowd go. Your window is 30 minutes later when the trees are still untracked and the light has lifted one stop.",
            mistake: "Following a fast pack into a glade you have not scouted. The buffer day is slow on purpose.",
            defaultSnow: .mixed,
            defaultTravel: .drive
        )
    ]

    static func brief(id: String) -> RidgeBrief {
        all.first { $0.id == id } ?? all[0]
    }
}
