import PhotosUI
import SwiftUI
import UniformTypeIdentifiers

private struct JournalImageData: Transferable {
    let data: Data

    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(importedContentType: .image) { data in
            JournalImageData(data: data)
        }
    }
}

struct DestinationDetailView: View {
    @EnvironmentObject private var store: AppStore
    let destinationId: UUID

    @State private var showEditor = false
    @State private var noteText = ""
    @State private var assignNoteDay = true
    @State private var noteDay = Date()
    @State private var poiTitle = ""
    @State private var poiKind = PointOfInterest.kinds[0]
    @State private var poiSlot = DaySlot.anytime.rawValue
    @State private var pendingNote: TravelNote?
    @State private var pendingPoint: PointOfInterest?
    @State private var pendingDocument: TripDocument?
    @State private var confirmNoteDelete = false
    @State private var confirmPointDelete = false
    @State private var confirmDocumentDelete = false
    @State private var confirmDestinationDelete = false
    @State private var noteError: String?
    @State private var poiError: String?
    @State private var documentError: String?
    @State private var documentKind = TripDocument.kinds[0]
    @State private var documentTitle = ""
    @State private var documentHasExpiry = false
    @State private var documentExpiry = Date()
    @State private var photoItem: PhotosPickerItem?

    var body: some View {
        Group {
            if let destination = store.destination(id: destinationId) {
                detail(destination)
            } else {
                JournalEmptyState(symbol: "map", message: "This destination is no longer in your journal.")
                    .journalCanvas()
            }
        }
    }

    private func detail(_ destination: Destination) -> some View {
        ScrollView {
            VStack(spacing: 16) {
                coverCard(destination)
                headerCard(destination)

                JournalPrimaryButton(
                    title: destination.visited ? "Mark as planned" : "Mark as visited",
                    systemImage: destination.visited ? "arrow.uturn.backward.circle.fill" : "checkmark.seal.fill",
                    identifier: "markVisitedButton"
                ) {
                    store.setVisited(id: destination.id, visited: !destination.visited)
                }

                seasonalCard(destination)

                if let trip = store.trip(forDestination: destination.id) {
                    packingLink(trip)
                }

                notesCard(destination)
                poiCard(destination)
                documentsCard(destination)

                Button {
                    confirmDestinationDelete = true
                } label: {
                    HStack {
                        Image(systemName: "trash")
                        Text("Delete destination")
                    }
                    .font(.system(.headline, design: .serif))
                    .foregroundColor(Color("AppInk"))
                    .frame(maxWidth: .infinity, minHeight: Theme.tap)
                    .overlay {
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .strokeBorder(style: StrokeStyle(lineWidth: 1.4, dash: [6, 4]))
                            .foregroundColor(Color("AppAccent"))
                    }
                }
                .accessibilityIdentifier("deleteDestinationDetailButton")
                .journalTapTarget()
            }
            .padding(16)
        }
        .journalCanvas()
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Passport page")
                    .font(.system(.headline, design: .serif))
                    .accessibilityIdentifier("destinationDetailTitle")
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Edit") { showEditor = true }
                    .frame(minHeight: Theme.tap)
                    .accessibilityIdentifier("editDestinationButton")
            }
        }
        .sheet(isPresented: $showEditor) {
            DestinationEditorView(existing: destination)
                .environmentObject(store)
        }
        .onChange(of: photoItem) { newValue in
            Task {
                guard let newValue, let loaded = try? await newValue.loadTransferable(type: JournalImageData.self) else { return }
                store.setCoverPhoto(destinationId: destination.id, data: loaded.data)
            }
        }
        .confirmationDialog("Delete this note?", isPresented: $confirmNoteDelete, titleVisibility: .visible) {
            Button("Delete Note", role: .destructive) {
                if let pendingNote {
                    store.deleteNote(id: pendingNote.id)
                }
                pendingNote = nil
            }
            .accessibilityIdentifier("confirmDeleteNoteButton")
            Button("Cancel", role: .cancel) { pendingNote = nil }
                .accessibilityIdentifier("cancelDeleteNoteButton")
        }
        .confirmationDialog("Delete this point of interest?", isPresented: $confirmPointDelete, titleVisibility: .visible) {
            Button("Delete Point", role: .destructive) {
                if let pendingPoint {
                    store.deletePoint(id: pendingPoint.id)
                }
                pendingPoint = nil
            }
            .accessibilityIdentifier("confirmDeletePointButton")
            Button("Cancel", role: .cancel) { pendingPoint = nil }
                .accessibilityIdentifier("cancelDeletePointButton")
        }
        .confirmationDialog("Delete this document?", isPresented: $confirmDocumentDelete, titleVisibility: .visible) {
            Button("Delete Document", role: .destructive) {
                if let pendingDocument {
                    store.deleteDocument(id: pendingDocument.id)
                }
                pendingDocument = nil
            }
            Button("Cancel", role: .cancel) { pendingDocument = nil }
        }
        .confirmationDialog("Remove this destination?", isPresented: $confirmDestinationDelete, titleVisibility: .visible) {
            Button("Delete Destination", role: .destructive) {
                store.deleteDestination(id: destination.id)
            }
            .accessibilityIdentifier("confirmDeleteDestinationDetailButton")
            Button("Cancel", role: .cancel) {}
                .accessibilityIdentifier("cancelDeleteDestinationDetailButton")
        } message: {
            Text("Notes and points of interest for this spot will also be removed.")
        }
    }

    private func coverCard(_ destination: Destination) -> some View {
        TicketStubCard {
            VStack(alignment: .leading, spacing: 12) {
                if let name = destination.coverPhotoName, let image = JournalPhotos.image(named: name) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity)
                        .frame(height: 180)
                        .clipped()
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                } else {
                    JournalEmptyState(symbol: "camera.fill", message: "Add a cover photo from your library.")
                }
                HStack {
                    PhotosPicker(selection: $photoItem, matching: .images) {
                        Label(destination.coverPhotoName == nil ? "Add cover photo" : "Change photo", systemImage: "photo")
                            .font(.system(.headline, design: .serif))
                            .foregroundColor(Color("AppInk"))
                            .frame(maxWidth: .infinity, minHeight: Theme.tap)
                    }
                    .accessibilityIdentifier("pickCoverPhotoButton")
                    if destination.coverPhotoName != nil {
                        JournalIconButton(systemImage: "trash", identifier: "clearCoverPhotoButton") {
                            store.clearCoverPhoto(destinationId: destination.id)
                        }
                    }
                }
            }
        }
    }

    private func headerCard(_ destination: Destination) -> some View {
        TicketStubCard {
            HStack(alignment: .top, spacing: 12) {
                PassportStamp(
                    symbol: destination.visited ? "checkmark.seal.fill" : "compass.drawing",
                    caption: destination.climate,
                    rotation: -10
                )
                VStack(alignment: .leading, spacing: 8) {
                    Text(destination.name)
                        .font(.system(.title2, design: .serif).weight(.semibold))
                        .foregroundColor(Color("AppInk"))
                    Text(destination.country.isEmpty ? "Country not set" : destination.country)
                        .font(.system(.body, design: .serif))
                        .foregroundColor(Color("AppInk").opacity(0.78))
                    Text("Region \(destination.regionCode.isEmpty ? "—" : destination.regionCode)")
                        .font(.system(.caption, design: .serif))
                        .foregroundColor(Color("AppAccent"))
                    if let plannedDate = destination.plannedDate {
                        Label(plannedDate.formatted(date: .long, time: .omitted), systemImage: "calendar")
                            .font(.system(.caption, design: .serif))
                            .foregroundColor(Color("AppInk"))
                    }
                    if let countdown = destination.countdownLabel {
                        Label(countdown, systemImage: "hourglass")
                            .font(.system(.headline, design: .serif))
                            .foregroundColor(Color("AppAccent"))
                            .accessibilityIdentifier("countdownLabel")
                    }
                    Label("Local time \(destination.localTimeLabel)", systemImage: "clock")
                        .font(.system(.caption, design: .serif))
                        .foregroundColor(Color("AppInk"))
                        .accessibilityIdentifier("localTimeLabel")
                }
                Spacer(minLength: 0)
            }
        }
    }

    private func seasonalCard(_ destination: Destination) -> some View {
        TicketStubCard {
            VStack(alignment: .leading, spacing: 8) {
                Text("Season tips")
                    .font(.system(.headline, design: .serif))
                    .foregroundColor(Color("AppInk"))
                Text(destination.seasonalTip)
                    .font(.system(.body, design: .serif))
                    .foregroundColor(Color("AppInk").opacity(0.85))
                    .accessibilityIdentifier("seasonalTipLabel")
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func packingLink(_ trip: PackingTrip) -> some View {
        NavigationLink {
            PackingTripDetailView(tripId: trip.id)
        } label: {
            HStack {
                Image(systemName: "suitcase.fill")
                Text("Open packing list")
                    .font(.system(.headline, design: .serif))
                Spacer()
                Text("\(Int((trip.completion * 100).rounded()))%")
                    .font(.system(.caption, design: .serif))
            }
            .foregroundColor(.white)
            .padding(.horizontal, 16)
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
                    .shadow(color: Color("AppPrimary").opacity(0.28), radius: 6, y: 3)
            }
        }
        .accessibilityIdentifier("openLinkedPackingButton")
        .journalTapTarget()
    }

    private func notesCard(_ destination: Destination) -> some View {
        TicketStubCard {
            VStack(alignment: .leading, spacing: 12) {
                Text("Day journal")
                    .font(.system(.headline, design: .serif))
                    .foregroundColor(Color("AppInk"))

                TextField("A postcard thought…", text: $noteText, axis: .vertical)
                    .lineLimit(2...4)
                    .foregroundColor(Color("AppInk"))
                    .padding(10)
                    .frame(minHeight: Theme.tap)
                    .background(Color("AppBackground").opacity(0.7))
                    .overlay {
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [5, 3]))
                            .foregroundColor(Color("AppAccent").opacity(0.55))
                    }
                    .accessibilityIdentifier("noteTextField")

                Toggle(isOn: $assignNoteDay) {
                    Text("Tie to a day")
                        .font(.system(.body, design: .serif))
                        .foregroundColor(Color("AppInk"))
                }
                .tint(Color("AppAccent"))
                .accessibilityIdentifier("noteDayToggle")

                if assignNoteDay {
                    DatePicker("Journal day", selection: $noteDay, displayedComponents: .date)
                        .datePickerStyle(.compact)
                        .tint(Color("AppAccent"))
                        .accessibilityIdentifier("noteDayPicker")
                }

                JournalPrimaryButton(
                    title: "Add journal entry",
                    systemImage: "square.and.pencil",
                    identifier: "addNoteButton"
                ) {
                    addNote(destinationId: destination.id)
                }

                if let noteError {
                    InlineErrorText(message: noteError)
                }

                let groups = store.groupedNotes(for: destination.id)
                if groups.isEmpty {
                    Text("No notes yet — jot a café, a street, a sunrise.")
                        .font(.system(.caption, design: .serif))
                        .foregroundColor(Color("AppInk").opacity(0.75))
                } else {
                    ForEach(groups) { group in
                        VStack(alignment: .leading, spacing: 8) {
                            Text(group.day?.formatted(date: .abbreviated, time: .omitted) ?? "Loose notes")
                                .font(.system(.caption, design: .serif).weight(.semibold))
                                .foregroundColor(Color("AppAccent"))
                            ForEach(group.notes) { note in
                                HStack(alignment: .top) {
                                    Text(note.text)
                                        .font(.system(.body, design: .serif))
                                        .foregroundColor(Color("AppInk"))
                                    Spacer()
                                    JournalIconButton(systemImage: "trash", identifier: "deleteNoteOnscreen_\(note.id.uuidString)") {
                                        pendingNote = note
                                        confirmNoteDelete = true
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    private func poiCard(_ destination: Destination) -> some View {
        TicketStubCard {
            VStack(alignment: .leading, spacing: 12) {
                Text("Day itinerary")
                    .font(.system(.headline, design: .serif))
                    .foregroundColor(Color("AppInk"))

                JournalField(
                    title: "Place title",
                    identifier: "poiTitleField",
                    text: $poiTitle,
                    placeholder: "Fushimi Inari"
                )
                Picker("Kind", selection: $poiKind) {
                    ForEach(PointOfInterest.kinds, id: \.self) { kind in
                        Text(kind).tag(kind)
                    }
                }
                .pickerStyle(.menu)
                .tint(Color("AppInk"))
                .frame(maxWidth: .infinity, minHeight: Theme.tap, alignment: .leading)
                .accessibilityIdentifier("poiKindPicker")

                Picker("Part of day", selection: $poiSlot) {
                    ForEach(DaySlot.allCases) { slot in
                        Text(slot.rawValue).tag(slot.rawValue)
                    }
                }
                .pickerStyle(.segmented)
                .accessibilityIdentifier("poiSlotPicker")

                JournalPrimaryButton(
                    title: "Add to itinerary",
                    systemImage: "mappin.circle.fill",
                    identifier: "addPoiButton"
                ) {
                    addPoint(destinationId: destination.id)
                }

                if let poiError {
                    InlineErrorText(message: poiError)
                }

                let groups = store.itinerary(for: destination.id)
                if groups.isEmpty {
                    Text("Pin markets, temples, stations, and harbors — then order the day.")
                        .font(.system(.caption, design: .serif))
                        .foregroundColor(Color("AppInk").opacity(0.75))
                } else {
                    ForEach(groups) { group in
                        VStack(alignment: .leading, spacing: 8) {
                            Text(group.slot.rawValue)
                                .font(.system(.caption, design: .serif).weight(.semibold))
                                .foregroundColor(Color("AppAccent"))
                            ForEach(group.points) { point in
                                HStack(alignment: .top, spacing: 8) {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(point.title)
                                            .font(.system(.body, design: .serif))
                                            .foregroundColor(Color("AppInk"))
                                        Text(point.kind)
                                            .font(.system(.caption, design: .serif))
                                            .foregroundColor(Color("AppAccent"))
                                    }
                                    Spacer()
                                    VStack(spacing: 0) {
                                        Button {
                                            store.movePoint(id: point.id, direction: -1)
                                        } label: {
                                            Image(systemName: "chevron.up")
                                                .frame(width: Theme.tap, height: 32)
                                        }
                                        .accessibilityIdentifier("movePoiUp_\(point.id.uuidString)")
                                        Button {
                                            store.movePoint(id: point.id, direction: 1)
                                        } label: {
                                            Image(systemName: "chevron.down")
                                                .frame(width: Theme.tap, height: 32)
                                        }
                                        .accessibilityIdentifier("movePoiDown_\(point.id.uuidString)")
                                    }
                                    .foregroundColor(Color("AppInk"))
                                    Menu {
                                        ForEach(DaySlot.allCases) { slot in
                                            Button(slot.rawValue) {
                                                store.setPointSlot(id: point.id, slot: slot.rawValue)
                                            }
                                        }
                                    } label: {
                                        Image(systemName: "clock")
                                            .frame(width: Theme.tap, height: Theme.tap)
                                            .foregroundColor(Color("AppAccent"))
                                    }
                                    JournalIconButton(systemImage: "trash", identifier: "deletePoiOnscreen_\(point.id.uuidString)") {
                                        pendingPoint = point
                                        confirmPointDelete = true
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    private func documentsCard(_ destination: Destination) -> some View {
        TicketStubCard {
            VStack(alignment: .leading, spacing: 12) {
                Text("Travel documents")
                    .font(.system(.headline, design: .serif))
                    .foregroundColor(Color("AppInk"))

                JournalField(
                    title: "Document title",
                    identifier: "documentTitleField",
                    text: $documentTitle,
                    placeholder: "Passport, Schengen visa…"
                )
                Picker("Kind", selection: $documentKind) {
                    ForEach(TripDocument.kinds, id: \.self) { kind in
                        Text(kind).tag(kind)
                    }
                }
                .pickerStyle(.menu)
                .tint(Color("AppInk"))
                .frame(maxWidth: .infinity, minHeight: Theme.tap, alignment: .leading)

                Toggle(isOn: $documentHasExpiry) {
                    Text("Has expiry date")
                        .font(.system(.body, design: .serif))
                        .foregroundColor(Color("AppInk"))
                }
                .tint(Color("AppAccent"))

                if documentHasExpiry {
                    DatePicker("Expiry", selection: $documentExpiry, displayedComponents: .date)
                        .datePickerStyle(.compact)
                        .tint(Color("AppAccent"))
                }

                JournalPrimaryButton(
                    title: "Add document",
                    systemImage: "doc.badge.plus",
                    identifier: "addDocumentButton"
                ) {
                    addDocument(destinationId: destination.id)
                }

                if let documentError {
                    InlineErrorText(message: documentError)
                }

                let items = store.documents(for: destination.id)
                if items.isEmpty {
                    Text("Track passport, visa, insurance, and tickets — dates only, no prices.")
                        .font(.system(.caption, design: .serif))
                        .foregroundColor(Color("AppInk").opacity(0.75))
                } else {
                    ForEach(items) { document in
                        HStack(alignment: .center, spacing: 10) {
                            Button {
                                store.toggleDocumentReady(id: document.id)
                            } label: {
                                Image(systemName: document.ready ? "checkmark.circle.fill" : "circle")
                                    .font(.title3)
                                    .foregroundColor(document.ready ? Color("AppAccent") : Color("AppInk"))
                                    .frame(width: Theme.tap, height: Theme.tap)
                            }
                            .buttonStyle(.plain)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(document.title)
                                    .font(.system(.body, design: .serif))
                                    .foregroundColor(Color("AppInk"))
                                Text(document.kind)
                                    .font(.system(.caption, design: .serif))
                                    .foregroundColor(Color("AppAccent"))
                                if let expiry = document.expiryLabel {
                                    Text(expiry)
                                        .font(.system(.caption2, design: .serif))
                                        .foregroundColor(Color("AppInk").opacity(0.75))
                                }
                            }
                            Spacer()
                            JournalIconButton(systemImage: "trash", identifier: "deleteDocument_\(document.id.uuidString)") {
                                pendingDocument = document
                                confirmDocumentDelete = true
                            }
                        }
                    }
                }
            }
        }
    }

    private func addNote(destinationId: UUID) {
        let trimmed = noteText.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            noteError = "Note text is required"
            return
        }
        noteError = nil
        store.addNote(destinationId: destinationId, text: trimmed, day: assignNoteDay ? noteDay : nil)
        noteText = ""
    }

    private func addPoint(destinationId: UUID) {
        let trimmed = poiTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            poiError = "A place title is required"
            return
        }
        poiError = nil
        store.addPoint(destinationId: destinationId, title: trimmed, kind: poiKind, slot: poiSlot)
        poiTitle = ""
    }

    private func addDocument(destinationId: UUID) {
        let trimmed = documentTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            documentError = "A document title is required"
            return
        }
        documentError = nil
        store.addDocument(
            destinationId: destinationId,
            kind: documentKind,
            title: trimmed,
            expiryDate: documentHasExpiry ? documentExpiry : nil
        )
        documentTitle = ""
    }
}
