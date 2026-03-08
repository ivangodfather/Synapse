import UIKit

@MainActor
final class HapticsManager: Sendable {
    static let shared = HapticsManager()
    private init() {}

    func light() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    func success() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }

    func error() {
        UINotificationFeedbackGenerator().notificationOccurred(.error)
    }
}
