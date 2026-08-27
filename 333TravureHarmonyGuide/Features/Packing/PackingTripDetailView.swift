import SwiftUI

struct PackingTripDetailView: View {
    @EnvironmentObject private var store: AppStore
    let tripId: UUID

    @State private var showItemEditor = false
    @State private var editingItem: PackingItem?
    @State private var pendingItem: PackingItem?
    @State private var confirmItemDelete = false
    @State private var confirmTripDelete = false
    @State private var titleDraft = ""
    @State private var titleError: String?

    var body: some View {
        Group {
            if let trip = store.trip(id: tripId) {
                detail(trip)
            } else {
                JournalEmptyState(symbol: "suitcase", message: "This packing list is no longer available.")
                    .journalCanvas()
            }
        }
    }

    private func detail(_ trip: PackingTrip) -> some View {
        List {
            Section {
                TicketStubCard {
                    VStack(alignment: .leading, spacing: 12) {
                        JournalField(
                            title: "List title",
                            identifier: "tripTitleField",
                            text: $titleDraft,
                            placeholder: "Trip essentials"
                        )
                        if let titleError {
                            InlineErrorText(message: titleError)
                        }
                        JournalPrimaryButton(
                            title: "Save title",
                            systemImage: "checkmark.circle.fill",
                            identifier: "saveTripTitleButton"
                        ) {
                            let trimmed = titleDraft.trimmingCharacters(in: .whitespacesAndNewlines)
                            if trimmed.isEmpty {
                                titleError = "Name is required"
                                return
                            }
                            titleError = nil
                            store.updateTripTitle(id: trip.id, title: trimmed)
                            Haptics.success()
                        }

                        HStack {
                            PassportStamp(symbol: "checkmark.circle", caption: "Packed", rotation: -8)
                            VStack(alignment: .leading, spacing: 4) {
                                Text("\(trip.packedCount) of \(trip.items.count) packed")
                                    .font(.system(.headline, design: .serif))
                                    .foregroundColor(Color("AppInk"))
                                ProgressView(value: trip.completion)
                                    .tint(Color("AppAccent"))
                                    .accessibilityIdentifier("tripPackingProgress")
                            }
                        }
                    }
                }
                .listRowInsets(EdgeInsets(top: 12, leading: 16, bottom: 8, trailing: 16))
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
            }

            if trip.items.isEmpty {
                Section {
                    TicketStubCard {
                        JournalEmptyState(
                            symbol: "suitcase.fill",
                            message: "No Essentials Yet! Start Adding Your Must-Haves."
                        )
                    }
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                }
            } else {
                ForEach(grouped(trip)) { group in
                    Section {
                        ForEach(group.items) { item in
                            itemRow(trip: trip, item: item)
                                .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                                .listRowBackground(Color.clear)
                                .listRowSeparator(.hidden)
                                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                    Button(role: .destructive) {
                                        pendingItem = item
                                        confirmItemDelete = true
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                    .accessibilityIdentifier("swipeDeleteItem_\(item.id.uuidString)")
                                }
                        }
                    } header: {
                        Text(group.category)
                            .font(.system(.subheadline, design: .serif).weight(.semibold))
                            .foregroundColor(Color("AppInk"))
                    }
                }
            }

            Section {
                Button {
                    confirmTripDelete = true
                } label: {
                    HStack {
                        Image(systemName: "trash")
                        Text("Delete packing list")
                    }
                    .font(.system(.headline, design: .serif))
                    .foregroundColor(Color("AppInk"))
                    .frame(maxWidth: .infinity, minHeight: Theme.tap)
                }
                .accessibilityIdentifier("deleteTripDetailButton")
                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 24, trailing: 16))
                .listRowBackground(Color.clear)
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .journalCanvas()
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Essentials")
                    .font(.system(.headline, design: .serif))
                    .accessibilityIdentifier("packingDetailTitle")
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    editingItem = nil
                    showItemEditor = true
                } label: {
                    Image(systemName: "plus")
                        .frame(minWidth: Theme.tap, minHeight: Theme.tap)
                }
                .accessibilityIdentifier("addPackingItemButton")
                .accessibilityLabel("Add item")
            }
        }
        .onAppear {
            titleDraft = trip.title
        }
        .sheet(isPresented: $showItemEditor) {
            PackingItemEditorView(tripId: tripId, existing: editingItem)
                .environmentObject(store)
        }
        .confirmationDialog("Delete this item?", isPresented: $confirmItemDelete, titleVisibility: .visible) {
            Button("Delete Item", role: .destructive) {
                if let pendingItem {
                    store.deleteItem(tripId: tripId, itemId: pendingItem.id)
                }
                pendingItem = nil
            }
            .accessibilityIdentifier("confirmDeleteItemButton")
            Button("Cancel", role: .cancel) { pendingItem = nil }
                .accessibilityIdentifier("cancelDeleteItemButton")
        }
        .confirmationDialog("Delete this packing list?", isPresented: $confirmTripDelete, titleVisibility: .visible) {
            Button("Delete List", role: .destructive) {
                store.deleteTrip(id: tripId)
            }
            .accessibilityIdentifier("confirmDeleteTripDetailButton")
            Button("Cancel", role: .cancel) {}
                .accessibilityIdentifier("cancelDeleteTripDetailButton")
        } message: {
            Text("All packed and unpacked items on this list will be removed.")
        }
    }

    private func itemRow(trip: PackingTrip, item: PackingItem) -> some View {
        TicketStubCard {
            HStack(spacing: 10) {
                Button {
                    store.togglePacked(tripId: trip.id, itemId: item.id)
                } label: {
                    Image(systemName: item.packed ? "checkmark.circle.fill" : "circle")
                        .font(.title3)
                        .foregroundColor(item.packed ? Color("AppAccent") : Color("AppInk"))
                        .frame(width: Theme.tap, height: Theme.tap)
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("togglePacked_\(item.id.uuidString)")
                .accessibilityLabel(item.packed ? "Mark unpacked" : "Mark packed")

                VStack(alignment: .leading, spacing: 2) {
                    Text(item.name)
                        .font(.system(.body, design: .serif))
                        .foregroundColor(Color("AppInk"))
                        .strikethrough(item.packed, color: Color("AppAccent"))
                    Text(item.category)
                        .font(.system(.caption, design: .serif))
                        .foregroundColor(Color("AppAccent"))
                }
                Spacer()
                JournalIconButton(systemImage: "pencil", identifier: "editItem_\(item.id.uuidString)") {
                    editingItem = item
                    showItemEditor = true
                }
                JournalIconButton(systemImage: "trash", identifier: "deleteItemOnscreen_\(item.id.uuidString)") {
                    pendingItem = item
                    confirmItemDelete = true
                }
            }
        }
    }

    private func grouped(_ trip: PackingTrip) -> [PackingCategoryGroup] {
        var buckets: [String: [PackingItem]] = [:]
        for item in trip.items {
            buckets[item.category, default: []].append(item)
        }
        let extra = buckets.keys.filter { !store.categoryOrder.contains($0) }.sorted()
        let order = store.categoryOrder + extra
        return order.compactMap { category in
            guard let items = buckets[category], !items.isEmpty else { return nil }
            return PackingCategoryGroup(id: category, category: category, items: items)
        }
    }
}

private struct PackingCategoryGroup: Identifiable {
    let id: String
    let category: String
    let items: [PackingItem]
}
