import SwiftUI

struct UnitConverterView: View {
    @EnvironmentObject private var store: AppStore
    @State private var amountText = ""
    @State private var amountError: String?
    @State private var showHistory = false
    @State private var kind: TravelUnit.Kind = .temperature
    @State private var clockTime = Date()

    private var fromUnit: TravelUnit? { TravelUnit.unit(for: store.homeUnitCode) }
    private var toUnit: TravelUnit? { TravelUnit.unit(for: store.destinationUnitCode) }

    private var unitsReady: Bool {
        fromUnit != nil && toUnit != nil && fromUnit?.kind == toUnit?.kind
    }

    private var parsedAmount: Double? {
        let trimmed = amountText.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty { return nil }
        let normalized = trimmed.replacingOccurrences(of: ",", with: ".")
        return Double(normalized)
    }

    private var converted: Double? {
        guard let amount = parsedAmount, amountError == nil else { return nil }
        return TravelUnit.convert(
            amount: amount,
            from: store.homeUnitCode,
            to: store.destinationUnitCode
        )
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                TicketStubCard {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Travel units")
                            .font(.system(.caption, design: .serif))
                            .foregroundColor(Color("AppInk").opacity(0.85))
                        Picker("Kind", selection: $kind) {
                            ForEach(TravelUnit.Kind.allCases) { item in
                                Text(item.rawValue).tag(item)
                            }
                        }
                        .pickerStyle(.segmented)
                        .accessibilityIdentifier("unitKindPicker")
                        .onChange(of: kind) { newKind in
                            if fromUnit?.kind != newKind || toUnit?.kind != newKind {
                                applyKind(newKind)
                            }
                        }
                    }
                }

                TicketStubCard {
                    VStack(spacing: 14) {
                        unitPicker(
                            title: "From",
                            identifier: "fromUnitPicker",
                            selection: fromBinding
                        )
                        JournalIconButton(
                            systemImage: "arrow.up.arrow.down.circle.fill",
                            identifier: "swapUnitsButton"
                        ) {
                            swapUnits()
                        }
                        .frame(maxWidth: .infinity)

                        unitPicker(
                            title: "To",
                            identifier: "toUnitPicker",
                            selection: toBinding
                        )
                    }
                }

                if kind == .zones {
                    timezoneCard
                } else if unitsReady {
                    TicketStubCard {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Value")
                                .font(.system(.caption, design: .serif))
                                .foregroundColor(Color("AppInk").opacity(0.85))
                            TextField("0.00", text: $amountText)
                                .keyboardType(.decimalPad)
                                .foregroundColor(Color("AppInk"))
                                .padding(.horizontal, 12)
                                .frame(minHeight: Theme.tap)
                                .background(Color("AppBackground").opacity(0.7))
                                .overlay {
                                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                                        .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [5, 3]))
                                        .foregroundColor(Color("AppAccent").opacity(0.55))
                                }
                                .accessibilityIdentifier("amountField")
                                .onChange(of: amountText) { newValue in
                                    validate(newValue)
                                }

                            if let amountError {
                                InlineErrorText(message: amountError)
                            }

                            if let converted, let toUnit {
                                HStack(alignment: .firstTextBaseline) {
                                    Text(formatted(converted))
                                        .font(.system(.largeTitle, design: .serif).weight(.semibold))
                                        .foregroundColor(Color("AppInk"))
                                    Text(toUnit.displayName)
                                        .font(.system(.headline, design: .serif))
                                        .foregroundColor(Color("AppAccent"))
                                }
                                .accessibilityIdentifier("conversionResult")

                                if let fromUnit, fromUnit.code != toUnit.code {
                                    Text("1 \(fromUnit.displayName) = \(formatted(TravelUnit.convert(amount: 1, from: fromUnit.code, to: toUnit.code) ?? 0)) \(toUnit.displayName)")
                                        .font(.system(.caption, design: .serif))
                                        .foregroundColor(Color("AppInk").opacity(0.75))
                                }
                            }

                            JournalPrimaryButton(
                                title: "Log conversion",
                                systemImage: "book.closed.fill",
                                identifier: "logConversionButton"
                            ) {
                                logConversion()
                            }
                        }
                    }

                    JournalPrimaryButton(
                        title: "Recent values",
                        systemImage: "clock.arrow.circlepath",
                        identifier: "openConversionHistoryButton"
                    ) {
                        showHistory = true
                    }
                }
            }
            .padding(16)
        }
        .journalCanvas()
        .onAppear {
            kind = fromUnit?.kind ?? .temperature
            if fromUnit?.kind != toUnit?.kind {
                applyKind(kind)
            }
        }
        .sheet(isPresented: $showHistory) {
            ConversionHistoryView { amount in
                amountText = formatted(amount)
                validate(amountText)
                showHistory = false
            }
            .environmentObject(store)
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") { Theme.dismissKeyboard() }
                    .foregroundColor(Color("AppAccent"))
            }
        }
    }

    private var timezoneCard: some View {
        TicketStubCard {
            VStack(alignment: .leading, spacing: 12) {
                Text("Local clocks")
                    .font(.system(.caption, design: .serif))
                    .foregroundColor(Color("AppInk").opacity(0.85))
                if let fromUnit, let toUnit {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(fromUnit.displayName)
                                .font(.system(.caption, design: .serif))
                                .foregroundColor(Color("AppAccent"))
                            Text(TravelUnit.clockTime(in: fromUnit.code))
                                .font(.system(.title2, design: .serif).weight(.semibold))
                                .foregroundColor(Color("AppInk"))
                        }
                        Spacer()
                        VStack(alignment: .trailing, spacing: 4) {
                            Text(toUnit.displayName)
                                .font(.system(.caption, design: .serif))
                                .foregroundColor(Color("AppAccent"))
                            Text(TravelUnit.clockTime(in: toUnit.code))
                                .font(.system(.title2, design: .serif).weight(.semibold))
                                .foregroundColor(Color("AppInk"))
                        }
                    }
                    .accessibilityIdentifier("zoneNowClocks")

                    DatePicker("When it is", selection: $clockTime, displayedComponents: .hourAndMinute)
                        .datePickerStyle(.compact)
                        .tint(Color("AppAccent"))
                        .accessibilityIdentifier("zoneClockPicker")

                    if let instant = TravelUnit.convertClock(clockTime, from: fromUnit.code, to: toUnit.code) {
                        Text("That moment is \(TravelUnit.clockTime(in: toUnit.code, from: instant)) in \(toUnit.displayName).")
                            .font(.system(.body, design: .serif))
                            .foregroundColor(Color("AppInk"))
                            .accessibilityIdentifier("zoneConversionResult")
                    }
                }
            }
        }
    }

    private var fromBinding: Binding<String> {
        Binding(
            get: { store.homeUnitCode },
            set: { store.setHomeUnit($0) }
        )
    }

    private var toBinding: Binding<String> {
        Binding(
            get: { store.destinationUnitCode },
            set: { store.setDestinationUnit($0) }
        )
    }

    private func unitPicker(title: String, identifier: String, selection: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(.caption, design: .serif))
                .foregroundColor(Color("AppInk").opacity(0.85))
            Picker(title, selection: selection) {
                ForEach(TravelUnit.units(for: kind)) { unit in
                    Text(unit.displayName).tag(unit.code)
                }
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
            .accessibilityIdentifier(identifier)
        }
    }

    private func applyKind(_ newKind: TravelUnit.Kind) {
        let pair = TravelUnit.units(for: newKind)
        guard let first = pair.first, let second = pair.dropFirst().first ?? pair.first else { return }
        store.setHomeUnit(first.code)
        store.setDestinationUnit(second.code)
        Haptics.light()
    }

    private func swapUnits() {
        let home = store.homeUnitCode
        let dest = store.destinationUnitCode
        store.setHomeUnit(dest)
        store.setDestinationUnit(home)
        Haptics.light()
    }

    private func validate(_ raw: String) {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            amountError = nil
            return
        }
        let normalized = trimmed.replacingOccurrences(of: ",", with: ".")
        guard Double(normalized) != nil else {
            amountError = "Enter a valid number"
            return
        }
        amountError = nil
    }

    private func logConversion() {
        validate(amountText)
        guard amountError == nil, let amount = parsedAmount else {
            if amountText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                amountError = "Enter a valid number"
            }
            Haptics.warning()
            return
        }
        if !unitsReady {
            amountError = "Select both units to convert"
            return
        }
        store.logAmount(amount)
        Haptics.success()
    }

    private func formatted(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: value)) ?? String(format: "%.2f", value)
    }
}
