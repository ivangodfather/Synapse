import GameKit
import SwiftUI

@MainActor
@Observable
final class GameCenterManager {
    static let shared = GameCenterManager()

    var isAuthenticated = false
    var localPlayerName: String = ""

    // Change this to match your App Store Connect leaderboard ID
    static let leaderboardID = "com.synapse.highscore"

    private init() {}

    // MARK: - Authentication

    func authenticate() {
        GKLocalPlayer.local.authenticateHandler = { [weak self] viewController, error in
            Task { @MainActor in
                if let error {
                    print("Game Center auth error: \(error.localizedDescription)")
                    self?.isAuthenticated = false
                    return
                }

                if viewController != nil {
                    // iOS will present the sign-in UI automatically
                    return
                }

                self?.isAuthenticated = GKLocalPlayer.local.isAuthenticated
                self?.localPlayerName = GKLocalPlayer.local.displayName
            }
        }
    }

    // MARK: - Submit Score

    func submitScore(_ score: Int) async {
        guard isAuthenticated else { return }
        do {
            try await GKLeaderboard.submitScore(
                score,
                context: 0,
                player: GKLocalPlayer.local,
                leaderboardIDs: [Self.leaderboardID]
            )
            print("Score \(score) submitted to Game Center")
        } catch {
            print("Failed to submit score: \(error.localizedDescription)")
        }
    }

    // MARK: - Show Leaderboard

    func showLeaderboard() {
        guard isAuthenticated else { return }
        let viewController = GKGameCenterViewController(
            leaderboardID: Self.leaderboardID,
            playerScope: .global,
            timeScope: .allTime
        )
        viewController.gameCenterDelegate = GameCenterDismissHandler.shared

        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootVC = windowScene.windows.first?.rootViewController else { return }

        rootVC.present(viewController, animated: true)
    }
}

// MARK: - Dismiss Handler

final class GameCenterDismissHandler: NSObject, GKGameCenterControllerDelegate, @unchecked Sendable {
    static let shared = GameCenterDismissHandler()

    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true)
    }
}
