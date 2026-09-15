import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var store: AppStore
    @Environment(\.dismiss) private var dismiss
    @State private var confirmReset = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    ChairPunch(symbol: "figure.skiing.downhill", caption: "Chairline")
                        .padding(.top, 8)

                    LiftPassCard {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("What this is")
                                .font(.system(.headline, design: .rounded))
                                .foregroundColor(Color("AppInk"))
                            Text("A first-chair launch pad: countdown, snow-specific kit, and original ridge briefs. Not a travel journal, not a unit converter, not a generic packing app.")
                                .font(.system(.caption, design: .rounded))
                                .foregroundColor(Color("AppInk").opacity(0.8))
                        }
                    }

                    LiftPassCard {
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

                    LiftPassCard {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Clear this device")
                                .font(.system(.headline, design: .rounded))
                                .foregroundColor(Color("AppInk"))
                            Text("Removes ski drops, kit checks, and dawn beats stored on this iPhone.")
                                .font(.system(.caption, design: .rounded))
                                .foregroundColor(Color("AppInk").opacity(0.78))
                            Button {
                                confirmReset = true
                            } label: {
                                HStack(spacing: 8) {
                                    Image(systemName: "trash.fill")
                                    Text("Reset All Data")
                                        .font(.system(.headline, design: .rounded))
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity, minHeight: Theme.tap)
                                .background {
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
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
                            .ridgeTapTarget()
                        }
                    }
                }
                .padding(16)
            }
            .clearScrollBackground()
            .ridgeCanvas()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Settings")
                        .font(.system(.headline, design: .rounded))
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
                Text("This cannot be undone. Drops, kits, and dawn checks will be removed.")
            }
        }
    }

    private var dashedDivider: some View {
        Rectangle()
            .fill(Color("AppAccent").opacity(0.35))
            .frame(height: 1)
    }

    private func settingsRow(title: String, symbol: String, identifier: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: symbol)
                    .foregroundColor(.white)
                    .frame(width: 32, height: 32)
                    .background(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [Color("AppPrimary"), Color("AppAccent")],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                    )
                Text(title)
                    .font(.system(.body, design: .rounded))
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
        .ridgeTapTarget()
    }
}
