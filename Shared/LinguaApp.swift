import SwiftUI

@main
struct LinguaApp: App {
    
    init() {
        DependencyResolver.shared.configure(with: Dependencies())
    }
    
    var body: some Scene {
        WindowGroup {
            MainWindow()
        }
    }
}
