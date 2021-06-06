import SwiftUI
import LocaleSupport
import TranslationCatalog

struct TranslationsView: View {
    
    class ViewModel: ObservableObject {
        @Dependency private var persistence: PersistenceManager
        
        let expression: Expression
        @Published var translations: [TranslationCatalog.Translation] = []
        
        init(expression: Expression) {
            self.expression = expression
            
            if let catalogTranslations = try? persistence.catalog.translations(matching: GenericTranslationQuery.expressionID(expression.id)) {
                translations = catalogTranslations.sorted(by: { $0.localeIdentifier < $1.localeIdentifier })
            }
        }
        
    }
    
    @ObservedObject var viewModel: ViewModel
    @State private var labelWidth: CGFloat = 100
    
    var body: some View {
        VStack {
            ForEach(viewModel.translations) { translation in
                TranslationView(viewModel: .init(translation: translation), labelWidth: $labelWidth)
            }
        }
    }
}

struct TranslationsView_Previews: PreviewProvider {
    static var previews: some View {
        TranslationsView(viewModel: .init(expression: .preview))
    }
}
