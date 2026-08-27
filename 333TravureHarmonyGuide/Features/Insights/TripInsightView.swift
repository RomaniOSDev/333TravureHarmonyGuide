import SwiftUI
import Charts

struct TripInsightView: View {
    @EnvironmentObject private var store: AppStore
    @Environment(\.dismiss) private var dismiss

    private var stampRows: [StampRow] {
        [
            StampRow(label: "Visited", value: store.visitedCount),
            StampRow(label: "Planned", value: store.plannedCount)
        ]
    }

    private var journalRows: [StampRow] {
        [
            StampRow(label: "Notes", value: store.notes.count),
            StampRow(label: "Places", value: store.points.count),
            StampRow(label: "Lists", value: store.tripEssentials.count)
        ]
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    JournalBanner(imageName: "bannerMarket")

                    HStack(spacing: 18) {
                        PassportStamp(symbol: "checkmark.seal.fill", caption: "Visited\n\(store.visitedCount)", rotation: -10)
                        PassportStamp(symbol: "airplane", caption: "Planned\n\(store.plannedCount)", rotation: 8)
                        PassportStamp(symbol: "suitcase.fill", caption: "Lists\n\(store.tripEssentials.count)", rotation: -4)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)

                    TicketStubCard {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Stamps vs tickets")
                                .font(.system(.headline, design: .serif))
                                .foregroundColor(Color("AppInk"))
                            if store.destinations.isEmpty {
                                Text("Add a destination to see visited vs planned.")
                                    .font(.system(.caption, design: .serif))
                                    .foregroundColor(Color("AppInk").opacity(0.75))
                            } else {
                                Chart(stampRows) { row in
                                    BarMark(
                                        x: .value("Count", row.value),
                                        y: .value("Status", row.label)
                                    )
                                    .foregroundStyle(
                                        row.label == "Visited"
                                            ? Color("AppAccent")
                                            : Color("AppPrimary")
                                    )
                                }
                                .chartXScale(domain: 0...(max(store.destinations.count, 1)))
                                .chartXAxis {
                                    AxisMarks(position: .bottom) { _ in
                                        AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [4, 3]))
                                            .foregroundStyle(Color("AppInk").opacity(0.25))
                                        AxisValueLabel()
                                            .foregroundStyle(Color("AppInk"))
                                    }
                                }
                                .chartYAxis {
                                    AxisMarks { _ in
                                        AxisValueLabel()
                                            .foregroundStyle(Color("AppInk"))
                                    }
                                }
                                .frame(height: 120)
                                .accessibilityIdentifier("statsVisitedChart")
                            }
                            Text(visitedCaption)
                                .font(.system(.caption, design: .serif))
                                .foregroundColor(Color("AppInk").opacity(0.75))
                        }
                    }

                    TicketStubCard {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Climate mix")
                                .font(.system(.headline, design: .serif))
                                .foregroundColor(Color("AppInk"))
                            if store.climateCounts.isEmpty {
                                Text("Climate tags will appear here after you add destinations.")
                                    .font(.system(.caption, design: .serif))
                                    .foregroundColor(Color("AppInk").opacity(0.75))
                            } else {
                                Chart(store.climateCounts) { item in
                                    BarMark(
                                        x: .value("Count", item.count),
                                        y: .value("Climate", item.climate.rawValue)
                                    )
                                    .foregroundStyle(Color("AppAccent"))
                                }
                                .chartXAxis {
                                    AxisMarks(position: .bottom) { _ in
                                        AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [4, 3]))
                                            .foregroundStyle(Color("AppInk").opacity(0.25))
                                        AxisValueLabel()
                                            .foregroundStyle(Color("AppInk"))
                                    }
                                }
                                .chartYAxis {
                                    AxisMarks { _ in
                                        AxisValueLabel()
                                            .foregroundStyle(Color("AppInk"))
                                    }
                                }
                                .frame(height: CGFloat(max(store.climateCounts.count, 1)) * 36 + 24)
                                .accessibilityIdentifier("statsClimateChart")
                            }
                        }
                    }

                    TicketStubCard {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Packing completion")
                                .font(.system(.headline, design: .serif))
                                .foregroundColor(Color("AppInk"))
                            if store.tripEssentials.isEmpty {
                                Text("Packing lists will appear here after you add a destination.")
                                    .font(.system(.caption, design: .serif))
                                    .foregroundColor(Color("AppInk").opacity(0.75))
                            } else {
                                Chart(store.tripEssentials) { trip in
                                    BarMark(
                                        x: .value("List", trip.title),
                                        y: .value("Packed", trip.completion * 100)
                                    )
                                    .foregroundStyle(Color("AppAccent"))
                                }
                                .chartYScale(domain: 0...100)
                                .chartXAxis {
                                    AxisMarks { _ in
                                        AxisValueLabel()
                                            .foregroundStyle(Color("AppInk"))
                                    }
                                }
                                .chartYAxis {
                                    AxisMarks(position: .leading) { _ in
                                        AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [4, 3]))
                                            .foregroundStyle(Color("AppInk").opacity(0.25))
                                        AxisValueLabel()
                                            .foregroundStyle(Color("AppInk"))
                                    }
                                }
                                .frame(height: 180)
                                .accessibilityIdentifier("insightPackingProgress")
                            }
                            Text("\(Int((store.overallPackingCompletion * 100).rounded()))% of all essentials packed")
                                .font(.system(.body, design: .serif))
                                .foregroundColor(Color("AppInk"))
                        }
                    }

                    TicketStubCard {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Journal volume")
                                .font(.system(.headline, design: .serif))
                                .foregroundColor(Color("AppInk"))
                            Chart(journalRows) { row in
                                BarMark(
                                    x: .value("Kind", row.label),
                                    y: .value("Count", row.value)
                                )
                                .foregroundStyle(Color("AppPrimary"))
                            }
                            .chartYAxis {
                                AxisMarks(position: .leading) { _ in
                                    AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [4, 3]))
                                        .foregroundStyle(Color("AppInk").opacity(0.25))
                                    AxisValueLabel()
                                        .foregroundStyle(Color("AppInk"))
                                }
                            }
                            .chartXAxis {
                                AxisMarks { _ in
                                    AxisValueLabel()
                                        .foregroundStyle(Color("AppInk"))
                                }
                            }
                            .frame(height: 160)
                            .accessibilityIdentifier("statsJournalChart")
                        }
                    }

                    TicketStubCard {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Journal pulse")
                                .font(.system(.headline, design: .serif))
                                .foregroundColor(Color("AppInk"))
                            Label(dateLine(store.lastActivityDate, empty: "No activity yet"), systemImage: "clock")
                                .font(.system(.caption, design: .serif))
                                .foregroundColor(Color("AppInk"))
                                .accessibilityIdentifier("lastActivityLabel")
                            Label(dateLine(store.lastSyncDate, empty: "Journal not saved yet"), systemImage: "tray.and.arrow.down")
                                .font(.system(.caption, design: .serif))
                                .foregroundColor(Color("AppInk"))
                                .accessibilityIdentifier("lastSyncLabel")
                        }
                    }
                }
                .padding(16)
            }
            .journalCanvas()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack(spacing: 6) {
                        Image(systemName: "chart.bar.xaxis")
                        Text("Statistics")
                            .font(.system(.headline, design: .serif))
                    }
                    .foregroundColor(Color("AppInk"))
                    .accessibilityIdentifier("insightTitle")
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                        .frame(minHeight: Theme.tap)
                        .accessibilityIdentifier("insightDoneButton")
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    private var visitedCaption: String {
        if store.destinations.isEmpty {
            return "Your passport is still blank — add a dream spot to begin."
        }
        if store.visitedCount == 0 {
            return "All destinations are still planned. Stamp one when you go."
        }
        return "\(store.visitedCount) stamped, \(store.plannedCount) waiting in the ticket pocket."
    }

    private func dateLine(_ date: Date?, empty: String) -> String {
        guard let date else { return empty }
        return date.formatted(date: .abbreviated, time: .shortened)
    }
}

private struct StampRow: Identifiable {
    let label: String
    let value: Int
    var id: String { label }
}
