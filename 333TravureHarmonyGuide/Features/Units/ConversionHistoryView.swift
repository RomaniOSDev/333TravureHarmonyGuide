import SwiftUI

struct ConversionHistoryView: View {
    @EnvironmentObject private var store: AppStore
    @Environment(\.dismiss) private var dismiss
    let onSelect: (Double) -> Void

    var body: some View {
        NavigationStack {
            Group {
                if store.recentAmounts.isEmpty {
                    ScrollView {
                        TicketStubCard {
                            JournalEmptyState(
                                symbol: "clock.arrow.circlepath",
                                message: "No conversions logged yet. Convert a travel unit to keep it on this ticket."
                            )
                        }
                        .padding(16)
                    }
                    .journalCanvas()
                } else {
                    List {
                        ForEach(Array(store.recentAmounts.enumerated()), id: \.offset) { index, amount in
                            Button {
                                onSelect(amount)
                            } label: {
                                TicketStubCard {
                                    HStack {
                                        PassportStamp(symbol: "ruler.fill", caption: "Value", rotation: index.isMultiple(of: 2) ? -8 : 6)
                                        Text(formatted(amount))
                                            .font(.system(.title3, design: .serif).weight(.semibold))
                                            .foregroundColor(Color("AppInk"))
                                        Spacer()
                                        Image(systemName: "arrow.turn.up.right")
                                            .foregroundColor(Color("AppAccent"))
                                    }
                                }
                            }
                            .buttonStyle(.plain)
                            .accessibilityIdentifier("recentAmount_\(index)")
                            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                    .journalCanvas()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Recent values")
                        .font(.system(.headline, design: .serif))
                        .foregroundColor(Color("AppInk"))
                        .accessibilityIdentifier("conversionHistoryTitle")
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                        .frame(minHeight: Theme.tap)
                        .accessibilityIdentifier("conversionHistoryDoneButton")
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    private func formatted(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: value)) ?? String(format: "%.2f", value)
    }
}
