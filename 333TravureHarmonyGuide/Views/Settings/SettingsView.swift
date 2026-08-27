import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var store: AppStore
    @Environment(\.dismiss) private var dismiss
    @State private var confirmReset = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    PassportStamp(symbol: "location.north.line.fill", caption: "Journal", rotation: -6)
                        .padding(.top, 8)

                    TicketStubCard {
                        VStack(spacing: 8) {
                            settingsRow(
                                title: "Rate Us",
                                symbol: "star.circle.fill",
                                identifier: "rateUsButton"
                            ) {
                                AppLinks.rateApp()
                            }
                            dashedDivider
                            settingsRow(
                                title: "Privacy",
                                symbol: "doc.plaintext.fill",
                                identifier: "privacyButton"
                            ) {
                                AppLinks.openPrivacy()
                            }
                            dashedDivider
                            settingsRow(
                                title: "Terms",
                                symbol: "scroll.fill",
                                identifier: "termsButton"
                            ) {
                                AppLinks.openTerms()
                            }
                        }
                    }

                    TicketStubCard {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Danger zone")
                                .font(.system(.headline, design: .serif))
                                .foregroundColor(Color("AppInk"))
                            Text("Clears destinations, notes, packing lists, documents, photos, and logged conversions from this device.")
                                .font(.system(.caption, design: .serif))
                                .foregroundColor(Color("AppInk").opacity(0.78))
                            Button {
                                confirmReset = true
                            } label: {
                                HStack(spacing: 8) {
                                    Image(systemName: "trash.fill")
                                    Text("Reset All Data")
                                        .font(.system(.headline, design: .serif))
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity, minHeight: Theme.tap)
                                .background {
                                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                                        .fill(
                                            LinearGradient(
                                                colors: [Color("AppAccent"), Color("AppPrimary")],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                        .shadow(color: Color("AppAccent").opacity(0.3), radius: 6, y: 3)
                                }
                            }
                            .buttonStyle(.plain)
                            .accessibilityIdentifier("resetDataButton")
                            .journalTapTarget()
                        }
                    }
                }
                .padding(16)
            }
            .journalCanvas()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Settings")
                        .font(.system(.headline, design: .serif))
                        .foregroundColor(Color("AppInk"))
                        .accessibilityIdentifier("settingsTitle")
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .frame(minHeight: Theme.tap)
                        .accessibilityIdentifier("settingsDoneButton")
                }
            }
            .confirmationDialog(
                "Reset All Data?",
                isPresented: $confirmReset,
                titleVisibility: .visible
            ) {
                Button("Reset All Data", role: .destructive) {
                    store.resetAllData()
                    dismiss()
                }
                .accessibilityIdentifier("confirmResetDataButton")
                Button("Cancel", role: .cancel) {}
                    .accessibilityIdentifier("cancelResetDataButton")
            } message: {
                Text("This cannot be undone. All journal entries, packing lists, and conversion values will be removed.")
            }
        }
    }

    private var dashedDivider: some View {
        Rectangle()
            .fill(Color("AppAccent").opacity(0.35))
            .frame(height: 1)
            .overlay(
                Rectangle()
                    .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [4, 3]))
                    .foregroundColor(Color("AppAccent").opacity(0.5))
            )
    }

    private func settingsRow(title: String, symbol: String, identifier: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: symbol)
                    .foregroundColor(.white)
                    .frame(width: 32, height: 32)
                    .background(
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color("AppPrimary"), Color("AppAccent")],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                    )
                Text(title)
                    .font(.system(.body, design: .serif))
                    .foregroundColor(Color("AppInk"))
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundColor(Color("AppAccent"))
            }
            .frame(minHeight: Theme.tap)
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier(identifier)
        .journalTapTarget()
    }
}
