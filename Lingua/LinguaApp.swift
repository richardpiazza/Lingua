import Occurrence
import SwiftUI
import TelemetryClient

@main
struct LinguaApp: App {

    #if os(macOS)
    @NSApplicationDelegateAdaptor private var delegate: LinguaAppDelegate
    #endif

    @State private var storageContainer: StorageContainer? = (try? StorageContainer.make())
    @State private var showCreate: Bool = false
    @State private var showImport: Bool = false
    @State private var showExport: Bool = false

    init() {
        Occurrence.bootstrap()

        let config = TelemetryManagerConfiguration(appID: "A7F887D8-1C46-4A69-BAC5-632ACF4EA5AA")
        TelemetryDeck.initialize(config: config)
        TelemetryDeck.signal("Application Launched")
    }

    var body: some Scene {
        WindowGroup {
            MainWindow(
                storageContainer: $storageContainer,
                showCreate: $showCreate,
                showImport: $showImport,
                showExport: $showExport,
            )
        }
        .commands {
            CommandGroup(before: .newItem) {
                Button {
                    showCreate = true
                } label: {
                    Label("New Expression", systemImage: "plus")
                }
                .keyboardShortcut(KeyEquivalent("N"), modifiers: [.command, .option])
                .disabled(storageContainer == nil)
            }

            CatalogCommands(
                storageContainer: $storageContainer,
                showImport: $showImport,
                showExport: $showExport,
            )
        }
    }
}

#if os(macOS)
class LinguaAppDelegate: NSObject, NSApplicationDelegate {
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        true
    }
}
#endif
