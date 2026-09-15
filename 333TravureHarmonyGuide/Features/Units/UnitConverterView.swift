import SwiftUI

struct LayerStudioView: View {
    @EnvironmentObject private var store: AppStore

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                if let drop = store.activeDrop {
                    LiftPassCard {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("First-chair stack")
                                .font(.system(.headline, design: .rounded))
                                .foregroundColor(Color("AppInk"))
                            Text("\(drop.chairTempC)°C · \(drop.snow.rawValue)")
                                .font(.system(.caption, design: .rounded))
                                .foregroundColor(Color("AppAccent"))
                            ForEach(LayerRecipe.lines(tempC: drop.chairTempC, snow: drop.snow)) { line in
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(line.slot)
                                        .font(.system(.caption2, design: .rounded).weight(.bold))
                                        .foregroundColor(Color("AppAccent"))
                                    Text(line.piece)
                                        .font(.system(.body, design: .rounded).weight(.semibold))
                                        .foregroundColor(Color("AppInk"))
                                    Text(line.note)
                                        .font(.system(.caption, design: .rounded))
                                        .foregroundColor(Color("AppInk").opacity(0.75))
                                }
                            }
                        }
                    }
                    NavigationLink {
                        KitLegendView()
                    } label: {
                        Text("How kit bays work")
                            .font(.system(.subheadline, design: .rounded).weight(.semibold))
                            .foregroundColor(Color("AppAccent"))
                            .frame(maxWidth: .infinity, minHeight: Theme.tap)
                    }
                } else {
                    RidgeEmptyState(
                        symbol: "tshirt.fill",
                        message: "Set a drop with a first-chair temperature to see the layer stack."
                    )
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 28)
        }
        .clearScrollBackground()
        .ridgeCanvas()
        .navigationTitle("Layers")
        .navigationBarTitleDisplayMode(.inline)
    }
}
