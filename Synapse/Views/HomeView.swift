import SwiftUI

struct HomeView: View {
    @State private var navigateToGame = false
    @State private var showLeaderboard = false
    @State private var viewModel = GameViewModel()

    // Animation
    @State private var titleScale: CGFloat = 0.8
    @State private var buttonsOpacity: Double = 0

    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                LinearGradient(
                    colors: [.black, Color(hex: "1a1a2e"), Color(hex: "16213e")],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack(spacing: 40) {
                    Spacer()

                    // Title
                    VStack(spacing: 12) {
                        Text("🧠")
                            .font(.system(size: 64))

                        Text("SYNAPSE")
                            .font(.system(size: 42, weight: .black, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.cyan, .purple],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )

                        Text("How far can you remember?")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .scaleEffect(titleScale)

                    Spacer()

                    // Buttons
                    VStack(spacing: 16) {
                        Button {
                            navigateToGame = true
                        } label: {
                            Text("PLAY")
                                .font(.title2.weight(.bold))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    LinearGradient(
                                        colors: [.cyan, .blue],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .foregroundColor(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                        }

                        Button {
                            if GameCenterManager.shared.isAuthenticated {
                                GameCenterManager.shared.showLeaderboard()
                            } else {
                                showLeaderboard = true // Fallback local
                            }
                        } label: {
                            Text("LEADERBOARD")
                                .font(.headline.weight(.semibold))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(Color.white.opacity(0.1))
                                .foregroundColor(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                )
                        }
                    }
                    .padding(.horizontal, 40)
                    .opacity(buttonsOpacity)

                    Spacer()
                        .frame(height: 60)
                }
            }
            .navigationDestination(isPresented: $navigateToGame) {
                GameView(viewModel: viewModel)
            }
            .sheet(isPresented: $showLeaderboard) {
                LeaderboardView(entries: viewModel.leaderboard)
            }
            .onAppear {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.1)) {
                    titleScale = 1.0
                }
                withAnimation(.easeOut(duration: 0.5).delay(0.4)) {
                    buttonsOpacity = 1.0
                }
            }
        }
    }
}

// MARK: - Hex Color Extension

extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)
        self.init(
            red: Double((rgb >> 16) & 0xFF) / 255,
            green: Double((rgb >> 8) & 0xFF) / 255,
            blue: Double(rgb & 0xFF) / 255
        )
    }
}

#Preview {
    HomeView()
}
