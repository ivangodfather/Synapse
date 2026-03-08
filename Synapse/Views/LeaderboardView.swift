import SwiftUI

struct LeaderboardView: View {
    let entries: [LeaderboardEntry]
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [.black, Color(hex: "1a1a2e")],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                if entries.isEmpty {
                    VStack(spacing: 16) {
                        Text("🏆")
                            .font(.system(size: 48))
                        Text("No scores yet")
                            .font(.title3.weight(.semibold))
                            .foregroundColor(.gray)
                        Text("Play a game to set your first record!")
                            .font(.subheadline)
                            .foregroundColor(.gray.opacity(0.7))
                    }
                } else {
                    ScrollView {
                        LazyVStack(spacing: 8) {
                            ForEach(Array(entries.enumerated()), id: \.element.id) { index, entry in
                                leaderboardRow(rank: index + 1, entry: entry)
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Leaderboard")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.cyan)
                }
            }
        }
    }

    private func leaderboardRow(rank: Int, entry: LeaderboardEntry) -> some View {
        HStack(spacing: 16) {
            // Rank
            Text(rankEmoji(rank))
                .font(.title2)
                .frame(width: 40)

            // Round info
            VStack(alignment: .leading, spacing: 2) {
                Text("Round \(entry.round)")
                    .font(.headline)
                    .foregroundColor(.white)
                Text(entry.date.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption)
                    .foregroundColor(.gray)
            }

            Spacer()

            // Score
            Text("\(entry.round)")
                .font(.title2.weight(.black))
                .foregroundStyle(
                    rank <= 3
                        ? AnyShapeStyle(LinearGradient(colors: [.cyan, .purple], startPoint: .leading, endPoint: .trailing))
                        : AnyShapeStyle(Color.white)
                )
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.white.opacity(rank == 1 ? 0.1 : 0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(rank == 1 ? Color.cyan.opacity(0.3) : Color.clear, lineWidth: 1)
                )
        )
    }

    private func rankEmoji(_ rank: Int) -> String {
        switch rank {
        case 1: return "🥇"
        case 2: return "🥈"
        case 3: return "🥉"
        default: return "#\(rank)"
        }
    }
}

#Preview {
    LeaderboardView(entries: [
        LeaderboardEntry(round: 15),
        LeaderboardEntry(round: 12),
        LeaderboardEntry(round: 8),
    ])
}
