import SwiftUI
import CodeQuickKit

@main
struct LinguaApp: App {
    
    init() {
        DependencyCache.shared.configure(with: Dependencies())
    }
    
    var body: some Scene {
        WindowGroup {
            MainWindow()
        }
    }
}
