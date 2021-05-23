import SwiftUI

struct MainWindow: View {
    @EnvironmentObject private var appEnvironment: AppEnvironment
    
    var body: some View {
        NavigationView {
            ProjectNavigator(viewModel: .init(appEnvironment: appEnvironment))
            
            ExpressionNavigator(viewModel: .init(appEnvironment: appEnvironment))
            
            if let id = appEnvironment.selectedExpression {
                TranslationNavigator(viewModel: .init(id: id))
            } else {
                NoSelectedExpressionView()
            }
        }
    }
}

struct MainWindow_Previews: PreviewProvider {
    static var previews: some View {
        MainWindow()
            .environmentObject(AppEnvironment.default)
    }
}
