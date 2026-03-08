import SwiftUI

struct CellView: View {
    let cell: Cell
    let phase: GamePhase
    let gridSize: Int

    private var cellSize: CGFloat {
        switch gridSize {
        case 2: return 120
        case 3: return 90
        case 4: return 72
        case 5: return 58
        default: return 60
        }
    }

    private var backgroundColor: Color {
        if cell.isRevealed && cell.isActive {
            // Memorize phase — show active cells
            return .cyan
        } else if cell.isTapped {
            if cell.isActive {
                return .green   // Correct tap
            } else {
                return .red     // Wrong tap
            }
        } else if phase == .gameOver && cell.isActive && !cell.isTapped {
            // Show missed cells on game over
            return .cyan.opacity(0.4)
        } else {
            return Color.white.opacity(0.08)
        }
    }

    private var borderColor: Color {
        if cell.isRevealed && cell.isActive {
            return .cyan
        } else if cell.isTapped && cell.isActive {
            return .green
        } else if cell.isTapped && !cell.isActive {
            return .red
        } else {
            return Color.white.opacity(0.15)
        }
    }

    var body: some View {
        RoundedRectangle(cornerRadius: gridSize <= 3 ? 16 : 12)
            .fill(backgroundColor)
            .overlay(
                RoundedRectangle(cornerRadius: gridSize <= 3 ? 16 : 12)
                    .stroke(borderColor, lineWidth: 2)
            )
            .frame(height: cellSize)
            .shadow(
                color: cell.isRevealed && cell.isActive ? .cyan.opacity(0.5) : .clear,
                radius: 8
            )
            .scaleEffect(cell.isTapped ? 0.92 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: cell.isTapped)
            .animation(.easeInOut(duration: 0.3), value: cell.isRevealed)
    }
}

#Preview {
    HStack {
        CellView(cell: Cell(id: 0, isActive: true, isRevealed: true, isTapped: false), phase: .memorize, gridSize: 3)
        CellView(cell: Cell(id: 1, isActive: false, isRevealed: false, isTapped: false), phase: .recall, gridSize: 3)
        CellView(cell: Cell(id: 2, isActive: true, isRevealed: false, isTapped: true), phase: .recall, gridSize: 3)
    }
    .padding()
    .background(.black)
}
