import SwiftUI

struct ContentView: View {
    @StateObject private var store = AppStore()
    @State private var section: AppSection = .launch
    @State private var showSettings = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.clear
                VStack(spacing: 0) {
                    sectionSwitcher
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                        .padding(.bottom, 10)

                    Group {
                        switch section {
                        case .launch:
                            LaunchHomeView()
                        case .kit:
                            KitBayView()
                        case .briefs:
                            BriefsLibraryView()
                        }
                    }
                    .id(section)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .ridgeCanvas()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack(spacing: 8) {
                        Image(systemName: "figure.skiing.downhill")
                            .foregroundColor(Color("AppAccent"))
                        Text(section.title)
                            .font(.system(.headline, design: .rounded))
                            .foregroundColor(Color("AppInk"))
                    }
                    .accessibilityIdentifier("screenTitle")
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "gearshape.fill")
                            .foregroundColor(Color("AppInk"))
                            .frame(minWidth: Theme.tap, minHeight: Theme.tap)
                    }
                    .accessibilityIdentifier("openSettingsButton")
                    .accessibilityLabel("Settings")
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
                    .environmentObject(store)
            }
        }
        .environmentObject(store)
        .preferredColorScheme(.dark)
        .tint(Color("AppAccent"))
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("dataReset"))) { _ in
            section = .launch
        }
    }

    private var sectionSwitcher: some View {
        HStack(spacing: 4) {
            ForEach(AppSection.allCases) { item in
                Button {
                    Haptics.light()
                    section = item
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: item.symbol)
                        Text(item.title)
                            .font(.system(.caption, design: .rounded).weight(.semibold))
                            .lineLimit(1)
                    }
                    .foregroundColor(section == item ? .white : Color("AppInk"))
                    .frame(maxWidth: .infinity, minHeight: Theme.tap)
                    .background {
                        Capsule()
                            .fill(
                                section == item
                                    ? AnyShapeStyle(
                                        LinearGradient(
                                            colors: [Color("AppPrimary"), Color("AppAccent")],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    : AnyShapeStyle(Color.clear)
                            )
                    }
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("section_\(item.rawValue)")
                .accessibilityLabel(item.title)
                .ridgeTapTarget()
            }
        }
        .padding(5)
        .background {
            Capsule()
                .fill(Color("AppSurface"))
                .shadow(color: Color("AppPrimary").opacity(0.16), radius: 6, y: 3)
            Capsule()
                .strokeBorder(Color("AppAccent").opacity(0.55), lineWidth: 1)
        }
        .accessibilityIdentifier("sectionSwitcher")
    }
}
