import SwiftUI
import Combine
import LocaleSupport
import TranslationCatalog
import Infuse

struct TranslationsView: View {
    
    private let expression: TranslationCatalog.Expression
    private let translationService: TranslationService
    
    @State private var translations: [TranslationCatalog.Translation] = []
    
    init(
        expression: TranslationCatalog.Expression,
        translationService: TranslationService? = nil
    ) {
        self.expression = expression
        if let translationService {
            self.translationService = translationService
        } else {
            @Resource var service: TranslationService
            self.translationService = service
        }
    }
    
    var body: some View {
        VStack {
            ForEach(translations) { translation in
                TranslationView(
                    translation: translation,
                    defaultLanguage: translation.languageCode == expression.defaultLanguage
                )
            }
        }
        .onReceive(translationService.translations(for: expression)) { value in
            translations = value
        }
    }
}

#Preview {
    TranslationsView(
        expression: .preview
    )
}
