import SwiftUI

struct DropDetailView: View {
    @EnvironmentObject private var store: AppStore
    let dropId: UUID

    @State private var showEditor = false
    @State private var confirmDelete = false

    var body: some View {
        Group {
            if let drop = store.drop(id: dropId) {
                detail(drop)
            } else {
                RidgeEmptyState(symbol: "snowflake", message: "This drop is no longer on the board.")
                    .ridgeCanvas()
            }
        }
    }

    private func detail(_ drop: SkiDrop) -> some View {
        ScrollView {
            VStack(spacing: 18) {
                LiftPassCard {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(drop.title)
                            .font(.system(.title2, design: .rounded).weight(.bold))
                            .foregroundColor(Color("AppInk"))
                        TimelineView(.periodic(from: .now, by: 30)) { _ in
                            Text(drop.countdownLabel)
                                .font(.system(.title, design: .rounded).weight(.semibold))
                                .foregroundColor(Color("AppAccent"))
                        }
                        Text(drop.chairClockLabel)
                            .font(.system(.subheadline, design: .rounded))
                            .foregroundColor(Color("AppInk").opacity(0.8))
                        Text(drop.ridge.name)
                            .font(.system(.headline, design: .rounded))
                            .foregroundColor(Color("AppInk"))
                        Text(drop.ridge.firstChair)
                            .font(.system(.caption, design: .rounded))
                            .foregroundColor(Color("AppInk").opacity(0.8))

                        HStack {
                            ChairPunch(symbol: drop.snow.symbol, caption: drop.snow.rawValue)
                            ChairPunch(symbol: drop.travel.symbol, caption: drop.travel.rawValue)
                            ChairPunch(symbol: "thermometer", caption: "\(drop.chairTempC)°C")
                        }
                        .frame(maxWidth: .infinity)

                        RidgePrimaryButton(
                            title: "Edit drop",
                            systemImage: "pencil.circle.fill",
                            identifier: "editDropButton"
                        ) {
                            showEditor = true
                        }
                    }
                }

                layersCard(drop)
                dawnCard(drop)

                NavigationLink {
                    BriefDetailView(brief: drop.ridge)
                } label: {
                    LiftPassCard {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Full ridge brief")
                                    .font(.system(.headline, design: .rounded))
                                    .foregroundColor(Color("AppInk"))
                                Text(drop.ridge.range)
                                    .font(.system(.caption, design: .rounded))
                                    .foregroundColor(Color("AppInk").opacity(0.75))
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(Color("AppAccent"))
                        }
                    }
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("openRidgeBriefButton")

                Button {
                    confirmDelete = true
                } label: {
                    Text("Remove drop")
                        .font(.system(.headline, design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, minHeight: Theme.tap)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(Color("AppAccent").opacity(0.85))
                        )
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("deleteDropButton")
                .ridgeTapTarget()
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 28)
        }
        .clearScrollBackground()
        .ridgeCanvas()
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Launch card")
                    .font(.system(.headline, design: .rounded))
                    .foregroundColor(Color("AppInk"))
            }
        }
        .sheet(isPresented: $showEditor) {
            DropEditorView(existing: drop)
                .environmentObject(store)
        }
        .confirmationDialog("Remove this drop?", isPresented: $confirmDelete, titleVisibility: .visible) {
            Button("Remove drop", role: .destructive) {
                store.deleteDrop(id: drop.id)
            }
            .accessibilityIdentifier("confirmDeleteDropButton")
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Kit checks and dawn beats for this drop will be cleared.")
        }
    }

    private func layersCard(_ drop: SkiDrop) -> some View {
        LiftPassCard {
            VStack(alignment: .leading, spacing: 12) {
                Text("Layer stack")
                    .font(.system(.headline, design: .rounded))
                    .foregroundColor(Color("AppInk"))
                Text("Built from first-chair feel and the snow window — not a generic packing list.")
                    .font(.system(.caption, design: .rounded))
                    .foregroundColor(Color("AppInk").opacity(0.75))
                ForEach(LayerRecipe.lines(tempC: drop.chairTempC, snow: drop.snow)) { line in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(line.slot.uppercased())
                            .font(.system(.caption2, design: .rounded).weight(.bold))
                            .foregroundColor(Color("AppAccent"))
                        Text(line.piece)
                            .font(.system(.body, design: .rounded).weight(.semibold))
                            .foregroundColor(Color("AppInk"))
                        Text(line.note)
                            .font(.system(.caption, design: .rounded))
                            .foregroundColor(Color("AppInk").opacity(0.75))
                    }
                    .padding(.vertical, 4)
                }
            }
        }
    }

    private func dawnCard(_ drop: SkiDrop) -> some View {
        LiftPassCard {
            VStack(alignment: .leading, spacing: 12) {
                Text("Dawn script")
                    .font(.system(.headline, design: .rounded))
                    .foregroundColor(Color("AppInk"))
                ForEach(DawnScript.beats) { beat in
                    Button {
                        store.toggleDawn(dropId: drop.id, beatId: beat.id)
                    } label: {
                        HStack(alignment: .top, spacing: 12) {
                            Image(systemName: drop.isDawnDone(beat.id) ? "checkmark.square.fill" : "square")
                                .foregroundColor(Color("AppAccent"))
                                .frame(width: 28, height: 28)
                            VStack(alignment: .leading, spacing: 4) {
                                Text("\(beat.whenLabel)  ·  \(beat.title)")
                                    .font(.system(.subheadline, design: .rounded).weight(.semibold))
                                    .foregroundColor(Color("AppInk"))
                                    .strikethrough(drop.isDawnDone(beat.id))
                                Text(beat.detail)
                                    .font(.system(.caption, design: .rounded))
                                    .foregroundColor(Color("AppInk").opacity(0.75))
                                    .multilineTextAlignment(.leading)
                            }
                            Spacer(minLength: 0)
                        }
                        .frame(minHeight: Theme.tap, alignment: .top)
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("dawnBeat_\(beat.id)")
                }
            }
        }
    }
}
