import SwiftUI

@main
struct SynapseApp: App {
    var body: some Scene {
        WindowGroup {
            HomeView()
                .onAppear {
                    GameCenterManager.shared.authenticate()
                }
        }
    }
}
