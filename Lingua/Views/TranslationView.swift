import SwiftUI
import LocaleSupport
import TranslationCatalog
import Infuse

struct TranslationView: View {
    
    private let translation: TranslationCatalog.Translation
    private let defaultLanguage: Bool
    private let translationService: TranslationService
    
    private let columns: [GridItem] = [
        GridItem(.fixed(100)),
        GridItem(.flexible())
    ]
    
    @State private var showEdit: Bool = false
    
    init(
        translation: TranslationCatalog.Translation,
        defaultLanguage: Bool,
        translationService: TranslationService? = nil
    ) {
        self.translation = translation
        self.defaultLanguage = defaultLanguage
        
        if let translationService {
            self.translationService = translationService
        } else {
            @Resource var service: TranslationService
            self.translationService = service
        }
    }
    
    var body: some View {
        LazyVGrid(columns: columns, alignment: .leading) {
            HStack(alignment: .firstTextBaseline) {
                Text(translation.languageName)
                    .font(defaultLanguage ? .headline : .caption)
                
                Text("(\(translation.localeIdentifier))")
                    .font(.caption)
                
                if let flag = translation.locale.flag {
                    Text(flag)
                }
            }
            
            HStack {
                Button(action: {
                    showEdit.toggle()
                }, label: {
                    Image(systemName: "pencil")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 12)
                })
                .buttonStyle(BorderlessButtonStyle())
                
                Text(translation.value)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .sheet(isPresented: $showEdit) {
            ModifyTranslationView(
                translation: translation
            ) { action in
                showEdit = false
                switch action {
                case .cancel:
                    break
                case .delete:
                    deleteTranslation(translation)
                case .save(let translation):
                    saveTranslation(translation)
                }
            }
        }
    }
    
    private func saveTranslation(_ translation: TranslationCatalog.Translation) {
        do {
            try translationService.updateTranslation(translation)
        } catch {
        }
    }
    
    private func deleteTranslation(_ translation: TranslationCatalog.Translation) {
        do {
            try translationService.deleteTranslation(translation.id)
        } catch {
        }
    }
}

#Preview("EN - Default") {
    TranslationView(
        translation: .en,
        defaultLanguage: true
    )
    .frame(width: 400)
}

#Preview("ES - Non-Default") {
    TranslationView(
        translation: .es,
        defaultLanguage: false
    )
    .frame(width: 400)
}
