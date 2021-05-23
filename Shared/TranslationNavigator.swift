import SwiftUI
import TranslationCatalog

struct TranslationNavigator: View {
    
    class ViewModel: ObservableObject {
        let appEnvironment: AppEnvironment
        let id: Expression.ID
        
        var expression: Expression
        
        init(appEnvironment: AppEnvironment = .default, id: Expression.ID) {
            self.appEnvironment = appEnvironment
            self.id = id
            
            expression = (try? appEnvironment.catalog.expression(id)) ?? .preview
        }
    }
    
    @EnvironmentObject private var appEnvironment: AppEnvironment
    @StateObject var viewModel: ViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20.0) {
                ExpressionView(viewModel: .init(appEnvironment: appEnvironment, expression: viewModel.expression))
                
                Divider()
            }
            .padding()
        }
    }
}

struct TranslationNavigator_Previews: PreviewProvider {
    static var previews: some View {
        TranslationNavigator(viewModel: .init(id: .zero))
            .environmentObject(AppEnvironment.default)
    }
}
