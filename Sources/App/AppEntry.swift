import SwiftUI

@main
struct AlwaysHaveAPlanApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            // Hidden anchor window to keep NSApp alive under SwiftPM.
            Color.clear
                .frame(width: 1, height: 1)
                .hidden()
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)

        Settings {
            EmptyView()
        }
        .commands {
            CommandGroup(replacing: .appInfo) {
                Button("AlwaysHaveAPlan") {}
            }
        }
    }
}
