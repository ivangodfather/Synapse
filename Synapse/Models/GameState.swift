import Foundation

/// Represents the current phase of a game round
enum GamePhase: Equatable {
    case idle
    case memorize    // Grid is showing the pattern
    case recall      // Player must tap the correct cells
    case success     // Player got it right — brief celebration
    case gameOver    // Player made a mistake
}

/// Represents a single cell in the grid
struct Cell: Identifiable, Equatable {
    let id: Int          // Index in the grid (0..<gridSize²)
    var isActive: Bool   // Part of the pattern to memorize
    var isRevealed: Bool // Currently showing (during memorize phase)
    var isTapped: Bool   // Player has tapped this cell
}

/// Difficulty parameters for each round
struct RoundConfig: Equatable {
    let gridSize: Int        // 2, 3, 4, or 5
    let activeCells: Int     // How many cells flash
    let displayTime: Double  // Seconds the pattern is shown

    /// Generates a round config based on the current round number
    static func forRound(_ round: Int) -> RoundConfig {
        switch round {
        case 1...3:
            return RoundConfig(gridSize: 2, activeCells: min(1 + round - 1, 3), displayTime: 1.5)
        case 4...7:
            return RoundConfig(gridSize: 3, activeCells: min(2 + round - 4, 5), displayTime: 1.5)
        case 8...12:
            return RoundConfig(gridSize: 4, activeCells: min(3 + round - 8, 8), displayTime: 1.5)
        default:
            let extra = round - 13
            return RoundConfig(gridSize: 5, activeCells: min(4 + extra, 12), displayTime: 1.5)
        }
    }
}

/// A single leaderboard entry
struct LeaderboardEntry: Identifiable, Codable, Comparable {
    let id: UUID
    let round: Int
    let date: Date

    init(round: Int, date: Date = .now) {
        self.id = UUID()
        self.round = round
        self.date = date
    }

    static func < (lhs: LeaderboardEntry, rhs: LeaderboardEntry) -> Bool {
        lhs.round > rhs.round // Higher rounds first
    }
}
