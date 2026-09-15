import SwiftUI
import UIKit

enum AppSection: String, CaseIterable, Identifiable {
    case launch = "Launch"
    case kit = "Kit"
    case briefs = "Briefs"

    var id: String { rawValue }

    var title: String { rawValue }

    var symbol: String {
        switch self {
        case .launch: return "clock.fill"
        case .kit: return "bag.fill"
        case .briefs: return "map.fill"
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
    func ridgeCanvas() -> some View {
        self
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background {
                Color("AppBackground").overlay {
                    Image("bgAlley").resizable().scaledToFill().opacity(0.18)
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

    func ridgeTapTarget() -> some View {
        self.frame(minWidth: Theme.tap, minHeight: Theme.tap)
    }

    func clearScrollBackground() -> some View {
        scrollContentBackground(.hidden)
            .background(Color.clear)
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
        if window.gestureRecognizers?.contains(where: { $0.name == "ridge.dismissKeyboard" }) == true {
            return
        }
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        tap.requiresExclusiveTouchType = false
        tap.name = "ridge.dismissKeyboard"
        window.addGestureRecognizer(tap)
    }

    @objc private func dismissKeyboard() {
        Theme.dismissKeyboard()
    }
}

struct RidgeBanner: View {
    let imageName: String

    var body: some View {
        Color.clear
            .frame(maxWidth: .infinity)
            .frame(height: 128)
            .background {
                Color("AppBackground").overlay {
                    Image(imageName)
                        .resizable()
                        .scaledToFill()
                }
                .clipped()
            }
            .overlay(alignment: .leading) {
                Circle()
                    .fill(Color("AppBackground"))
                    .frame(width: 22, height: 22)
                    .offset(x: -11)
            }
            .overlay(alignment: .trailing) {
                Circle()
                    .fill(Color("AppBackground"))
                    .frame(width: 22, height: 22)
                    .offset(x: 11)
            }
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .strokeBorder(Color("AppAccent").opacity(0.55), lineWidth: 1.2)
            }
            .shadow(color: Color("AppPrimary").opacity(0.22), radius: 8, y: 4)
            .allowsHitTesting(false)
            .accessibilityHidden(true)
    }
}

struct LiftPassCard<Content: View>: View {
    private let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(16)
            .padding(.leading, 10)
            .background {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color("AppSurface"))
                    .shadow(color: Color("AppPrimary").opacity(0.18), radius: 8, y: 4)
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .strokeBorder(Color("AppAccent").opacity(0.45), lineWidth: 1)
            }
            .overlay(alignment: .leading) {
                VStack(spacing: 10) {
                    ForEach(0..<4, id: \.self) { _ in
                        Circle()
                            .strokeBorder(Color("AppAccent").opacity(0.7), lineWidth: 1.2)
                            .frame(width: 8, height: 8)
                    }
                }
                .padding(.leading, 8)
            }
    }
}

struct ChairPunch: View {
    let symbol: String
    let caption: String

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: symbol)
                .font(.system(size: 18, weight: .semibold, design: .rounded))
            Text(caption)
                .font(.system(.caption2, design: .rounded))
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .foregroundColor(Color("AppInk"))
        .frame(width: 78, height: 78)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color("AppSurface").opacity(0.95))
        )
        .overlay {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .strokeBorder(Color("AppAccent"), lineWidth: 1.6)
        }
    }
}

struct RidgeEmptyState: View {
    let symbol: String
    let message: String

    var body: some View {
        VStack(spacing: 18) {
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .strokeBorder(Color("AppAccent"), lineWidth: 1.6)
                    .frame(width: 88, height: 88)
                Image(systemName: symbol)
                    .font(.system(size: 34, weight: .semibold, design: .rounded))
                    .foregroundColor(Color("AppInk"))
            }
            Text(message)
                .font(.system(.body, design: .rounded))
                .multilineTextAlignment(.center)
                .foregroundColor(Color("AppInk"))
                .padding(.horizontal, 12)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 28)
    }
}

struct RidgePrimaryButton: View {
    let title: String
    let systemImage: String
    var identifier: String
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: systemImage)
                Text(title)
                    .font(.system(.headline, design: .rounded))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity, minHeight: Theme.tap)
            .background {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
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
        .ridgeTapTarget()
    }
}

struct RidgeField: View {
    let title: String
    let identifier: String
    @Binding var text: String
    var placeholder: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(.caption, design: .rounded))
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
                        .strokeBorder(Color("AppAccent").opacity(0.5), lineWidth: 1)
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
            .font(.system(.caption, design: .rounded))
            .foregroundColor(Color("AppAccent"))
            .frame(maxWidth: .infinity, alignment: .leading)
            .accessibilityIdentifier("inlineError")
    }
}
