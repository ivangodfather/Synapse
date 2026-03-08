import Foundation
import Observation
import SwiftUI

@MainActor
@Observable
final class GameViewModel {

    // MARK: - Published State

    var phase: GamePhase = .idle
    var round: Int = 0
    var cells: [Cell] = []
    var config: RoundConfig = .forRound(1)
    var leaderboard: [LeaderboardEntry] = []

    // MARK: - Computed

    var gridSize: Int { config.gridSize }
    var gridColumns: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: 8), count: gridSize)
    }
    var activeCellCount: Int { config.activeCells }
    var tappedCorrectCount: Int {
        cells.filter { $0.isActive && $0.isTapped }.count
    }
    var remainingTaps: Int {
        activeCellCount - tappedCorrectCount
    }

    // MARK: - Private

    private var displayTimer: Task<Void, Never>?
    private let leaderboardKey = "synapse_leaderboard"

    // MARK: - Init

    init() {
        loadLeaderboard()
    }

    // MARK: - Game Flow

    func startGame() {
        round = 0
        nextRound()
    }

    func nextRound() {
        round += 1
        config = RoundConfig.forRound(round)
        generateGrid()
        startMemorizePhase()
    }

    func tapCell(_ cell: Cell) {
        guard phase == .recall else { return }
        guard let index = cells.firstIndex(where: { $0.id == cell.id }) else { return }
        guard !cells[index].isTapped else { return }

        cells[index].isTapped = true
        HapticsManager.shared.light()

        if !cell.isActive {
            // Wrong cell — game over
            revealAll()
            phase = .gameOver
            HapticsManager.shared.error()
            saveScore()
        } else if tappedCorrectCount == activeCellCount {
            // All correct!
            phase = .success
            HapticsManager.shared.success()

            Task { @MainActor in
                try? await Task.sleep(for: .seconds(0.8))
                guard phase == .success else { return }
                nextRound()
            }
        }
    }

    func resetGame() {
        displayTimer?.cancel()
        phase = .idle
        round = 0
        cells = []
    }

    // MARK: - Grid Generation

    private func generateGrid() {
        let totalCells = gridSize * gridSize
        var newCells = (0..<totalCells).map { Cell(id: $0, isActive: false, isRevealed: false, isTapped: false) }

        // Randomly select active cells
        var activeIndices = Set<Int>()
        while activeIndices.count < config.activeCells {
            activeIndices.insert(Int.random(in: 0..<totalCells))
        }

        for index in activeIndices {
            newCells[index].isActive = true
        }

        cells = newCells
    }

    // MARK: - Phases

    private func startMemorizePhase() {
        phase = .memorize

        // Reveal active cells
        for i in cells.indices where cells[i].isActive {
            cells[i].isRevealed = true
        }

        // After display time, switch to recall
        displayTimer?.cancel()
        displayTimer = Task { @MainActor in
            try? await Task.sleep(for: .seconds(config.displayTime))
            guard phase == .memorize else { return }

            // Hide all cells
            for i in cells.indices {
                cells[i].isRevealed = false
            }
            phase = .recall
        }
    }

    private func revealAll() {
        for i in cells.indices {
            cells[i].isRevealed = true
        }
    }

    // MARK: - Leaderboard

    private func saveScore() {
        let entry = LeaderboardEntry(round: round)
        leaderboard.append(entry)
        leaderboard.sort()
        if leaderboard.count > 20 {
            leaderboard = Array(leaderboard.prefix(20))
        }
        persistLeaderboard()

        // Submit to Game Center
        Task {
            await GameCenterManager.shared.submitScore(round)
        }
    }

    private func loadLeaderboard() {
        guard let data = UserDefaults.standard.data(forKey: leaderboardKey),
              let entries = try? JSONDecoder().decode([LeaderboardEntry].self, from: data) else { return }
        leaderboard = entries.sorted()
    }

    private func persistLeaderboard() {
        guard let data = try? JSONEncoder().encode(leaderboard) else { return }
        UserDefaults.standard.set(data, forKey: leaderboardKey)
    }
}
