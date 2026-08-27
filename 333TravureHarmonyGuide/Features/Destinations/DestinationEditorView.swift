import SwiftUI

struct DestinationEditorView: View {
    @EnvironmentObject private var store: AppStore
    @Environment(\.dismiss) private var dismiss

    let existing: Destination?

    @State private var name = ""
    @State private var country = ""
    @State private var regionCode = ""
    @State private var climate = ClimateKind.temperate.rawValue
    @State private var hasDate = false
    @State private var plannedDate = Date()
    @State private var timeZoneIdentifier = ""
    @State private var nameError: String?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    TicketStubCard {
                        VStack(spacing: 14) {
                            JournalField(
                                title: "Destination name",
                                identifier: "destinationNameField",
                                text: $name,
                                placeholder: "Kyoto, Lisbon, Oaxaca…"
                            )
                            if let nameError {
                                InlineErrorText(message: nameError)
                            }

                            JournalField(
                                title: "Country",
                                identifier: "destinationCountryField",
                                text: $country,
                                placeholder: "Japan"
                            )

                            JournalField(
                                title: "Region code",
                                identifier: "destinationRegionField",
                                text: $regionCode,
                                placeholder: "EU, JP, UK, TH…"
                            )

                            VStack(alignment: .leading, spacing: 6) {
                                Text("Climate")
                                    .font(.system(.caption, design: .serif))
                                    .foregroundColor(Color("AppInk").opacity(0.85))
                                Picker("Climate", selection: $climate) {
                                    ForEach(ClimateKind.allCases) { kind in
                                        Text(kind.rawValue).tag(kind.rawValue)
                                    }
                                }
                                .pickerStyle(.menu)
                                .tint(Color("AppInk"))
                                .frame(maxWidth: .infinity, minHeight: Theme.tap, alignment: .leading)
                                .padding(.horizontal, 8)
                                .background(Color("AppBackground").opacity(0.7))
                                .overlay {
                                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                                        .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [5, 3]))
                                        .foregroundColor(Color("AppAccent").opacity(0.55))
                                }
                                .accessibilityIdentifier("destinationClimatePicker")
                            }

                            Toggle(isOn: $hasDate) {
                                Text("Set travel date")
                                    .font(.system(.body, design: .serif))
                                    .foregroundColor(Color("AppInk"))
                            }
                            .frame(minHeight: Theme.tap)
                            .tint(Color("AppAccent"))
                            .accessibilityIdentifier("destinationDateToggle")

                            if hasDate {
                                DatePicker(
                                    "Planned date",
                                    selection: $plannedDate,
                                    displayedComponents: .date
                                )
                                .datePickerStyle(.compact)
                                .frame(minHeight: Theme.tap)
                                .accessibilityIdentifier("destinationDatePicker")
                            }

                            VStack(alignment: .leading, spacing: 6) {
                                Text("Local time zone")
                                    .font(.system(.caption, design: .serif))
                                    .foregroundColor(Color("AppInk").opacity(0.85))
                                Picker("Time zone", selection: $timeZoneIdentifier) {
                                    Text("Device time").tag("")
                                    ForEach(TravelUnit.units(for: .zones)) { zone in
                                        Text(zone.displayName).tag(zone.code)
                                    }
                                }
                                .pickerStyle(.menu)
                                .tint(Color("AppInk"))
                                .frame(maxWidth: .infinity, minHeight: Theme.tap, alignment: .leading)
                                .padding(.horizontal, 8)
                                .background(Color("AppBackground").opacity(0.7))
                                .overlay {
                                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                                        .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [5, 3]))
                                        .foregroundColor(Color("AppAccent").opacity(0.55))
                                }
                                .accessibilityIdentifier("destinationTimeZonePicker")
                            }
                        }
                    }

                    JournalPrimaryButton(
                        title: existing == nil ? "Save destination" : "Update destination",
                        systemImage: "checkmark.circle.fill",
                        identifier: "saveDestinationButton"
                    ) {
                        save()
                    }
                }
                .padding(16)
            }
            .journalCanvas()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(existing == nil ? "New destination" : "Edit destination")
                        .font(.system(.headline, design: .serif))
                        .accessibilityIdentifier("destinationEditorTitle")
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .frame(minHeight: Theme.tap)
                        .accessibilityIdentifier("cancelDestinationEditorButton")
                }
            }
            .onAppear(perform: hydrate)
        }
    }

    private func hydrate() {
        guard let existing else { return }
        name = existing.name
        country = existing.country
        regionCode = existing.regionCode
        climate = existing.climate
        timeZoneIdentifier = existing.timeZoneIdentifier
        if let date = existing.plannedDate {
            hasDate = true
            plannedDate = date
        }
    }

    private func save() {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            nameError = "Name is required"
            Haptics.warning()
            return
        }
        nameError = nil
        let record = Destination(
            id: existing?.id ?? UUID(),
            name: trimmed,
            country: country.trimmingCharacters(in: .whitespacesAndNewlines),
            regionCode: regionCode.trimmingCharacters(in: .whitespacesAndNewlines),
            plannedDate: hasDate ? plannedDate : nil,
            visited: existing?.visited ?? false,
            climate: climate,
            coverPhotoName: existing?.coverPhotoName,
            timeZoneIdentifier: timeZoneIdentifier
        )
        if existing == nil {
            store.addDestination(record)
        } else {
            store.updateDestination(record)
        }
        Haptics.success()
        dismiss()
    }
}
