import SwiftUI

struct DropEditorView: View {
    @EnvironmentObject private var store: AppStore
    @Environment(\.dismiss) private var dismiss

    let existing: SkiDrop?

    @State private var title = ""
    @State private var ridgeId = RidgeCatalog.all[0].id
    @State private var firstChairAt = Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()
    @State private var nights = 3
    @State private var travel: TravelMode = .drive
    @State private var snow: SnowWindow = .mixed
    @State private var chairTempC = -4
    @State private var titleError: String?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    LiftPassCard {
                        VStack(spacing: 14) {
                            RidgeField(
                                title: "Drop name",
                                identifier: "dropTitleField",
                                text: $title,
                                placeholder: "Sunday first chair"
                            )
                            if let titleError {
                                InlineErrorText(message: titleError)
                            }

                            VStack(alignment: .leading, spacing: 6) {
                                Text("Ridge brief")
                                    .font(.system(.caption, design: .rounded))
                                    .foregroundColor(Color("AppInk").opacity(0.85))
                                Picker("Ridge brief", selection: $ridgeId) {
                                    ForEach(RidgeCatalog.all) { brief in
                                        Text(brief.name).tag(brief.id)
                                    }
                                }
                                .pickerStyle(.menu)
                                .tint(Color("AppInk"))
                                .frame(maxWidth: .infinity, minHeight: Theme.tap, alignment: .leading)
                                .accessibilityIdentifier("ridgePicker")
                                .onChange(of: ridgeId) { newId in
                                    let brief = RidgeCatalog.brief(id: newId)
                                    snow = brief.defaultSnow
                                    travel = brief.defaultTravel
                                }
                            }

                            DatePicker(
                                "First chair",
                                selection: $firstChairAt
                            )
                            .font(.system(.body, design: .rounded))
                            .foregroundColor(Color("AppInk"))
                            .tint(Color("AppAccent"))
                            .accessibilityIdentifier("firstChairPicker")

                            Stepper(value: $nights, in: 1...14) {
                                Text("\(nights) nights on hill")
                                    .font(.system(.body, design: .rounded))
                                    .foregroundColor(Color("AppInk"))
                            }
                            .accessibilityIdentifier("nightsStepper")

                            Picker("Travel", selection: $travel) {
                                ForEach(TravelMode.allCases) { mode in
                                    Text(mode.rawValue).tag(mode)
                                }
                            }
                            .pickerStyle(.segmented)
                            .accessibilityIdentifier("travelPicker")

                            Picker("Snow window", selection: $snow) {
                                ForEach(SnowWindow.allCases) { window in
                                    Text(window.rawValue).tag(window)
                                }
                            }
                            .pickerStyle(.menu)
                            .tint(Color("AppInk"))
                            .frame(maxWidth: .infinity, minHeight: Theme.tap, alignment: .leading)
                            .accessibilityIdentifier("snowPicker")

                            Stepper(value: $chairTempC, in: -25...10) {
                                Text("First-chair feel \(chairTempC)°C")
                                    .font(.system(.body, design: .rounded))
                                    .foregroundColor(Color("AppInk"))
                            }
                            .accessibilityIdentifier("tempStepper")
                        }
                    }

                    LiftPassCard {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(RidgeCatalog.brief(id: ridgeId).name)
                                .font(.system(.headline, design: .rounded))
                                .foregroundColor(Color("AppInk"))
                            Text(RidgeCatalog.brief(id: ridgeId).snowRead)
                                .font(.system(.caption, design: .rounded))
                                .foregroundColor(Color("AppInk").opacity(0.8))
                        }
                    }

                    RidgePrimaryButton(
                        title: existing == nil ? "Set the drop" : "Save drop",
                        systemImage: "checkmark.circle.fill",
                        identifier: "saveDropButton"
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
                    Text(existing == nil ? "New drop" : "Edit drop")
                        .font(.system(.headline, design: .rounded))
                        .foregroundColor(Color("AppInk"))
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") { dismiss() }
                        .frame(minHeight: Theme.tap)
                        .accessibilityIdentifier("closeDropEditorButton")
                }
            }
            .onAppear {
                if let existing {
                    title = existing.title
                    ridgeId = existing.ridgeId
                    firstChairAt = existing.firstChairAt
                    nights = existing.nights
                    travel = existing.travel
                    snow = existing.snow
                    chairTempC = existing.chairTempC
                }
            }
        }
    }

    private func save() {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            titleError = "Name the drop"
            return
        }
        titleError = nil
        if var existing {
            existing.title = trimmed
            existing.ridgeId = ridgeId
            existing.firstChairAt = firstChairAt
            existing.nights = nights
            existing.travel = travel
            existing.snow = snow
            existing.chairTempC = chairTempC
            store.updateDrop(existing)
        } else {
            store.addDrop(
                SkiDrop(
                    title: trimmed,
                    ridgeId: ridgeId,
                    firstChairAt: firstChairAt,
                    nights: nights,
                    travel: travel,
                    snow: snow,
                    chairTempC: chairTempC
                )
            )
        }
        dismiss()
    }
}
