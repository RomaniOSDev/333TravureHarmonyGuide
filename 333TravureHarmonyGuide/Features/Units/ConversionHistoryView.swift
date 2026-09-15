import SwiftUI

struct BriefDetailView: View {
    @EnvironmentObject private var store: AppStore
    let brief: RidgeBrief

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                LiftPassCard {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Image(systemName: brief.symbol)
                                .foregroundColor(Color("AppAccent"))
                            Text(brief.name)
                                .font(.system(.title2, design: .rounded).weight(.bold))
                                .foregroundColor(Color("AppInk"))
                        }
                        Text(brief.range)
                            .font(.system(.subheadline, design: .rounded))
                            .foregroundColor(Color("AppInk").opacity(0.75))
                    }
                }

                section(title: "Snow read", body: brief.snowRead)
                section(title: "Layering", body: brief.layering)
                section(title: "Packing delta", body: brief.packingDelta)
                section(title: "First chair", body: brief.firstChair)
                section(title: "The usual mistake", body: brief.mistake)

                if let drop = store.activeDrop {
                    RidgePrimaryButton(
                        title: "Apply to \(drop.title)",
                        systemImage: "arrow.triangle.2.circlepath",
                        identifier: "applyBriefButton"
                    ) {
                        store.applyBrief(brief, to: drop.id)
                    }
                    Text("Applies this brief’s snow window, travel mode, and rebuilds the kit.")
                        .font(.system(.caption, design: .rounded))
                        .foregroundColor(Color("AppInk").opacity(0.7))
                        .multilineTextAlignment(.center)
                } else {
                    Text("Plan a drop on Launch, then you can pin this brief to it.")
                        .font(.system(.caption, design: .rounded))
                        .foregroundColor(Color("AppInk").opacity(0.75))
                        .multilineTextAlignment(.center)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 28)
        }
        .clearScrollBackground()
        .ridgeCanvas()
        .navigationTitle("Brief")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func section(title: String, body: String) -> some View {
        LiftPassCard {
            VStack(alignment: .leading, spacing: 8) {
                Text(title.uppercased())
                    .font(.system(.caption2, design: .rounded).weight(.bold))
                    .foregroundColor(Color("AppAccent"))
                Text(body)
                    .font(.system(.body, design: .rounded))
                    .foregroundColor(Color("AppInk"))
            }
        }
    }
}
