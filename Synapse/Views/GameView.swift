import SwiftUI

struct GameView: View {
    @Bindable var viewModel: GameViewModel
    @Environment(\.dismiss) private var dismiss

    // Animation
    @State private var gridScale: CGFloat = 0.9
    @State private var showGameOver = false

    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [.black, Color(hex: "1a1a2e")],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 24) {
                // Header
                header

                Spacer()

                // Grid
                if !viewModel.cells.isEmpty {
                    gridView
                        .scaleEffect(gridScale)
                }

                Spacer()

                // Status text
                statusText
            }
            .padding()

            // Game Over overlay
            if viewModel.phase == .gameOver {
                gameOverOverlay
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            viewModel.startGame()
        }
        .onChange(of: viewModel.phase) { _, newPhase in
            if newPhase == .memorize {
                gridScale = 0.9
                withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                    gridScale = 1.0
                }
            }
            if newPhase == .gameOver {
                withAnimation(.easeInOut(duration: 0.3).delay(0.5)) {
                    showGameOver = true
                }
            }
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack {
            Button {
                viewModel.resetGame()
                dismiss()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.title2)
                    .foregroundColor(.gray)
            }

            Spacer()

            VStack(spacing: 2) {
                Text("ROUND")
                    .font(.caption.weight(.semibold))
                    .foregroundColor(.gray)
                Text("\(viewModel.round)")
                    .font(.title.weight(.black))
                    .foregroundColor(.white)
                    .contentTransition(.numericText())
            }

            Spacer()

            // Grid size indicator
            Text("\(viewModel.gridSize)×\(viewModel.gridSize)")
                .font(.callout.weight(.semibold))
                .foregroundColor(.cyan)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.cyan.opacity(0.15))
                .clipShape(Capsule())
        }
    }

    // MARK: - Grid

    private var gridView: some View {
        let maxWidth: CGFloat = min(UIScreen.main.bounds.width - 48, 400)
        let spacing: CGFloat = 8

        return LazyVGrid(columns: viewModel.gridColumns, spacing: spacing) {
            ForEach(viewModel.cells) { cell in
                CellView(
                    cell: cell,
                    phase: viewModel.phase,
                    gridSize: viewModel.gridSize
                )
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.15)) {
                        viewModel.tapCell(cell)
                    }
                }
            }
        }
        .frame(maxWidth: maxWidth)
        .padding(12)
    }

    // MARK: - Status

    private var statusText: some View {
        Group {
            switch viewModel.phase {
            case .memorize:
                Text("Memorize the pattern!")
                    .foregroundColor(.cyan)
            case .recall:
                Text("Tap \(viewModel.remainingTaps) cell\(viewModel.remainingTaps == 1 ? "" : "s")")
                    .foregroundColor(.white)
            case .success:
                Text("Correct! 🎉")
                    .foregroundColor(.green)
            default:
                Text(" ")
            }
        }
        .font(.headline)
        .animation(.easeInOut, value: viewModel.phase)
        .padding(.bottom, 20)
    }

    // MARK: - Game Over

    private var gameOverOverlay: some View {
        ZStack {
            Color.black.opacity(showGameOver ? 0.7 : 0)
                .ignoresSafeArea()

            if showGameOver {
                VStack(spacing: 24) {
                    Text("GAME OVER")
                        .font(.system(size: 32, weight: .black, design: .rounded))
                        .foregroundColor(.red)

                    Text("Round \(viewModel.round)")
                        .font(.title2.weight(.semibold))
                        .foregroundColor(.white)

                    VStack(spacing: 12) {
                        Button {
                            showGameOver = false
                            viewModel.startGame()
                        } label: {
                            Text("PLAY AGAIN")
                                .font(.headline.weight(.bold))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(
                                    LinearGradient(
                                        colors: [.cyan, .blue],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .foregroundColor(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                        }

                        Button {
                            showGameOver = false
                            viewModel.resetGame()
                            dismiss()
                        } label: {
                            Text("HOME")
                                .font(.headline)
                                .foregroundColor(.gray)
                                .padding(.vertical, 10)
                        }
                    }
                    .frame(maxWidth: 250)
                }
                .padding(32)
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color(hex: "1a1a2e"))
                        .shadow(color: .cyan.opacity(0.2), radius: 20)
                )
                .transition(.scale.combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: showGameOver)
    }
}

#Preview {
    GameView(viewModel: GameViewModel())
}
