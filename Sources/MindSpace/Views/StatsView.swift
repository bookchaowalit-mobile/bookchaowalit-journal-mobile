import SwiftUI
import MindSpaceCore

struct StatsView: View {
    @EnvironmentObject var store: JournalStore
    @EnvironmentObject var timer: MeditationTimer

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Meditation stats card
                    VStack(spacing: 16) {
                        HStack {
                            Image(systemName: "wind")
                                .foregroundStyle(Color(hex: "7C3AED"))
                            Text("Meditation")
                                .font(.headline)
                                .foregroundStyle(.white)
                            Spacer()
                        }

                        HStack(spacing: 20) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("\(timer.sessionsCompleted)")
                                    .font(.system(size: 36, weight: .bold))
                                    .foregroundStyle(Color(hex: "7C3AED"))
                                Text("Sessions")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }

                            Divider()
                                .frame(height: 50)

                            VStack(alignment: .leading, spacing: 4) {
                                Text("\(timer.totalMinutes)")
                                    .font(.system(size: 36, weight: .bold))
                                    .foregroundStyle(Color(hex: "7C3AED"))
                                Text("Minutes")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()
                        }
                    }
                    .padding()
                    .background(Color(hex: "1E1E2E"))
                    .clipShape(RoundedRectangle(cornerRadius: 16))

                    // Journal streak card
                    VStack(spacing: 16) {
                        HStack {
                            Image(systemName: "flame")
                                .foregroundStyle(.orange)
                            Text("Journal Streak")
                                .font(.headline)
                                .foregroundStyle(.white)
                            Spacer()
                        }

                        HStack(alignment: .firstTextBaseline, spacing: 8) {
                            Text("\(store.streakDays)")
                                .font(.system(size: 48, weight: .bold))
                                .foregroundStyle(.orange)
                            Text("days")
                                .font(.title3)
                                .foregroundStyle(.secondary)
                            Spacer()
                        }

                        Text("Keep writing every day to maintain your streak!")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding()
                    .background(Color(hex: "1E1E2E"))
                    .clipShape(RoundedRectangle(cornerRadius: 16))

                    // Mood distribution
                    if !store.entries.isEmpty {
                        VStack(spacing: 16) {
                            HStack {
                                Image(systemName: "face.smiling")
                                    .foregroundStyle(Color(hex: "7C3AED"))
                                Text("Mood Distribution")
                                    .font(.headline)
                                    .foregroundStyle(.white)
                                Spacer()
                            }

                            let total = store.entries.count
                            ForEach(Mood.allCases) { mood in
                                let count = store.moodCounts[mood] ?? 0
                                let percentage = Double(count) / Double(total)

                                HStack(spacing: 12) {
                                    Text(mood.emoji)
                                        .font(.title3)

                                    Text(mood.rawValue)
                                        .font(.subheadline)
                                        .foregroundStyle(.white)
                                        .frame(width: 50, alignment: .leading)

                                    GeometryReader { geo in
                                        ZStack(alignment: .leading) {
                                            RoundedRectangle(cornerRadius: 4)
                                                .fill(Color(hex: "1E1E2E"))
                                                .frame(height: 24)

                                            RoundedRectangle(cornerRadius: 4)
                                                .fill(mood.color)
                                                .frame(width: geo.size.width * percentage, height: 24)
                                        }
                                    }
                                    .frame(height: 24)

                                    Text("\(count)")
                                        .font(.caption.bold())
                                        .foregroundStyle(.secondary)
                                        .frame(width: 30, alignment: .trailing)
                                }
                            }
                        }
                        .padding()
                        .background(Color(hex: "1E1E2E"))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }

                    // Total entries
                    VStack(spacing: 8) {
                        Text("\(store.entries.count)")
                            .font(.system(size: 48, weight: .bold))
                            .foregroundStyle(Color(hex: "7C3AED"))
                        Text("Total Journal Entries")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(hex: "1E1E2E"))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .padding()
            }
            .navigationTitle("Stats")
        }
    }
}
