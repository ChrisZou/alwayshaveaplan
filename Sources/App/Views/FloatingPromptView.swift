import EventKit
import SwiftUI

struct FloatingPromptView: View {
  @ObservedObject var model: FloatingPromptModel
  let onCheck: () -> Void

  var body: some View {
    VStack(spacing: 18) {
      Text(titleText)
        .font(.system(size: 34, weight: .semibold))
        .foregroundStyle(.primary)
        .multilineTextAlignment(.center)

      if model.currentEvents.isEmpty {
        Text("没有正在进行的日程")
          .font(.system(size: 18))
          .foregroundStyle(.secondary)

        Button(action: onCheck) {
          Text("检查日程")
            .font(.system(size: 18, weight: .semibold))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
        }
        .buttonStyle(.borderedProminent)
      }
    }
    .padding(24)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
  }

  private var titleText: String {
    if model.currentEvents.isEmpty {
      return "你想干什么？"
    }
    let titles = model.currentEvents.map { ($0.title?.isEmpty == false) ? $0.title! : "(无标题)" }
    return titles.joined(separator: "\n")
  }
}
