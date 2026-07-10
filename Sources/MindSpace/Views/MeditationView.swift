import SwiftUI

struct MeditationView: View {
    @EnvironmentObject var timer: MeditationTimer

    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                Spacer()

                // Circular timer
                ZStack {
                    Circle()
                        .stroke(Color(hex: "1E1E2E"), lineWidth: 12)
                        .frame(width: 240, height: 240)

                    Circle()
                        .trim(from: 0, to: timer.progress)
                        .stroke(
                            Color(hex: "7C3AED"),
                            style: StrokeStyle(lineWidth: 12, lineCap: .round)
                        )
                        .frame(width: 240, height: 240)
                        .rotationEffect(.degrees(-90))
                        .animation(.linear(duration: 1), value: timer.progress)

                    VStack(spacing: 4) {
                        Text(timer.timeString)
                            .font(.system(size: 52, weight: .thin, design: .monospaced))
                            .foregroundStyle(.white)

                        Text("remaining")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                // Breathing guide
                if timer.isRunning {
                    BreathingCircle()
                        .frame(width: 80, height: 80)
                        .transition(.scale.combined(with: .opacity))
                }

                // Duration picker
                if !timer.isRunning {
                    VStack(spacing: 8) {
                        Text("Duration")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        HStack(spacing: 8) {
                            ForEach(timer.availableDurations, id: \.self) { mins in
                                Button {
                                    timer.selectedDuration = mins
                                    timer.secondsRemaining = mins * 60
                                } label: {
                                    Text("\(mins)m")
                                        .font(.subheadline.bold())
                                        .frame(width: 48, height: 36)
                                        .background(
                                            timer.selectedDuration == mins
                                                ? Color(hex: "7C3AED")
                                                : Color(hex: "1E1E2E")
                                        )
                                        .foregroundStyle(.white)
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                }
                            }
                        }
                    }
                    .transition(.opacity)
                }

                // Controls
                HStack(spacing: 24) {
                    Button {
                        timer.reset()
                    } label: {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.title2)
                            .frame(width: 56, height: 56)
                            .background(Color(hex: "1E1E2E"))
                            .foregroundStyle(.white)
                            .clipShape(Circle())
                    }

                    Button {
                        if timer.isRunning {
                            timer.pause()
                        } else {
                            timer.start()
                        }
                    } label: {
                        Image(systemName: timer.isRunning ? "pause.fill" : "play.fill")
                            .font(.title)
                            .frame(width: 72, height: 72)
                            .background(Color(hex: "7C3AED"))
                            .foregroundStyle(.white)
                            .clipShape(Circle())
                    }
                }

                Spacer()

                // Session stats
                HStack(spacing: 40) {
                    StatPill(title: "Sessions", value: "\(timer.sessionsCompleted)", icon: "checkmark.circle")
                    StatPill(title: "Minutes", value: "\(timer.totalMinutes)", icon: "clock")
                }
                .padding(.bottom, 20)
            }
            .navigationTitle("Breathe")
        }
    }
}

struct BreathingCircle: View {
    @State private var scale = 1.0

    var body: some View {
        Circle()
            .fill(Color(hex: "7C3AED").opacity(0.3))
            .scaleEffect(scale)
            .onAppear {
                withAnimation(.easeInOut(duration: 4).repeatForever(autoreverses: true)) {
                    scale = 1.4
                }
            }
    }
}

struct StatPill: View {
    let title: String
    let value: String
    let icon: String

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .foregroundStyle(Color(hex: "7C3AED"))
            Text(value)
                .font(.title2.bold())
                .foregroundStyle(.white)
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}
