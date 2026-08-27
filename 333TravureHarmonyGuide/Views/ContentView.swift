import SwiftUI

struct ContentView: View {
    @StateObject private var store = AppStore()
    @State private var section: JournalSection = .destinations
    @State private var showSettings = false
    @State private var showInsights = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                sectionSwitcher
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .padding(.bottom, 10)

                Group {
                    switch section {
                    case .destinations:
                        DestinationListView()
                    case .packing:
                        PackingTripListView()
                    case .units:
                        UnitConverterView()
                    }
                }
                .id(section)
            }
            .journalCanvas()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack(spacing: 8) {
                        Image(systemName: "safari.fill")
                            .foregroundColor(Color("AppAccent"))
                        Text(section.title)
                            .font(.system(.headline, design: .serif))
                            .foregroundColor(Color("AppInk"))
                    }
                    .accessibilityIdentifier("screenTitle")
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        showInsights = true
                    } label: {
                        Image(systemName: "chart.bar.xaxis")
                            .foregroundColor(Color("AppInk"))
                            .frame(minWidth: Theme.tap, minHeight: Theme.tap)
                    }
                    .accessibilityIdentifier("openInsightsButton")
                    .accessibilityLabel("Statistics")
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
            .sheet(isPresented: $showInsights) {
                TripInsightView()
                    .environmentObject(store)
            }
        }
        .environmentObject(store)
        .preferredColorScheme(.dark)
        .tint(Color("AppAccent"))
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("dataReset"))) { _ in
            section = .destinations
        }
    }

    private var sectionSwitcher: some View {
        HStack(spacing: 4) {
            ForEach(JournalSection.allCases) { item in
                Button {
                    Haptics.light()
                    section = item
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: item.symbol)
                        Text(item.title)
                            .font(.system(.caption, design: .serif).weight(.semibold))
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
                .journalTapTarget()
            }
        }
        .padding(5)
        .background {
            Capsule()
                .fill(Color("AppSurface"))
                .shadow(color: Color("AppPrimary").opacity(0.16), radius: 6, y: 3)
            Capsule()
                .strokeBorder(style: StrokeStyle(lineWidth: 1.2, dash: [5, 3]))
                .foregroundColor(Color("AppAccent").opacity(0.7))
        }
        .accessibilityIdentifier("sectionSwitcher")
    }
}
