import SwiftUI

struct PackingTripListView: View {
    @EnvironmentObject private var store: AppStore
    @State private var showNewTrip = false
    @State private var newTitle = ""
    @State private var template: PackingTemplate = .blank
    @State private var titleError: String?
    @State private var pendingDelete: PackingTrip?
    @State private var confirmDelete = false

    var body: some View {
        Group {
            if store.tripEssentials.isEmpty {
                emptyState
            } else {
                listContent
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showNewTrip = true
                    titleError = nil
                    newTitle = ""
                    template = .blank
                } label: {
                    Image(systemName: "plus")
                        .foregroundColor(Color("AppInk"))
                        .frame(minWidth: Theme.tap, minHeight: Theme.tap)
                }
                .accessibilityIdentifier("addPackingTripToolbarButton")
                .accessibilityLabel("Add packing list")
            }
        }
        .sheet(isPresented: $showNewTrip) {
            newTripSheet
        }
        .confirmationDialog(
            "Delete this packing list?",
            isPresented: $confirmDelete,
            titleVisibility: .visible
        ) {
            Button("Delete List", role: .destructive) {
                if let pendingDelete {
                    store.deleteTrip(id: pendingDelete.id)
                }
                pendingDelete = nil
            }
            .accessibilityIdentifier("confirmDeleteTripButton")
            Button("Cancel", role: .cancel) { pendingDelete = nil }
                .accessibilityIdentifier("cancelDeleteTripButton")
        } message: {
            Text("All packed and unpacked items on this list will be removed.")
        }
    }

    private var emptyState: some View {
        ScrollView {
            VStack(spacing: 18) {
                JournalBanner(imageName: "bannerPack")
                TicketStubCard {
                    JournalEmptyState(
                        symbol: "suitcase.fill",
                        message: "No Essentials Yet! Start Adding Your Must-Haves."
                    )
                }
                JournalPrimaryButton(
                    title: "Start a packing list",
                    systemImage: "plus.circle.fill",
                    identifier: "addPackingTripButton"
                ) {
                    showNewTrip = true
                    titleError = nil
                    newTitle = ""
                    template = .blank
                }
            }
            .padding(16)
        }
    }

    private var listContent: some View {
        List {
            Section {
                JournalBanner(imageName: "bannerPack")
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
            }

            ForEach(store.tripEssentials) { trip in
                ZStack {
                    NavigationLink {
                        PackingTripDetailView(tripId: trip.id)
                    } label: {
                        EmptyView()
                    }
                    .opacity(0)
                    .accessibilityIdentifier("packingTripRow_\(trip.id.uuidString)")

                    TicketStubCard {
                        HStack(spacing: 12) {
                            PassportStamp(
                                symbol: "suitcase.fill",
                                caption: "\(Int((trip.completion * 100).rounded()))%",
                                rotation: -6
                            )
                            VStack(alignment: .leading, spacing: 6) {
                                Text(trip.title)
                                    .font(.system(.headline, design: .serif))
                                    .foregroundColor(Color("AppInk"))
                                Text("\(trip.packedCount) of \(trip.items.count) packed")
                                    .font(.system(.caption, design: .serif))
                                    .foregroundColor(Color("AppAccent"))
                                if let destinationId = trip.destinationId,
                                   let destination = store.destination(id: destinationId) {
                                    Text(destination.country.isEmpty ? destination.name : "\(destination.name), \(destination.country)")
                                        .font(.system(.caption, design: .serif))
                                        .foregroundColor(Color("AppInk").opacity(0.75))
                                }
                            }
                            Spacer(minLength: 0)
                            JournalIconButton(
                                systemImage: "plus.square.on.square",
                                identifier: "duplicateTripOnscreen_\(trip.id.uuidString)"
                            ) {
                                store.duplicateTrip(id: trip.id)
                                Haptics.success()
                            }
                            JournalIconButton(
                                systemImage: "trash",
                                identifier: "deleteTripOnscreen_\(trip.id.uuidString)"
                            ) {
                                pendingDelete = trip
                                confirmDelete = true
                            }
                        }
                    }
                }
                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
                .swipeActions(edge: .leading, allowsFullSwipe: false) {
                    Button {
                        store.duplicateTrip(id: trip.id)
                        Haptics.success()
                    } label: {
                        Label("Copy", systemImage: "plus.square.on.square")
                    }
                    .tint(Color("AppAccent"))
                    .accessibilityIdentifier("swipeDuplicateTrip_\(trip.id.uuidString)")
                }
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    Button(role: .destructive) {
                        pendingDelete = trip
                        confirmDelete = true
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                    .accessibilityIdentifier("swipeDeleteTrip_\(trip.id.uuidString)")
                }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .accessibilityIdentifier("packingTripList")
    }

    private var newTripSheet: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    TicketStubCard {
                        VStack(alignment: .leading, spacing: 10) {
                            JournalField(
                                title: "List title",
                                identifier: "newTripTitleField",
                                text: $newTitle,
                                placeholder: "Weekend in Lisbon"
                            )
                            if let titleError {
                                InlineErrorText(message: titleError)
                            }
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Template")
                                    .font(.system(.caption, design: .serif))
                                    .foregroundColor(Color("AppInk").opacity(0.85))
                                Picker("Template", selection: $template) {
                                    ForEach(PackingTemplate.allCases) { item in
                                        Text(item.rawValue).tag(item)
                                    }
                                }
                                .pickerStyle(.menu)
                                .tint(Color("AppInk"))
                                .frame(maxWidth: .infinity, minHeight: Theme.tap, alignment: .leading)
                                .accessibilityIdentifier("packingTemplatePicker")
                            }
                        }
                    }
                    JournalPrimaryButton(
                        title: "Create packing list",
                        systemImage: "checkmark.circle.fill",
                        identifier: "saveNewTripButton"
                    ) {
                        let trimmed = newTitle.trimmingCharacters(in: .whitespacesAndNewlines)
                        if trimmed.isEmpty {
                            titleError = "Name is required"
                            Haptics.warning()
                            return
                        }
                        titleError = nil
                        store.addTrip(title: trimmed, items: template.items)
                        Haptics.success()
                        showNewTrip = false
                    }
                }
                .padding(16)
            }
            .journalCanvas()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("New packing list")
                        .font(.system(.headline, design: .serif))
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { showNewTrip = false }
                        .frame(minHeight: Theme.tap)
                        .accessibilityIdentifier("cancelNewTripButton")
                }
            }
        }
        .environmentObject(store)
    }
}
