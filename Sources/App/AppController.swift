import AppKit
import Combine

final class AppController: NSObject, ObservableObject {
  private let calendarManager = CalendarManager()
  private var cancellables = Set<AnyCancellable>()
  private let windowManager = WindowManager()
  private var distributedObservers: [NSObjectProtocol] = []
  private var scheduledCheck: DispatchWorkItem?
  private var periodicTimer: Timer?

  override init() {
    super.init()
    setupUnlockObservers()
    startPeriodicChecks()

    // First check immediately; if Calendar permission isn't granted yet,
    // this will show the prompt and then re-check once the user responds.
    scheduleUnlockCheck(
      reason: "initialLaunch", openCalendarIfNoEvents: true, showEventsIfAny: true)
    calendarManager.requestAccessIfNeeded { [weak self] _ in
      self?.scheduleUnlockCheck(
        reason: "calendarPermissionChanged", openCalendarIfNoEvents: true, showEventsIfAny: true)
    }
  }

  func triggerCheck() {
    scheduleUnlockCheck(reason: "manual", openCalendarIfNoEvents: false, showEventsIfAny: true)
  }

  private func setupUnlockObservers() {
    Log.info("Setting up unlock/wake observers.")
    let center = NSWorkspace.shared.notificationCenter

    center.publisher(for: NSWorkspace.sessionDidBecomeActiveNotification)
      .sink { [weak self] _ in
        Log.info("NSWorkspace.sessionDidBecomeActiveNotification")
        self?.scheduleUnlockCheck(
          reason: "sessionDidBecomeActive", openCalendarIfNoEvents: true, showEventsIfAny: true)
      }
      .store(in: &cancellables)

    center.publisher(for: NSWorkspace.screensDidWakeNotification)
      .sink { [weak self] _ in
        Log.info("NSWorkspace.screensDidWakeNotification")
        self?.scheduleUnlockCheck(
          reason: "screensDidWake", openCalendarIfNoEvents: true, showEventsIfAny: true)
      }
      .store(in: &cancellables)

    if #available(macOS 13.0, *) {
      center.publisher(for: NSWorkspace.didWakeNotification)
        .sink { [weak self] _ in
          Log.info("NSWorkspace.didWakeNotification")
          self?.scheduleUnlockCheck(
            reason: "didWake", openCalendarIfNoEvents: true, showEventsIfAny: true)
        }
        .store(in: &cancellables)
    }

    // More reliable lock/unlock signals.
    let dnc = DistributedNotificationCenter.default()
    distributedObservers.append(
      dnc.addObserver(
        forName: Notification.Name("com.apple.screenIsUnlocked"), object: nil, queue: .main
      ) { [weak self] _ in
        Log.info("Distributed com.apple.screenIsUnlocked")
        self?.scheduleUnlockCheck(
          reason: "screenIsUnlocked", openCalendarIfNoEvents: true, showEventsIfAny: true)
      }
    )
    distributedObservers.append(
      dnc.addObserver(
        forName: Notification.Name("com.apple.screenIsLocked"), object: nil, queue: .main
      ) { _ in
        Log.info("Distributed com.apple.screenIsLocked")
      }
    )
  }

  private func startPeriodicChecks() {
    periodicTimer?.invalidate()
    periodicTimer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
      Log.info("Periodic timer fired")
      self?.scheduleUnlockCheck(
        reason: "periodicTimer", openCalendarIfNoEvents: false, showEventsIfAny: false)
    }
    RunLoop.main.add(periodicTimer!, forMode: .common)
  }

  private func scheduleUnlockCheck(
    reason: String, openCalendarIfNoEvents: Bool, showEventsIfAny: Bool
  ) {
    scheduledCheck?.cancel()
    let item = DispatchWorkItem { [weak self] in
      guard let self else { return }
      self.performCheck(
        reason: reason,
        openCalendarIfNoEvents: openCalendarIfNoEvents,
        exitOnEvent: false,
        showEventsIfAny: showEventsIfAny
      )
    }
    scheduledCheck = item
    Log.info("Scheduling check in 0.5s reason=\(reason)")
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: item)
  }

  private func performCheck(
    reason: String, openCalendarIfNoEvents: Bool, exitOnEvent: Bool, showEventsIfAny: Bool
  ) {
    Log.info("performCheck: checking current events reason=\(reason)")
    calendarManager.fetchCurrentEvents { [weak self] events in
      guard let self else { return }
      DispatchQueue.main.async {
        Log.info("performCheck: events.count=\(events.count)")
        if events.isEmpty {
          self.windowManager.showFloatingPrompt(
            onCheck: { [weak self] in
              Log.info("FloatingPrompt: onCheck tapped")
              self?.performCheck(
                reason: "floatingPromptCheckButton",
                openCalendarIfNoEvents: false,
                exitOnEvent: false,
                showEventsIfAny: true
              )
            }
          )
          self.windowManager.updateFloatingEvents([])
          if openCalendarIfNoEvents {
            self.openCalendarAppBackground()
          }
        } else {
          if showEventsIfAny {
            // Show current events in the same floating window (no extra overlay window).
            self.windowManager.showFloatingEvents(events, autoHideAfter: 10)
          } else {
            // For periodic checks: if there are events, don't show any UI.
            self.windowManager.hideFloatingWindow()
          }
        }
      }
    }
  }

  private func openCalendarAppBackground() {
    let config = NSWorkspace.OpenConfiguration()
    config.activates = false
    config.addsToRecentItems = false
    NSWorkspace.shared.openApplication(
      at: URL(fileURLWithPath: "/System/Applications/Calendar.app"),
      configuration: config,
      completionHandler: nil
    )
  }
}
