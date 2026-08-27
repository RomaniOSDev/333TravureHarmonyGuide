import SwiftUI

struct PackingItemEditorView: View {
    @EnvironmentObject private var store: AppStore
    @Environment(\.dismiss) private var dismiss

    let tripId: UUID
    let existing: PackingItem?

    @State private var name = ""
    @State private var category = "Gadgets"
    @State private var customCategory = ""
    @State private var packed = false
    @State private var nameError: String?

    private var categories: [String] {
        var list = store.categoryOrder
        if !list.contains("Other") {
            list.append("Other")
        }
        if !list.contains(category) && !category.isEmpty && category != "Custom" {
            list.append(category)
        }
        return list
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    TicketStubCard {
                        VStack(spacing: 14) {
                            JournalField(
                                title: "Item name",
                                identifier: "packingItemNameField",
                                text: $name,
                                placeholder: "Passport holder"
                            )
                            if let nameError {
                                InlineErrorText(message: nameError)
                            }

                            VStack(alignment: .leading, spacing: 6) {
                                Text("Category")
                                    .font(.system(.caption, design: .serif))
                                    .foregroundColor(Color("AppInk").opacity(0.85))
                                Picker("Category", selection: $category) {
                                    ForEach(categories, id: \.self) { item in
                                        Text(item).tag(item)
                                    }
                                    Text("Custom").tag("Custom")
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
                                .accessibilityIdentifier("packingItemCategoryPicker")
                            }

                            if category == "Custom" {
                                JournalField(
                                    title: "Custom category",
                                    identifier: "packingItemCustomCategoryField",
                                    text: $customCategory,
                                    placeholder: "Documents"
                                )
                            }

                            Toggle(isOn: $packed) {
                                Text("Already packed")
                                    .font(.system(.body, design: .serif))
                                    .foregroundColor(Color("AppInk"))
                            }
                            .frame(minHeight: Theme.tap)
                            .tint(Color("AppAccent"))
                            .accessibilityIdentifier("packingItemPackedToggle")
                        }
                    }

                    JournalPrimaryButton(
                        title: existing == nil ? "Add item" : "Save item",
                        systemImage: "checkmark.circle.fill",
                        identifier: "savePackingItemButton"
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
                    Text(existing == nil ? "New essential" : "Edit essential")
                        .font(.system(.headline, design: .serif))
                        .accessibilityIdentifier("packingItemEditorTitle")
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .frame(minHeight: Theme.tap)
                        .accessibilityIdentifier("cancelPackingItemEditorButton")
                }
            }
            .onAppear(perform: hydrate)
        }
    }

    private func hydrate() {
        guard let existing else {
            category = store.categoryOrder.first ?? "Gadgets"
            return
        }
        name = existing.name
        category = existing.category
        packed = existing.packed
    }

    private func save() {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            nameError = "Name is required"
            Haptics.warning()
            return
        }
        let resolvedCategory: String
        if category == "Custom" {
            let custom = customCategory.trimmingCharacters(in: .whitespacesAndNewlines)
            resolvedCategory = custom.isEmpty ? "Other" : custom
        } else {
            resolvedCategory = category
        }

        if store.duplicateItemName(in: tripId, name: trimmed, excluding: existing?.id) {
            nameError = "That item is already on this list"
            Haptics.warning()
            return
        }
        nameError = nil

        if var existing {
            existing.name = trimmed
            existing.category = resolvedCategory
            existing.packed = packed
            if store.updateItem(tripId: tripId, item: existing) {
                Haptics.success()
                dismiss()
            } else {
                nameError = "That item is already on this list"
            }
        } else {
            if store.addItem(tripId: tripId, name: trimmed, category: resolvedCategory) {
                if packed, let trip = store.trip(id: tripId), let added = trip.items.last {
                    if !added.packed {
                        store.togglePacked(tripId: tripId, itemId: added.id)
                    }
                }
                Haptics.success()
                dismiss()
            } else {
                nameError = "That item is already on this list"
            }
        }
    }
}
