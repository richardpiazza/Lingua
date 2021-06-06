import SwiftUI
import LocaleSupport
import TranslationCatalog

struct TranslationView: View {
    
    class ViewModel: ObservableObject {
        
        var translation: TranslationCatalog.Translation
        @Published var value: String
        
        init(translation: TranslationCatalog.Translation) {
            self.translation = translation
            value = translation.value
        }
        
        var locale: Locale {
            if let region = translation.regionCode {
                return Locale(identifier: "\(translation.languageCode.rawValue)_\(region.rawValue)")
            } else {
                return Locale(identifier: translation.languageCode.rawValue)
            }
        }
        
        var languageName: String {
            if let localized = Locale.current.localizedString(forLanguageCode: translation.languageCode.rawValue) {
                return localized
            } else {
                return locale.identifier
            }
        }
        
        func commitValue() {
            
        }
    }
    
    @ObservedObject var viewModel: ViewModel
    @Binding var labelWidth: CGFloat
    
    var body: some View {
        HStack {
            Text(viewModel.languageName)
                .font(.caption)
                .equalWidth($labelWidth)
            
            if let flag = viewModel.locale.flag {
                Text(flag)
            }
            
            TextField("Translated Value", text: $viewModel.value, onCommit: viewModel.commitValue)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            Spacer()
        }
        .padding(4)
    }
}

struct TranslationView_Previews: PreviewProvider {
    static var previews: some View {
        TranslationView(viewModel: .init(translation: .en), labelWidth: .constant(85.0))
        TranslationView(viewModel: .init(translation: .es), labelWidth: .constant(85.0))
    }
}

extension TranslationCatalog.Translation {
    static var en: Self = .init(languageCode: .en, regionCode: .US, value: "This is an english string.")
    static var es: Self = .init(languageCode: .es, regionCode: .ES, value: "Esta es una cadena inglesa.")
}
