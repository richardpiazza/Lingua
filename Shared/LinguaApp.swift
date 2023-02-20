import SwiftUI
import CodeQuickKit
import Occurrence

@main
struct LinguaApp: App {
    
    init() {
        Occurrence.bootstrap()
        DependencyCache.shared.configure(with: Dependencies())
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
