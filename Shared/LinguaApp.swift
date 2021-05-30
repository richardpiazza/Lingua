import SwiftUI

@main
struct LinguaApp: App {
    let stateManager: StateManager = .shared
    let persistenceManager: PersistenceManager = .shared
    let projectManager: ProjectManager = .shared
    let expressionManager: ExpressionManager = .shared
    let translationManager: TranslationManager = .shared
    
    var body: some Scene {
        WindowGroup {
            MainWindow()
                .environmentObject(stateManager)
                .environmentObject(persistenceManager)
                .environmentObject(projectManager)
                .environmentObject(expressionManager)
                .environmentObject(translationManager)
        }
    }
}
