import SwiftUI

struct KitLegendView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                LiftPassCard {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("How the bays work")
                            .font(.system(.headline, design: .rounded))
                            .foregroundColor(Color("AppInk"))
                        bayCopy(
                            title: "Boot bag",
                            text: "The kit you cannot rent in a hurry: boots, helmet, lenses, gloves. If you fly, this bay stays with you."
                        )
                        bayCopy(
                            title: "Cabin",
                            text: "Warm layers, pass, phone brick, paper lodging. Anything that dies in a cold hold."
                        )
                        bayCopy(
                            title: "Hold / roof",
                            text: "Skis, boards, shells, spare mids. Delay-tolerant. Never put the only gloves here."
                        )
                        bayCopy(
                            title: "Car cache",
                            text: "Dawn-lot insurance: ice, water, blanket, traction. Drive drops only."
                        )
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 28)
        }
        .clearScrollBackground()
        .ridgeCanvas()
        .navigationTitle("Kit bays")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func bayCopy(title: String, text: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(.subheadline, design: .rounded).weight(.semibold))
                .foregroundColor(Color("AppAccent"))
            Text(text)
                .font(.system(.caption, design: .rounded))
                .foregroundColor(Color("AppInk").opacity(0.8))
        }
    }
}
