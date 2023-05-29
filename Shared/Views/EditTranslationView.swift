import SwiftUI
import LocaleSupport
import TranslationCatalog
import CodeQuickKit
import Logging

struct EditTranslationView: View {
    
    class ViewModel: ObservableObject {
        
        @Dependency private(set) var logger: Logger
        @Dependency private var translationService: TranslationService
        
        private let expression: Expression
        public private(set) var translation: TranslationCatalog.Translation?
        @Published var languageCode: LanguageCode = .default
        @Published var scriptCode: ScriptCode?
        @Published var regionCode: RegionCode?
        @Published var value: String
        
        var localeIdentifier: Locale.Identifier {
            var output = languageCode.rawValue
            if let scriptCode = self.scriptCode?.rawValue {
                output += "-\(scriptCode)"
            }
            if let regionCode = self.regionCode?.rawValue {
                output += "_\(regionCode)"
            }
            return output
        }
        
        var locale: Locale { Locale(identifier: localeIdentifier) }
        
        var name: String { Locale.current.localizedString(for: locale) }
        
        init(expression: Expression, translation: TranslationCatalog.Translation?) {
            self.expression = expression
            self.translation = translation
            self.value = translation?.value ?? ""
            
            languageCode = translation?.languageCode ?? expression.defaultLanguage
            scriptCode = translation?.scriptCode
            regionCode = translation?.regionCode
        }
        
        func commit() throws {
            if let translation = self.translation {
                var existing = translation
                existing.languageCode = languageCode
                existing.scriptCode = scriptCode
                existing.regionCode = regionCode
                existing.value = value
                do {
                    _ = try translationService.updateTranslation(existing)
                } catch {
                    logger.error("Failed to Update Translation.", error: error)
                    throw error
                }
            } else {
                var new = TranslationCatalog.Translation()
                new.expressionID = expression.id
                new.languageCode = languageCode
                new.scriptCode = scriptCode
                new.regionCode = regionCode
                new.value = value
                do {
                    _ = try translationService.createTranslation(new)
                } catch {
                    logger.error("Failed to Create Translation.", error: error)
                    throw error
                }
            }
        }
        
        func delete() throws {
            guard let id = translation?.id else {
                throw CatalogError.translationID(.zero)
            }
            
            do {
                try translationService.deleteTranslation(id)
            } catch {
                logger.error("Failed to Delete Translation.", error: error)
                throw error
            }
        }
    }
    
    @ObservedObject var viewModel: ViewModel
    @Binding var showEdit: Bool
    @State var confirmDelete: Bool = false
    
    private let languages: [LanguageCode] = LanguageCode.allCases.sorted(by: { $0.name < $1.name })
    private let scripts: [ScriptCode] = ScriptCode.allCases.sorted(by: { $0.name < $1.name })
    private let regions: [RegionCode] = RegionCode.allCases.sorted(by: { $0.name < $1.name })
    
    init(viewModel: ViewModel = .init(expression: .init(), translation: .init()), showEdit: Binding<Bool> = .constant(true)) {
        self.viewModel = viewModel
        self._showEdit = showEdit
    }
    
    var body: some View {
        VStack(spacing: 20.0) {
            Text("Locale")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Form {
                Picker("Language Code", selection: $viewModel.languageCode) {
                    ForEach(languages) { code in
                        Text("\(code.name) (\(code.rawValue))").tag(code)
                    }
                }
                
                Picker("Script Code", selection: $viewModel.scriptCode) {
                    Text("").tag(ScriptCode?.none)
                    
                    ForEach(scripts) { code in
                        Text("\(code.name) (\(code.rawValue))").tag(code as Optional<ScriptCode>)
                    }
                }
                
                Picker("Region Code", selection: $viewModel.regionCode) {
                    Text("").tag(RegionCode?.none)
                    
                    ForEach(regions) { code in
                        Text("\(code.name) (\(code.rawValue))").tag(code as Optional<RegionCode>)
                    }
                }
            }
            
            HStack(alignment: .firstTextBaseline) {
                Text("Identifier:")
                    .font(.subheadline)
                
                Text(viewModel.localeIdentifier)
                
                if let flag = viewModel.locale.flag {
                    Text(flag)
                }
                
                Spacer()
            }
            
            VStack(alignment: .leading) {
                Text("Translated Value")
                    .font(.headline)
                
                TextEditor(text: $viewModel.value)
                    .frame(minHeight: 200)
            }
            
            HStack {
                Button {
                    showEdit.toggle()
                } label: {
                    Text("Cancel")
                }
                
                if viewModel.translation != nil {
                    Button {
                        confirmDelete.toggle()
                    } label: {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    }
                    .alert(isPresented: $confirmDelete, content: {
                        Alert(
                            title: Text("Remove Translation"),
                            message: Text("Are you sure you want to remove this translation from the catalog?"),
                            primaryButton: .cancel(),
                            secondaryButton: .destructive(Text("Remove"), action: {
                                do {
                                    try viewModel.delete()
                                    showEdit.toggle()
                                } catch {
                                }
                            })
                        )
                    })
                }
                
                Button {
                    do {
                        try viewModel.commit()
                        showEdit.toggle()
                    } catch {
                    }
                } label: {
                    Text("Save")
                }
            }
        }
        .padding()
        .frame(minWidth: 350)
    }
}

struct EditTranslationView_Previews: PreviewProvider {
    static var previews: some View {
        EditTranslationView()
    }
}
