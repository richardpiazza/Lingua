import SwiftUI
import Combine
import LocaleSupport
import TranslationCatalog
import CodeQuickKit

struct TranslationsView: View {
    
    class ViewModel: ObservableObject {
        
        @Dependency private var translationService: TranslationService
        private var translationPublisher: AnyCancellable?
        
        let expression: Expression
        let defaultLanguage: LanguageCode
        @Published var translations: [TranslationCatalog.Translation] = []
        
        init(expression: Expression) {
            self.expression = expression
            defaultLanguage = expression.defaultLanguage
            
            translationPublisher = translationService
                .$translations
                .assign(to: \.translations, on: self)
            
            translationService.setExpression(expression)
        }
        
    }
    
    @ObservedObject var viewModel: ViewModel
    @State private var labelWidth: CGFloat = 150
    
    var body: some View {
        VStack {
            ForEach(viewModel.translations) { translation in
                TranslationView(
                    viewModel: .init(
                        expression: viewModel.expression,
                        translation: translation,
                        defaultLanguage: translation.languageCode == viewModel.defaultLanguage
                    ),
                    labelWidth: $labelWidth
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
