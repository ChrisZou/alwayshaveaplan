import EventKit
import SwiftUI

// MARK: - Color Theme
extension Color {
    // Warm neutrals
    static let stone50 = Color(red: 0.98, green: 0.98, blue: 0.976)
    static let stone100 = Color(red: 0.96, green: 0.96, blue: 0.953)
    static let stone200 = Color(red: 0.906, green: 0.898, blue: 0.894)
    static let stone300 = Color(red: 0.839, green: 0.827, blue: 0.82)
    static let stone400 = Color(red: 0.659, green: 0.635, blue: 0.62)
    static let stone500 = Color(red: 0.471, green: 0.443, blue: 0.424)
    static let stone600 = Color(red: 0.341, green: 0.325, blue: 0.306)
    static let stone700 = Color(red: 0.267, green: 0.251, blue: 0.235)
    static let stone800 = Color(red: 0.161, green: 0.145, blue: 0.141)

    // Primary accent - Warm coral
    static let coral400 = Color(red: 1.0, green: 0.541, blue: 0.42)
    static let coral500 = Color(red: 0.957, green: 0.427, blue: 0.29)
    static let coral600 = Color(red: 0.886, green: 0.329, blue: 0.208)

    // Secondary - Sage green
    static let sage50 = Color(red: 0.965, green: 0.969, blue: 0.957)
    static let sage200 = Color(red: 0.831, green: 0.855, blue: 0.776)
    static let sage400 = Color(red: 0.588, green: 0.651, blue: 0.478)
    static let sage500 = Color(red: 0.478, green: 0.549, blue: 0.365)
    static let sage600 = Color(red: 0.373, green: 0.435, blue: 0.282)
    static let sage700 = Color(red: 0.29, green: 0.341, blue: 0.227)
}

// MARK: - Main View
struct FloatingPromptView: View {
    @ObservedObject var model: FloatingPromptModel
    let onCheck: () -> Void

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [Color.white, Color(red: 0.992, green: 0.988, blue: 0.98), Color(red: 0.98, green: 0.973, blue: 0.961)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            // Decorative gradient orbs
            GeometryReader { geometry in
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color.coral500.opacity(0.08), Color.clear],
                            center: .center,
                            startRadius: 0,
                            endRadius: geometry.size.width * 0.4
                        )
                    )
                    .frame(width: geometry.size.width * 0.7, height: geometry.size.width * 0.7)
                    .offset(x: geometry.size.width * 0.4, y: -geometry.size.height * 0.2)

                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color.sage500.opacity(0.1), Color.clear],
                            center: .center,
                            startRadius: 0,
                            endRadius: geometry.size.width * 0.35
                        )
                    )
                    .frame(width: geometry.size.width * 0.6, height: geometry.size.width * 0.6)
                    .offset(x: -geometry.size.width * 0.15, y: geometry.size.height * 0.5)
            }

            // Main content
            if model.currentEvents.isEmpty {
                NoEventsView(onCheck: onCheck)
            } else if let event = model.currentEvents.first {
                EventView(event: event)
            }

            // Time display
            VStack {
                HStack {
                    Spacer()
                    Text(currentTimeString)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.stone400)
                        .monospacedDigit()
                        .padding(.top, 24)
                        .padding(.trailing, 28)
                }
                Spacer()
            }
        }
    }

    private var currentTimeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: Date())
    }
}

// MARK: - No Events View
struct NoEventsView: View {
    let onCheck: () -> Void
    @State private var appeared = false

    var body: some View {
        ZStack {
            // Background question mark
            Text("?")
                .font(.system(size: 280, weight: .black, design: .serif))
                .foregroundColor(.coral500.opacity(0.04))

            VStack(spacing: 0) {
                Spacer()

                Text("你想干什么？")
                    .font(.system(size: 84, weight: .bold, design: .rounded))
                    .foregroundColor(.stone800)
                    .multilineTextAlignment(.center)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 20)
                    .animation(.easeOut(duration: 0.6), value: appeared)

                Text("别着急，好好想一想，当前最重要的事情是什么？")
                    .font(.system(size: 24, weight: .regular))
                    .foregroundColor(.stone500)
                    .multilineTextAlignment(.center)
                    .padding(.top, 32)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 15)
                    .animation(.easeOut(duration: 0.6).delay(0.1), value: appeared)

                Spacer()

                Button(action: onCheck) {
                    HStack(spacing: 10) {
                        Image(systemName: "calendar")
                            .font(.system(size: 18, weight: .semibold))
                        Text("检查日程")
                            .font(.system(size: 18, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(
                            colors: [.coral500, .coral600],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .cornerRadius(14)
                    .shadow(color: .coral500.opacity(0.25), radius: 15, x: 0, y: 4)
                    .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                }
                .buttonStyle(.plain)
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 20)
                .animation(.easeOut(duration: 0.6).delay(0.2), value: appeared)

                Spacer()
            }
            .padding(40)
        }
        .onAppear {
            appeared = true
        }
    }
}

// MARK: - Event View
struct EventView: View {
    let event: EKEvent
    @State private var appeared = false

    var body: some View {
        ZStack {
            // Event card - centered
            VStack(alignment: .center, spacing: 20) {
                Text(event.title ?? "(无标题)")
                    .font(.system(size: 38, weight: .bold, design: .serif))
                    .foregroundColor(.stone800)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
                    .fixedSize(horizontal: false, vertical: true)

                // Time range
                HStack(spacing: 12) {
                    TimeBadge(time: formatTime(event.startDate), showIcon: true)
                    Text("→")
                        .foregroundColor(.stone300)
                        .font(.system(size: 14))
                    TimeBadge(time: formatTime(event.endDate), showIcon: false)
                }
                .padding(.bottom, 32)

                // Progress section
                VStack(spacing: 10) {
                    HStack {
                        Text("进度")
                            .font(.system(size: 13))
                            .foregroundColor(.stone500)
                        Spacer()
                        Text("\(Int(progressPercentage))%")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.coral600)
                            .monospacedDigit()
                    }

                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.stone100)
                                .frame(height: 8)

                            RoundedRectangle(cornerRadius: 4)
                                .fill(
                                    LinearGradient(
                                        colors: [.sage400, .coral400],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: geometry.size.width * progressPercentage / 100, height: 8)
                        }
                    }
                    .frame(height: 8)
                }

                // Remaining time
                HStack {
                    Spacer()
                    Text("还剩 ")
                        .foregroundColor(.stone500)
                    + Text(remainingTimeString)
                        .foregroundColor(.coral600)
                        .fontWeight(.semibold)
                    Spacer()
                }
                .font(.system(size: 14))
                .padding(.top, 8)
            }
            .frame(maxWidth: 700)
            .padding(.horizontal, 40)
            .padding(.vertical, 44)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 4)
                    .shadow(color: .black.opacity(0.06), radius: 20, x: 0, y: 10)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.black.opacity(0.06), lineWidth: 1)
            )
            .opacity(appeared ? 1 : 0)
            .scaleEffect(appeared ? 1 : 0.95)
            .animation(.easeOut(duration: 0.5), value: appeared)

            // Header - absolute positioned at top
            VStack {
                HStack {
                    HStack(spacing: 8) {
                        Circle()
                            .fill(Color.sage500)
                            .frame(width: 8, height: 8)
                        Text("当前日程")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.sage600)
                            .tracking(2)
                            .textCase(.uppercase)
                    }
                    Spacer()
                }
                .padding(.horizontal, 32)
                .padding(.top, 24)
                Spacer()
            }
        }
        .onAppear {
            appeared = true
        }
    }

    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }

    private var progressPercentage: Double {
        let now = Date()
        let totalDuration = event.endDate.timeIntervalSince(event.startDate)
        let elapsed = now.timeIntervalSince(event.startDate)

        guard totalDuration > 0 else { return 0 }
        return min(max(elapsed / totalDuration * 100, 0), 100)
    }

    private var remainingTimeString: String {
        let now = Date()
        let remaining = event.endDate.timeIntervalSince(now)

        guard remaining > 0 else { return "已结束" }

        let minutes = Int(remaining / 60)
        if minutes >= 60 {
            let hours = minutes / 60
            let mins = minutes % 60
            if mins == 0 {
                return "\(hours) 小时"
            }
            return "\(hours) 小时 \(mins) 分钟"
        }
        return "\(minutes) 分钟"
    }
}

// MARK: - Time Badge Component
struct TimeBadge: View {
    let time: String
    let showIcon: Bool

    var body: some View {
        HStack(spacing: 6) {
            if showIcon {
                Image(systemName: "clock")
                    .font(.system(size: 14))
                    .opacity(0.7)
            }
            Text(time)
                .font(.system(size: 15, weight: .medium))
                .monospacedDigit()
        }
        .foregroundColor(.sage700)
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(Color.sage50)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.sage200, lineWidth: 1)
        )
        .cornerRadius(10)
    }
}
