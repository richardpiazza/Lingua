import SwiftUI
import LocaleSupport
import TranslationCatalog
import Infuse

struct TranslationView: View {
    
    class ViewModel: ObservableObject {
        @Resource private var translationService: TranslationService
        
        let expression: Expression
        @Published var translation: TranslationCatalog.Translation
        let defaultLanguage: Bool
        
        init(expression: Expression, translation: TranslationCatalog.Translation, defaultLanguage: Bool = false) {
            self.expression = expression
            self.translation = translation
            self.defaultLanguage = defaultLanguage
        }
    }
    
    private let columns: [GridItem] = [
        GridItem(.fixed(100)),
        GridItem(.flexible())
    ]
    
    @ObservedObject var viewModel: ViewModel
    @State private var showEdit: Bool = false
    
    var body: some View {
        LazyVGrid(columns: columns, alignment: .leading) {
            HStack(alignment: .firstTextBaseline) {
                Text(viewModel.translation.languageName)
                    .font(viewModel.defaultLanguage ? .headline : .caption)
                
                Text("(\(viewModel.translation.localeIdentifier))")
                    .font(.caption)
                
                if let flag = viewModel.translation.locale.flag {
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
                
                Text(viewModel.translation.value)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .sheet(isPresented: $showEdit, content: {
            EditTranslationView(viewModel: .init(expression: viewModel.expression, translation: viewModel.translation), showEdit: $showEdit)
        })
    }
}

struct TranslationView_Previews: PreviewProvider {
    static var previews: some View {
        TranslationView(viewModel: .init(expression: .init(), translation: .en, defaultLanguage: true))
        TranslationView(viewModel: .init(expression: .init(), translation: .es))
    }
}

extension TranslationCatalog.Translation {
    static var en: Self = .init(languageCode: .en, regionCode: .US, value: "This is an english string.")
    static var es: Self = .init(languageCode: .es, regionCode: .ES, value: "Esta es una cadena inglesa.")
}
