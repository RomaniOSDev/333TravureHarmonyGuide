import SwiftUI

struct KitBayView: View {
    @EnvironmentObject private var store: AppStore
    @State private var showEditor = false
    @State private var editingPiece: GearPiece?
    @State private var pendingPiece: GearPiece?
    @State private var confirmDelete = false
    @State private var confirmRebuild = false

    var body: some View {
        Group {
            if let drop = store.activeDrop {
                kit(drop)
            } else {
                ScrollView {
                    VStack(spacing: 18) {
                        RidgeBanner(imageName: "bannerPack")
                        LiftPassCard {
                            RidgeEmptyState(
                                symbol: "bag.fill",
                                message: "Kit is tied to a drop. Set first chair on Launch, then pack by boot bag, cabin, hold, and car."
                            )
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .padding(.bottom, 28)
                }
                .clearScrollBackground()
            }
        }
    }

    private func kit(_ drop: SkiDrop) -> some View {
        ScrollView {
            VStack(spacing: 18) {
                RidgeBanner(imageName: "bannerPack")

                LiftPassCard {
                    VStack(alignment: .leading, spacing: 10) {
                        Text(drop.title)
                            .font(.system(.headline, design: .rounded))
                            .foregroundColor(Color("AppInk"))
                        Text("\(drop.packedCount) of \(drop.kit.count) stowed · \(drop.snow.rawValue) · \(drop.travel.rawValue)")
                            .font(.system(.caption, design: .rounded))
                            .foregroundColor(Color("AppInk").opacity(0.75))
                        ProgressView(value: drop.kitProgress)
                            .tint(Color("AppAccent"))
                            .accessibilityIdentifier("kitProgress")
                        Text("This is not a city-break packing list. Bays follow how ski kit actually travels.")
                            .font(.system(.caption, design: .rounded))
                            .foregroundColor(Color("AppInk").opacity(0.75))
                    }
                }

                ForEach(KitBayLayout.groups(from: drop.kit)) { group in
                    LiftPassCard {
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Image(systemName: group.bay.symbol)
                                Text(group.bay.rawValue)
                                    .font(.system(.headline, design: .rounded))
                            }
                            .foregroundColor(Color("AppInk"))

                            ForEach(group.pieces) { piece in
                                pieceRow(drop: drop, piece: piece)
                            }
                        }
                    }
                }

                RidgePrimaryButton(
                    title: "Add a piece",
                    systemImage: "plus.circle.fill",
                    identifier: "addGearButton"
                ) {
                    editingPiece = nil
                    showEditor = true
                }

                NavigationLink {
                    KitLegendView()
                } label: {
                    Text("How kit bays work")
                        .font(.system(.subheadline, design: .rounded).weight(.semibold))
                        .foregroundColor(Color("AppAccent"))
                        .frame(maxWidth: .infinity, minHeight: Theme.tap)
                }
                .accessibilityIdentifier("kitLegendButton")

                NavigationLink {
                    LayerStudioView()
                } label: {
                    Text("First-chair layer stack")
                        .font(.system(.subheadline, design: .rounded).weight(.semibold))
                        .foregroundColor(Color("AppAccent"))
                        .frame(maxWidth: .infinity, minHeight: Theme.tap)
                }
                .accessibilityIdentifier("layerStudioButton")

                Button {
                    confirmRebuild = true
                } label: {
                    Text("Rebuild kit from snow + travel")
                        .font(.system(.subheadline, design: .rounded).weight(.semibold))
                        .foregroundColor(Color("AppAccent"))
                        .frame(maxWidth: .infinity, minHeight: Theme.tap)
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("rebuildKitButton")
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 28)
        }
        .clearScrollBackground()
        .sheet(isPresented: $showEditor) {
            if let drop = store.activeDrop {
                GearPieceEditorView(dropId: drop.id, existing: editingPiece)
                    .environmentObject(store)
            }
        }
        .confirmationDialog("Rebuild this kit?", isPresented: $confirmRebuild, titleVisibility: .visible) {
            Button("Rebuild kit", role: .destructive) {
                store.rebuildKit(for: drop.id)
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Custom pieces will be replaced with the snow-and-travel template.")
        }
        .confirmationDialog("Remove this piece?", isPresented: $confirmDelete, titleVisibility: .visible) {
            Button("Remove piece", role: .destructive) {
                if let pendingPiece {
                    store.deleteGear(dropId: drop.id, pieceId: pendingPiece.id)
                }
                pendingPiece = nil
            }
            Button("Cancel", role: .cancel) { pendingPiece = nil }
        }
    }

    private func pieceRow(drop: SkiDrop, piece: GearPiece) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Button {
                store.toggleGear(dropId: drop.id, pieceId: piece.id)
            } label: {
                Image(systemName: piece.stowed ? "checkmark.square.fill" : "square")
                    .foregroundColor(Color("AppAccent"))
                    .frame(width: Theme.tap, height: Theme.tap)
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("toggleGear_\(piece.id.uuidString)")

            VStack(alignment: .leading, spacing: 4) {
                Text(piece.name)
                    .font(.system(.body, design: .rounded).weight(.semibold))
                    .foregroundColor(Color("AppInk"))
                    .strikethrough(piece.stowed)
                Text(piece.why)
                    .font(.system(.caption, design: .rounded))
                    .foregroundColor(Color("AppInk").opacity(0.75))
            }
            Spacer(minLength: 0)
            Button {
                editingPiece = piece
                showEditor = true
            } label: {
                Image(systemName: "pencil")
                    .foregroundColor(Color("AppAccent"))
                    .frame(width: Theme.tap, height: Theme.tap)
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("editGear_\(piece.id.uuidString)")
            Button {
                pendingPiece = piece
                confirmDelete = true
            } label: {
                Image(systemName: "trash")
                    .foregroundColor(Color("AppAccent"))
                    .frame(width: Theme.tap, height: Theme.tap)
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("deleteGear_\(piece.id.uuidString)")
        }
        .ridgeTapTarget()
    }
}
