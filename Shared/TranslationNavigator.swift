import SwiftUI
import TranslationCatalog

struct TranslationNavigator: View {
    
    class ViewModel: ObservableObject {
        
        enum State {
            case noSelection
            case expression(Expression.ID)
        }
        
        let appEnvironment: AppEnvironment
        let state: State
        
        var expression: Expression = .init()
        
        init(appEnvironment: AppEnvironment = .default, state: State = .noSelection) {
            self.appEnvironment = appEnvironment
            self.state = state
            
            if case let .expression(id) = state {
                expression = (try? appEnvironment.catalog.expression(id)) ?? .preview
            }
        }
    }
    
    @EnvironmentObject private var appEnvironment: AppEnvironment
    @StateObject var viewModel: ViewModel
    
    var body: some View {
        ScrollView {
            switch viewModel.state {
            case .noSelection:
                NoSelectedExpressionView()
            case .expression:
                VStack(spacing: 20.0) {
                    ExpressionView(viewModel: .init(appEnvironment: appEnvironment, expression: viewModel.expression))
                    
                    Divider()
                }
                .padding()
            }
        }
    }
}

struct TranslationNavigator_Previews: PreviewProvider {
    static var previews: some View {
        TranslationNavigator(viewModel: .init(state: .expression(.zero)))
            .environmentObject(AppEnvironment.default)
    }
}
