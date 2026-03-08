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
        case 1:
            // Start with 2x2, 2 cells — already a real challenge
            return RoundConfig(gridSize: 2, activeCells: 2, displayTime: 1.2)
        case 2:
            return RoundConfig(gridSize: 2, activeCells: 3, displayTime: 1.0)
        case 3:
            // Jump to 3x3 fast
            return RoundConfig(gridSize: 3, activeCells: 3, displayTime: 1.2)
        case 4:
            return RoundConfig(gridSize: 3, activeCells: 4, displayTime: 1.0)
        case 5:
            return RoundConfig(gridSize: 3, activeCells: 5, displayTime: 0.9)
        case 6:
            return RoundConfig(gridSize: 4, activeCells: 4, displayTime: 1.1)
        case 7:
            return RoundConfig(gridSize: 4, activeCells: 5, displayTime: 1.0)
        case 8:
            return RoundConfig(gridSize: 4, activeCells: 6, displayTime: 0.9)
        case 9:
            return RoundConfig(gridSize: 4, activeCells: 7, displayTime: 0.8)
        case 10:
            return RoundConfig(gridSize: 5, activeCells: 5, displayTime: 1.0)
        case 11:
            return RoundConfig(gridSize: 5, activeCells: 6, displayTime: 0.9)
        case 12:
            return RoundConfig(gridSize: 5, activeCells: 7, displayTime: 0.8)
        default:
            // Beyond round 12: 5x5, more cells, less time — gets brutal
            let extra = round - 12
            let cells = min(7 + extra, 15)
            let time = max(0.8 - Double(extra) * 0.05, 0.4)
            return RoundConfig(gridSize: 5, activeCells: cells, displayTime: time)
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
