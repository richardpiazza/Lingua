import SwiftUI
import Combine
import TranslationCatalog
import LocaleSupport

struct ExpressionNavigator: View {
    
    class ViewModel: ObservableObject {
        
        @Dependency private var expressionService: ExpressionService
        private var expressionPublisher: AnyCancellable?
        
        @Published var expressions: [Expression] = []
        
        init(contentMode: ContentMode?) {
            expressionPublisher = expressionService
                .$expressions
                .assign(to: \.expressions, on: self)
            
            expressionService.setContentMode(contentMode)
        }
        
        func deleteExpressions(_ indexSet: IndexSet) {
            expressionService.deleteExpressions(indexSet)
        }
    }
    
    @ObservedObject var viewModel: ViewModel
    @State private var selectedExpressionId: Expression.ID?
    @State private var showCreate: Bool = false
    
    init(viewModel: ViewModel = .init(contentMode: .catalog)) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        List {
            ForEach(viewModel.expressions) { expression in
                NavigationLink(
                    destination: TranslationNavigator(viewModel: .init(expression: expression)),
                    tag: expression.id,
                    selection: $selectedExpressionId,
                    label: {
                        ListedExpressionView(expression: expression)
                            .padding(8)
                    })
            }
            .onDelete(perform: viewModel.deleteExpressions)
        }
        .navigationTitle("Lingua")
        #if os(macOS)
        .navigationSubtitle("Localization Catalog")
        #endif
        .toolbar {
            ToolbarItemGroup {
                Button(action: {
                    showCreate.toggle()
                }, label: {
                    Image(systemName: "square.and.pencil")
                })
                .keyboardShortcut(KeyEquivalent("E"), modifiers: .command)
                .sheet(isPresented: $showCreate, content: {
                    CreateExpressionView(show: $showCreate, selectedExpressionId: $selectedExpressionId)
                })
            }
        }
    }
}

struct ExpressionNavigator_Previews: PreviewProvider {
    static var previews: some View {
        ExpressionNavigator()
    }
}
