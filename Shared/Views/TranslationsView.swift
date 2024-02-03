import SwiftUI
import Combine
import LocaleSupport
import TranslationCatalog
import Infuse

struct TranslationsView: View {
    
    class ViewModel: ObservableObject {
        
        @Resource private var translationService: TranslationService
        
        let expression: Expression
        let defaultLanguage: LanguageCode
        @Published var translations: [TranslationCatalog.Translation] = []
        
        init(expression: Expression) {
            self.expression = expression
            defaultLanguage = expression.defaultLanguage
            
            translationService
                .translationsPublisher
                .receive(on: DispatchQueue.main)
                .assign(to: &$translations)
            
            translationService.setExpression(expression)
        }
        
    }
    
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        VStack {
            ForEach(viewModel.translations) { translation in
                TranslationView(
                    viewModel: .init(
                        expression: viewModel.expression,
                        translation: translation,
                        defaultLanguage: translation.languageCode == viewModel.defaultLanguage
                    )
                )
            }
        }
    }
}

struct TranslationsView_Previews: PreviewProvider {
    static var previews: some View {
        TranslationsView(viewModel: .init(expression: .preview))
    }
}
