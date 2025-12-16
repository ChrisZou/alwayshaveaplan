import SwiftUI
import EventKit

struct BigDisplayView: View {
    let events: [EKEvent]

    var body: some View {
        ZStack {
            Color.black.opacity(0.6)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                Text("当前日程")
                    .font(.system(size: 36, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.9))

                VStack(alignment: .leading, spacing: 12) {
                    ForEach(events, id: \.eventIdentifier) { event in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(event.title ?? "(无标题)")
                                .font(.system(size: 44, weight: .bold))
                                .foregroundStyle(.white)
                                .lineLimit(2)
                            Text(timeRange(for: event))
                                .font(.system(size: 20, weight: .medium))
                                .foregroundStyle(.white.opacity(0.8))
                        }
                        .padding(.vertical, 6)
                    }
                }
                .padding(32)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white.opacity(0.08))
                )
            }
            .padding(60)
        }
    }

    private func timeRange(for event: EKEvent) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return "\(formatter.string(from: event.startDate)) - \(formatter.string(from: event.endDate))"
    }
}

