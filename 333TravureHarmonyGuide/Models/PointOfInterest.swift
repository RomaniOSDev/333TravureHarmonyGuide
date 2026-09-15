import Foundation

struct DawnBeat: Identifiable, Hashable {
    let id: String
    let minutesBeforeChair: Int
    let title: String
    let detail: String

    var whenLabel: String {
        if minutesBeforeChair == 0 {
            return "Chair"
        }
        if minutesBeforeChair > 0 {
            return "T-\(minutesBeforeChair)m"
        }
        return "T+\(-minutesBeforeChair)m"
    }
}

enum DawnScript {
    static let beats: [DawnBeat] = [
        DawnBeat(
            id: "boots-warm",
            minutesBeforeChair: 70,
            title: "Warm the boots",
            detail: "Room heater, boot dryer, or under the covers. Frozen liners steal the first hour of the day."
        ),
        DawnBeat(
            id: "lens-call",
            minutesBeforeChair: 55,
            title: "Pick the lens from the window",
            detail: "Look at the ridge, not the app. Flat cloud = amber. Hard blue = sunny. Mixed = both lenses in the bag."
        ),
        DawnBeat(
            id: "pass-phone",
            minutesBeforeChair: 45,
            title: "Pass, ID, and phone brick",
            detail: "These three live together. A jacket pocket you might leave in the lodge is not a plan."
        ),
        DawnBeat(
            id: "car-or-lobby",
            minutesBeforeChair: 35,
            title: "Move to the warm staging spot",
            detail: "Car with engine on, or lodge lobby. Do not finish dressing in a windy lot."
        ),
        DawnBeat(
            id: "goggle-heat",
            minutesBeforeChair: 20,
            title: "Heat the goggles",
            detail: "Defrost on the dash or against a warm chest layer. Spit and fog cloths fail at -10."
        ),
        DawnBeat(
            id: "click-in",
            minutesBeforeChair: 8,
            title: "Click in off to the side",
            detail: "Not in the funnel. Bindings and cold fingers need space. Then join the line."
        ),
        DawnBeat(
            id: "first-chair",
            minutesBeforeChair: 0,
            title: "First chair",
            detail: "Visor down, hands in, no phone out. The run is the point of the alarm."
        ),
        DawnBeat(
            id: "layer-check",
            minutesBeforeChair: -25,
            title: "Vent after run one",
            detail: "If you are damp, unzip now. Wet base layers at 9am become a cold stop at 11."
        )
    ]
}
