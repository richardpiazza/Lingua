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
        
        func deleteExpression() {
        }
        
        func share() {
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
        .navigationTitle(viewModel.expression.name)
        .toolbar {
            ToolbarItemGroup {
                #if os(macOS)
                if case .expression = viewModel.state {
                    Text(viewModel.expression.name)
                        .font(.headline)
                }
                #endif
                
                Spacer()
                
                if case .expression = viewModel.state {
                    Button(action: viewModel.share, label: {
                        Image(systemName: "square.and.arrow.up")
                    })
                    
                    Button(action: viewModel.deleteExpression, label: {
                        Image(systemName: "trash")
                    })
                }
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
