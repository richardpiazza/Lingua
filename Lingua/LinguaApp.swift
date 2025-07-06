import SwiftUI
import Occurrence
import TelemetryClient

@main
struct LinguaApp: App {
    
    #if os(macOS)
    @NSApplicationDelegateAdaptor private var delegate: LinguaAppDelegate
    #endif
    
    @State private var storageContainer: StorageContainer? = (try? StorageContainer.make())
    
    init() {
        Occurrence.bootstrap()
        
        let config = TelemetryManagerConfiguration(appID: "A7F887D8-1C46-4A69-BAC5-632ACF4EA5AA")
        TelemetryDeck.initialize(config: config)
        TelemetryDeck.signal("Application Launched")
    }
    
    var body: some Scene {
        WindowGroup {
            MainWindow(
                storageContainer: $storageContainer
            )
        }
        .commands {
            CatalogCommands(
                storageContainer: $storageContainer
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
