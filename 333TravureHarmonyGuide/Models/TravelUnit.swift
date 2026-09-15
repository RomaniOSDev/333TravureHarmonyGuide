import Foundation

struct LayerLine: Identifiable, Hashable {
    let id: String
    let slot: String
    let piece: String
    let note: String
}

enum LayerRecipe {
    static func lines(tempC: Int, snow: SnowWindow) -> [LayerLine] {
        var base = LayerLine(
            id: "base",
            slot: "Base",
            piece: tempC <= -12 ? "Heavy merino, long sleeve + pant" : "Light merino set",
            note: tempC <= -12
                ? "The only day a thick base earns its bag space."
                : "If you start heavier than this, you will vent too late."
        )
        var mid = LayerLine(
            id: "mid",
            slot: "Mid",
            piece: tempC <= -8 ? "Grid fleece or light synthetic puffy" : "Vest or nothing",
            note: "The mid is for the chair, not the lot. Add it at the maze."
        )
        var shell = LayerLine(
            id: "shell",
            slot: "Shell",
            piece: snow == .dump ? "Taped 3L jacket + pant" : "Wind shell, pit zips open",
            note: snow == .dump
                ? "Softshell soaks. Taped or stay home after lunch."
                : "Wind is the cold, not the snowflake count."
        )
        let spare = LayerLine(
            id: "spare",
            slot: "Spare",
            piece: snow == .corn ? "Stowable vest only" : "Dry gloves + dry neck tube",
            note: "The spare is for 1pm you, not 7am you."
        )

        if snow == .corn && tempC >= -2 {
            base = LayerLine(
                id: "base",
                slot: "Base",
                piece: "Light short-sleeve merino under a long-sleeve you can peel",
                note: "Corn overheats. Plan a peel at 10:30."
            )
            mid = LayerLine(
                id: "mid",
                slot: "Mid",
                piece: "None at first chair",
                note: "You can add a vest. You cannot subtract a soaked fleece."
            )
        }

        if snow == .groomer && tempC <= -6 {
            shell = LayerLine(
                id: "shell",
                slot: "Shell",
                piece: "Windproof with a high collar",
                note: "Groomer wind on an open piste is colder than a dump in the trees."
            )
        }

        return [base, mid, shell, spare]
    }
}
