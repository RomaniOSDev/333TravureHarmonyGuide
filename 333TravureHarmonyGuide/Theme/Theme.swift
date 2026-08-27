import SwiftUI
import UIKit

enum JournalSection: String, CaseIterable, Identifiable {
    case destinations = "Destinations"
    case packing = "Packing"
    case units = "Units"

    var id: String { rawValue }

    var title: String { rawValue }

    var symbol: String {
        switch self {
        case .destinations: return "globe"
        case .packing: return "suitcase.fill"
        case .units: return "ruler.fill"
        }
    }
}

enum Theme {
    static let tap: CGFloat = 44

    static func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

extension View {
    func journalCanvas() -> some View {
        self
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background {
                Color("AppBackground").overlay {
                    Image("bgAlley").resizable().scaledToFill().opacity(0.22)
                }
                .clipped()
                .ignoresSafeArea()
            }
            .background {
                KeyboardDismissSieve()
            }
            .scrollDismissesKeyboard(.interactively)
            .preferredColorScheme(.dark)
    }

    func journalTapTarget() -> some View {
        self.frame(minWidth: Theme.tap, minHeight: Theme.tap)
    }
}

private struct KeyboardDismissSieve: UIViewRepresentable {
    func makeUIView(context: Context) -> KeyboardDismissInstaller {
        KeyboardDismissInstaller()
    }

    func updateUIView(_ uiView: KeyboardDismissInstaller, context: Context) {}
}

private final class KeyboardDismissInstaller: UIView {
    override func didMoveToWindow() {
        super.didMoveToWindow()
        guard let window else { return }
        if window.gestureRecognizers?.contains(where: { $0.name == "journal.dismissKeyboard" }) == true {
            return
        }
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        tap.requiresExclusiveTouchType = false
        tap.name = "journal.dismissKeyboard"
        window.addGestureRecognizer(tap)
    }

    @objc private func dismissKeyboard() {
        Theme.dismissKeyboard()
    }
}

struct JournalBanner: View {
    let imageName: String

    var body: some View {
        Color.clear
            .frame(maxWidth: .infinity)
            .frame(height: 132)
            .background {
                Color("AppBackground").overlay {
                    Image(imageName)
                        .resizable()
                        .scaledToFill()
                }
                .clipped()
            }
            .overlay {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(style: StrokeStyle(lineWidth: 1.5, dash: [7, 5]))
                    .foregroundColor(Color("AppAccent").opacity(0.85))
                    .padding(6)
            }
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .shadow(color: Color("AppPrimary").opacity(0.22), radius: 8, y: 4)
            .allowsHitTesting(false)
            .accessibilityHidden(true)
    }
}

struct TicketStubCard<Content: View>: View {
    private let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(16)
            .background {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color("AppSurface"))
                    .shadow(color: Color("AppPrimary").opacity(0.18), radius: 8, x: 0, y: 4)
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(style: StrokeStyle(lineWidth: 1.4, dash: [6, 4]))
                    .foregroundColor(Color("AppAccent").opacity(0.6))
            }
    }
}

struct PassportStamp: View {
    let symbol: String
    let caption: String
    var rotation: Double = -8

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: symbol)
                .font(.system(size: 20, weight: .semibold))
            Text(caption)
                .font(.system(.caption2, design: .serif))
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .foregroundColor(Color("AppInk"))
        .frame(width: 76, height: 76)
        .background(
            Circle()
                .fill(Color("AppSurface").opacity(0.9))
                .shadow(color: Color("AppPrimary").opacity(0.16), radius: 4, y: 2)
        )
        .overlay {
            Circle()
                .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [3, 2]))
                .foregroundColor(Color("AppAccent"))
        }
        .rotationEffect(.degrees(rotation))
    }
}

struct JournalEmptyState: View {
    let symbol: String
    let message: String

    var body: some View {
        VStack(spacing: 18) {
            ZStack {
                Circle()
                    .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [4, 3]))
                    .foregroundColor(Color("AppAccent"))
                    .frame(width: 92, height: 92)
                Image(systemName: symbol)
                    .font(.system(size: 36, weight: .semibold))
                    .foregroundColor(Color("AppInk"))
            }
            .shadow(color: Color("AppPrimary").opacity(0.12), radius: 6, y: 3)

            Text(message)
                .font(.system(.body, design: .serif))
                .multilineTextAlignment(.center)
                .foregroundColor(Color("AppInk"))
                .padding(.horizontal, 12)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 28)
    }
}

struct JournalPrimaryButton: View {
    let title: String
    let systemImage: String
    var identifier: String
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: systemImage)
                Text(title)
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
                    .shadow(color: Color("AppPrimary").opacity(0.32), radius: 6, y: 3)
            }
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier(identifier)
        .journalTapTarget()
    }
}

struct JournalIconButton: View {
    let systemImage: String
    var identifier: String
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: Theme.tap, height: Theme.tap)
                .background {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color("AppPrimary"), Color("AppAccent")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .shadow(color: Color("AppPrimary").opacity(0.28), radius: 4, y: 2)
                }
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier(identifier)
        .journalTapTarget()
    }
}

struct JournalField: View {
    let title: String
    let identifier: String
    @Binding var text: String
    var placeholder: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(.caption, design: .serif))
                .foregroundColor(Color("AppInk").opacity(0.85))
            TextField(placeholder, text: $text)
                .foregroundColor(Color("AppInk"))
                .textInputAutocapitalization(.words)
                .disableAutocorrection(true)
                .padding(.horizontal, 12)
                .frame(minHeight: Theme.tap)
                .background(Color("AppBackground").opacity(0.7))
                .overlay {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [5, 3]))
                        .foregroundColor(Color("AppAccent").opacity(0.55))
                }
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                .accessibilityIdentifier(identifier)
        }
    }
}

struct InlineErrorText: View {
    let message: String

    var body: some View {
        Text(message)
            .font(.system(.caption, design: .serif))
            .foregroundColor(Color("AppAccent"))
            .frame(maxWidth: .infinity, alignment: .leading)
            .accessibilityIdentifier("inlineError")
    }
}
