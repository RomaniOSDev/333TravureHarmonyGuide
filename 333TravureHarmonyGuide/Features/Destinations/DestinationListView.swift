import SwiftUI

enum DestinationStatusFilter: String, CaseIterable, Identifiable {
    case all = "All"
    case planned = "Planned"
    case visited = "Visited"

    var id: String { rawValue }
}

struct DestinationListView: View {
    @EnvironmentObject private var store: AppStore
    @State private var showEditor = false
    @State private var pendingDelete: Destination?
    @State private var confirmDelete = false
    @State private var searchText = ""
    @State private var statusFilter: DestinationStatusFilter = .all
    @State private var climateFilter: String = "Any"
    @State private var spunDestination: Destination?
    @State private var showNoPlanned = false

    private var filteredDestinations: [Destination] {
        store.destinations.filter { destination in
            switch statusFilter {
            case .all: break
            case .planned: if destination.visited { return false }
            case .visited: if !destination.visited { return false }
            }
            if climateFilter != "Any", destination.climate != climateFilter {
                return false
            }
            let needle = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !needle.isEmpty else { return true }
            return destination.name.localizedCaseInsensitiveContains(needle)
                || destination.country.localizedCaseInsensitiveContains(needle)
                || destination.regionCode.localizedCaseInsensitiveContains(needle)
                || destination.climate.localizedCaseInsensitiveContains(needle)
        }
    }

    var body: some View {
        Group {
            if store.destinations.isEmpty {
                emptyState
            } else {
                listContent
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showEditor = true
                } label: {
                    Image(systemName: "plus")
                        .foregroundColor(Color("AppInk"))
                        .frame(minWidth: Theme.tap, minHeight: Theme.tap)
                }
                .accessibilityIdentifier("addDestinationToolbarButton")
                .accessibilityLabel("Add destination")
            }
        }
        .sheet(isPresented: $showEditor) {
            DestinationEditorView(existing: nil)
                .environmentObject(store)
        }
        .sheet(item: $spunDestination) { destination in
            WhereNextSheet(destination: destination) {
                spunDestination = nil
            }
            .environmentObject(store)
        }
        .alert("No planned trips", isPresented: $showNoPlanned) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Add a planned destination first, then spin the compass.")
        }
        .confirmationDialog(
            "Remove this destination?",
            isPresented: $confirmDelete,
            titleVisibility: .visible
        ) {
            Button("Delete Destination", role: .destructive) {
                if let pendingDelete {
                    store.deleteDestination(id: pendingDelete.id)
                }
                pendingDelete = nil
            }
            .accessibilityIdentifier("confirmDeleteDestinationButton")
            Button("Cancel", role: .cancel) {
                pendingDelete = nil
            }
            .accessibilityIdentifier("cancelDeleteDestinationButton")
        } message: {
            Text("Notes and points of interest for this spot will also be removed.")
        }
    }

    private var emptyState: some View {
        ScrollView {
            VStack(spacing: 18) {
                JournalBanner(imageName: "bannerMap")
                TicketStubCard {
                    JournalEmptyState(
                        symbol: "globe.desk.fill",
                        message: "Tap the '+' icon to add your first dream travel spot!"
                    )
                }
                JournalPrimaryButton(
                    title: "Add destination",
                    systemImage: "plus.circle.fill",
                    identifier: "addDestinationButton"
                ) {
                    showEditor = true
                }
            }
            .padding(16)
        }
    }

    private var listContent: some View {
        List {
            Section {
                JournalBanner(imageName: "bannerMap")
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
            }

            Section {
                filterCard
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
            }

            if filteredDestinations.isEmpty {
                Section {
                    TicketStubCard {
                        JournalEmptyState(
                            symbol: "line.3.horizontal.decrease.circle",
                            message: "Nothing matches these filters. Clear search or switch status."
                        )
                    }
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                }
            }

            ForEach(filteredDestinations) { destination in
                ZStack {
                    NavigationLink {
                        DestinationDetailView(destinationId: destination.id)
                    } label: {
                        EmptyView()
                    }
                    .opacity(0)
                    .accessibilityIdentifier("destinationRow_\(destination.id.uuidString)")

                    DestinationTicketRow(
                        destination: destination,
                        onDelete: {
                            pendingDelete = destination
                            confirmDelete = true
                        }
                    )
                }
                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    Button(role: .destructive) {
                        pendingDelete = destination
                        confirmDelete = true
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                    .accessibilityIdentifier("swipeDeleteDestination_\(destination.id.uuidString)")
                }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .searchable(text: $searchText, prompt: "Search places, countries, climate")
        .accessibilityIdentifier("destinationList")
    }

    private var filterCard: some View {
        TicketStubCard {
            VStack(alignment: .leading, spacing: 12) {
                Picker("Status", selection: $statusFilter) {
                    ForEach(DestinationStatusFilter.allCases) { item in
                        Text(item.rawValue).tag(item)
                    }
                }
                .pickerStyle(.segmented)
                .accessibilityIdentifier("destinationStatusFilter")

                HStack {
                    Text("Climate")
                        .font(.system(.caption, design: .serif))
                        .foregroundColor(Color("AppInk").opacity(0.85))
                    Spacer()
                    Picker("Climate", selection: $climateFilter) {
                        Text("Any").tag("Any")
                        ForEach(ClimateKind.allCases) { kind in
                            Text(kind.rawValue).tag(kind.rawValue)
                        }
                    }
                    .pickerStyle(.menu)
                    .tint(Color("AppInk"))
                    .accessibilityIdentifier("destinationClimateFilter")
                }

                JournalPrimaryButton(
                    title: "Where next?",
                    systemImage: "sparkles",
                    identifier: "whereNextButton"
                ) {
                    spinNext()
                }
            }
        }
    }

    private func spinNext() {
        let pool = store.plannedDestinations()
        guard let pick = pool.randomElement() else {
            showNoPlanned = true
            return
        }
        Haptics.success()
        spunDestination = pick
    }
}

private struct DestinationTicketRow: View {
    let destination: Destination
    let onDelete: () -> Void

    var body: some View {
        TicketStubCard {
            HStack(alignment: .center, spacing: 12) {
                if let name = destination.coverPhotoName, let image = JournalPhotos.image(named: name) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 76, height: 76)
                        .clipShape(Circle())
                        .overlay {
                            Circle()
                                .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [3, 2]))
                                .foregroundColor(Color("AppAccent"))
                        }
                } else {
                    PassportStamp(
                        symbol: destination.visited ? "checkmark.seal.fill" : "airplane",
                        caption: destination.visited ? "Visited" : "Planned",
                        rotation: destination.visited ? 6 : -8
                    )
                }
                VStack(alignment: .leading, spacing: 6) {
                    Text(destination.name)
                        .font(.system(.headline, design: .serif))
                        .foregroundColor(Color("AppInk"))
                    Text(destination.country.isEmpty ? "Open itinerary" : destination.country)
                        .font(.system(.subheadline, design: .serif))
                        .foregroundColor(Color("AppInk").opacity(0.78))
                    HStack(spacing: 8) {
                        Label(destination.climate, systemImage: destination.climateKind.symbol)
                        if let countdown = destination.countdownLabel {
                            Label(countdown, systemImage: "hourglass")
                        } else if let plannedDate = destination.plannedDate {
                            Label(plannedDate.formatted(date: .abbreviated, time: .omitted), systemImage: "calendar")
                        }
                    }
                    .font(.system(.caption, design: .serif))
                    .foregroundColor(Color("AppAccent"))
                }
                Spacer(minLength: 0)
                JournalIconButton(systemImage: "trash", identifier: "deleteDestinationOnscreen_\(destination.id.uuidString)", action: onDelete)
            }
        }
    }
}

private struct WhereNextSheet: View {
    @EnvironmentObject private var store: AppStore
    let destination: Destination
    var onClose: () -> Void

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    TicketStubCard {
                        VStack(spacing: 12) {
                            PassportStamp(symbol: "sparkles", caption: "Next?", rotation: -8)
                            Text(destination.name)
                                .font(.system(.title2, design: .serif).weight(.semibold))
                                .foregroundColor(Color("AppInk"))
                            Text(destination.country.isEmpty ? destination.climate : "\(destination.country) · \(destination.climate)")
                                .font(.system(.body, design: .serif))
                                .foregroundColor(Color("AppInk").opacity(0.78))
                            if let countdown = destination.countdownLabel {
                                Text(countdown)
                                    .font(.system(.caption, design: .serif))
                                    .foregroundColor(Color("AppAccent"))
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                    NavigationLink {
                        DestinationDetailView(destinationId: destination.id)
                    } label: {
                        HStack {
                            Image(systemName: "safari.fill")
                            Text("Open passport page")
                                .font(.system(.headline, design: .serif))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, minHeight: Theme.tap)
                        .background {
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(
                                    LinearGradient(
                                        colors: [Color("AppPrimary"), Color("AppAccent")],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                        }
                    }
                    .accessibilityIdentifier("openSpunDestinationButton")
                }
                .padding(16)
            }
            .journalCanvas()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Where next?")
                        .font(.system(.headline, design: .serif))
                        .foregroundColor(Color("AppInk"))
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { onClose() }
                        .frame(minHeight: Theme.tap)
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}
