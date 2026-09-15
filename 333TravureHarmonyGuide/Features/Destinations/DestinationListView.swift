import SwiftUI

struct LaunchHomeView: View {
    @EnvironmentObject private var store: AppStore
    @State private var showEditor = false

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                RidgeBanner(imageName: "bannerMap")

                if let drop = store.activeDrop {
                    hero(drop)
                    dawnPreview(drop)
                    upcomingList(excluding: drop.id)
                } else {
                    emptyState
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 28)
        }
        .clearScrollBackground()
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showEditor = true
                } label: {
                    Image(systemName: "plus")
                        .foregroundColor(Color("AppInk"))
                        .frame(minWidth: Theme.tap, minHeight: Theme.tap)
                }
                .accessibilityIdentifier("addDropToolbarButton")
                .accessibilityLabel("Plan a drop")
            }
        }
        .sheet(isPresented: $showEditor) {
            DropEditorView(existing: nil)
                .environmentObject(store)
        }
    }

    private var emptyState: some View {
        LiftPassCard {
            VStack(spacing: 16) {
                RidgeEmptyState(
                    symbol: "clock.badge.checkmark",
                    message: "No drop on the clock. Set first chair, snow window, and travel mode — Chairline builds the kit from there."
                )
                RidgePrimaryButton(
                    title: "Plan first chair",
                    systemImage: "plus.circle.fill",
                    identifier: "addDropButton"
                ) {
                    showEditor = true
                }
            }
        }
    }

    private func hero(_ drop: SkiDrop) -> some View {
        LiftPassCard {
            VStack(alignment: .leading, spacing: 14) {
                Text("NEXT CHAIR")
                    .font(.system(.caption2, design: .rounded).weight(.bold))
                    .foregroundColor(Color("AppAccent"))
                Text(drop.title)
                    .font(.system(.title2, design: .rounded).weight(.bold))
                    .foregroundColor(Color("AppInk"))
                Text(drop.ridge.name.uppercased())
                    .font(.system(.caption, design: .rounded).weight(.semibold))
                    .foregroundColor(Color("AppInk").opacity(0.75))

                TimelineView(.periodic(from: .now, by: 30)) { _ in
                    Text(drop.countdownLabel)
                        .font(.system(.title, design: .rounded).weight(.semibold))
                        .foregroundColor(Color("AppAccent"))
                        .accessibilityIdentifier("countdownLabel")
                }

                Text(drop.chairClockLabel)
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundColor(Color("AppInk").opacity(0.8))

                HStack(spacing: 10) {
                    chip(drop.snow.rawValue, symbol: drop.snow.symbol)
                    chip(drop.travel.rawValue, symbol: drop.travel.symbol)
                    chip("\(drop.nights) nights", symbol: "moon.fill")
                }

                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Kit")
                            .font(.system(.caption2, design: .rounded))
                            .foregroundColor(Color("AppInk").opacity(0.7))
                        ProgressView(value: drop.kitProgress)
                            .tint(Color("AppAccent"))
                        Text("\(drop.packedCount)/\(drop.kit.count) stowed")
                            .font(.system(.caption, design: .rounded))
                            .foregroundColor(Color("AppInk"))
                    }
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Dawn")
                            .font(.system(.caption2, design: .rounded))
                            .foregroundColor(Color("AppInk").opacity(0.7))
                        ProgressView(value: drop.dawnProgress)
                            .tint(Color("AppPrimary"))
                        Text("\(drop.dawnDone.count)/\(DawnScript.beats.count) beats")
                            .font(.system(.caption, design: .rounded))
                            .foregroundColor(Color("AppInk"))
                    }
                }

                NavigationLink {
                    DropDetailView(dropId: drop.id)
                } label: {
                    HStack {
                        Text("Open launch card")
                            .font(.system(.headline, design: .rounded))
                        Spacer()
                        Image(systemName: "chevron.right")
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, minHeight: Theme.tap)
                    .padding(.horizontal, 14)
                    .background {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [Color("AppPrimary"), Color("AppAccent")],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    }
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("openDropDetailButton")
            }
        }
    }

    private func dawnPreview(_ drop: SkiDrop) -> some View {
        let next = DawnScript.beats.first { !drop.isDawnDone($0.id) }
        return LiftPassCard {
            VStack(alignment: .leading, spacing: 10) {
                Text("Dawn script")
                    .font(.system(.headline, design: .rounded))
                    .foregroundColor(Color("AppInk"))
                if let next {
                    Text("\(next.whenLabel)  ·  \(next.title)")
                        .font(.system(.body, design: .rounded).weight(.semibold))
                        .foregroundColor(Color("AppAccent"))
                    Text(next.detail)
                        .font(.system(.caption, design: .rounded))
                        .foregroundColor(Color("AppInk").opacity(0.8))
                } else {
                    Text("Every beat is checked. Ride.")
                        .font(.system(.body, design: .rounded))
                        .foregroundColor(Color("AppInk"))
                }
            }
        }
    }

    private func upcomingList(excluding id: UUID) -> some View {
        let rest = store.upcoming.filter { $0.id != id }
        return Group {
            if !rest.isEmpty {
                VStack(alignment: .leading, spacing: 10) {
                    Text("On deck")
                        .font(.system(.headline, design: .rounded))
                        .foregroundColor(Color("AppInk"))
                    ForEach(rest) { drop in
                        Button {
                            store.setActive(id: drop.id)
                        } label: {
                            LiftPassCard {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(drop.title)
                                            .font(.system(.headline, design: .rounded))
                                            .foregroundColor(Color("AppInk"))
                                        Text(drop.countdownLabel)
                                            .font(.system(.caption, design: .rounded))
                                            .foregroundColor(Color("AppAccent"))
                                    }
                                    Spacer()
                                    Image(systemName: "arrow.right.circle.fill")
                                        .foregroundColor(Color("AppAccent"))
                                }
                            }
                        }
                        .buttonStyle(.plain)
                        .accessibilityIdentifier("selectDrop_\(drop.id.uuidString)")
                    }
                }
            }
        }
    }

    private func chip(_ text: String, symbol: String) -> some View {
        HStack(spacing: 4) {
            Image(systemName: symbol)
            Text(text)
        }
        .font(.system(.caption2, design: .rounded).weight(.semibold))
        .foregroundColor(Color("AppInk"))
        .padding(.horizontal, 8)
        .frame(minHeight: 28)
        .background(Color("AppBackground").opacity(0.7))
        .clipShape(Capsule())
    }
}
