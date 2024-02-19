import SwiftUI
import Occurrence
import Infuse

@main
struct LinguaApp: App {
    
    #if os(macOS)
    @NSApplicationDelegateAdaptor private var delegate: LinguaAppDelegate
    #endif
    
    init() {
        Occurrence.bootstrap()
        ResourceCache.shared.configure(with: Dependencies())
    }
    
    var body: some Scene {
        WindowGroup {
            MainWindow()
        }
        .commands {
            CatalogCommands()
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
