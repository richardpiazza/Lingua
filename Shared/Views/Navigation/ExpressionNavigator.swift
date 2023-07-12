import SwiftUI
import Combine
import TranslationCatalog
import LocaleSupport
import CodeQuickKit

struct ExpressionNavigator: View {
    
    private let expressionService: ExpressionService
    private var publisher: AnyPublisher<[Expression], Never>!
    
    @State private var expressions: [Expression] = []
    @State private var selectedExpressionId: Expression.ID?
    @State private var showCreate: Bool = false
    
    init(expressionService: ExpressionService? = nil) {
        if let service = expressionService {
            self.expressionService = service
        } else {
            @Dependency var dependency: ExpressionService
            self.expressionService = dependency
        }
        
        publisher = self.expressionService
            .expressions
            .map { collection in
                collection.sorted(by: \.name)
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    var body: some View {
        List(expressions, id: \.self, selection: $selectedExpressionId) { expression in
            NavigationLink(value: expression) {
                ListedExpressionView(expression: expression)
                    .padding(8)
            }
        }
//        .onDelete(perform: viewModel.deleteExpressions)
        .navigationDestination(for: Expression.self, destination: { expression in
            TranslationNavigator(viewModel: .init(expression: expression))
        })
        .onReceive(publisher, perform: { value in
            expressions = value
        })
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
        NavigationStack {
            ExpressionNavigator(expressionService: EmulatedExpressionService())
        }
    }
}
