import StoreKit
import UIKit

enum AppLinks {
    static let privacy = "https://travureharmonyguide333.site/privacy/435"
    static let terms = "https://travureharmonyguide333.site/terms/435"

    static func openPrivacy() {
        if let url = URL(string: AppLinks.privacy) {
            UIApplication.shared.open(url)
        }
    }

    static func openTerms() {
        if let url = URL(string: AppLinks.terms) {
            UIApplication.shared.open(url)
        }
    }

    static func rateApp() {
        let scenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
        let windowScene = scenes.first(where: { $0.activationState == .foregroundActive }) ?? scenes.first
        if let windowScene {
            SKStoreReviewController.requestReview(in: windowScene)
        }
    }
}
