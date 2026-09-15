import SwiftUI

struct GearPieceEditorView: View {
    @EnvironmentObject private var store: AppStore
    @Environment(\.dismiss) private var dismiss

    let dropId: UUID
    let existing: GearPiece?

    @State private var name = ""
    @State private var why = ""
    @State private var bay: GearBay = .bootBag
    @State private var nameError: String?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    LiftPassCard {
                        VStack(spacing: 14) {
                            RidgeField(
                                title: "Piece",
                                identifier: "gearNameField",
                                text: $name,
                                placeholder: "Low-light lens"
                            )
                            if let nameError {
                                InlineErrorText(message: nameError)
                            }
                            RidgeField(
                                title: "Why it rides",
                                identifier: "gearWhyField",
                                text: $why,
                                placeholder: "Storm light goes flat in the trees"
                            )
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Bay")
                                    .font(.system(.caption, design: .rounded))
                                    .foregroundColor(Color("AppInk").opacity(0.85))
                                Picker("Bay", selection: $bay) {
                                    ForEach(GearBay.allCases) { item in
                                        Text(item.rawValue).tag(item)
                                    }
                                }
                                .pickerStyle(.menu)
                                .tint(Color("AppInk"))
                                .frame(maxWidth: .infinity, minHeight: Theme.tap, alignment: .leading)
                                .accessibilityIdentifier("gearBayPicker")
                            }
                        }
                    }

                    RidgePrimaryButton(
                        title: existing == nil ? "Add to kit" : "Save piece",
                        systemImage: "checkmark.circle.fill",
                        identifier: "saveGearButton"
                    ) {
                        save()
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 28)
            }
            .clearScrollBackground()
            .ridgeCanvas()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(existing == nil ? "New piece" : "Edit piece")
                        .font(.system(.headline, design: .rounded))
                        .foregroundColor(Color("AppInk"))
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") { dismiss() }
                        .frame(minHeight: Theme.tap)
                }
            }
            .onAppear {
                if let existing {
                    name = existing.name
                    why = existing.why
                    bay = existing.bay
                }
            }
        }
    }

    private func save() {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            nameError = "Name the piece"
            return
        }
        let reason = why.trimmingCharacters(in: .whitespacesAndNewlines)
        let resolvedWhy = reason.isEmpty ? "Added for this drop." : reason
        nameError = nil
        if var existing {
            existing.name = trimmed
            existing.why = resolvedWhy
            existing.bay = bay
            if store.updateGear(dropId: dropId, piece: existing) {
                dismiss()
            } else {
                nameError = "Already in this kit"
            }
        } else if store.addGear(dropId: dropId, name: trimmed, bay: bay, why: resolvedWhy) {
            dismiss()
        } else {
            nameError = "Already in this kit"
        }
    }
}
