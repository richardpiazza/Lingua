import SwiftUI

@main
struct LinguaApp: App {
//    let persistenceController = PersistenceController.shared
//            ContentView()
//                .environment(\.managedObjectContext, persistenceController.container.viewContext)
    
    var body: some Scene {
        WindowGroup {
            MainWindow()
                .environmentObject(AppEnvironment())
        }
    }
}
