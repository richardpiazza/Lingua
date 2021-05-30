import SwiftUI

struct MainWindow: View {
    var body: some View {
        NavigationView {
            ProjectNavigator()
            ExpressionNavigator()
            TranslationNavigator()
        }
    }
}

struct MainWindow_Previews: PreviewProvider {
    static var previews: some View {
        MainWindow()
            .environmentObject(StateManager.shared)
            .environmentObject(PersistenceManager.shared)
            .environmentObject(ProjectManager.shared)
            .environmentObject(ExpressionManager.shared)
            .environmentObject(TranslationManager.shared)
    }
}
