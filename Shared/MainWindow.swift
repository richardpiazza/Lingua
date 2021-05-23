import SwiftUI

struct MainWindow: View {
    @EnvironmentObject private var appEnvironment: AppEnvironment
    
    var body: some View {
        NavigationView {
            ProjectNavigator(viewModel: .init(catalog: appEnvironment.catalog))
            
            ExpressionNavigator(viewModel: .init(catalog: appEnvironment.catalog, contentMode: .catalog))
            
            if let id = appEnvironment.selectedExpression {
                TranslationNavigator(viewModel: .init(catalog: appEnvironment.catalog, id: id))
            } else {
                NoSelectedExpressionView()
            }
        }
    }
}

struct MainWindow_Previews: PreviewProvider {
    static var previews: some View {
        MainWindow()
            .environmentObject(AppEnvironment())
    }
}
