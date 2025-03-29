import LocaleSupport
import SwiftUI
import TranslationCatalog

struct ModifyTranslationView: View {
    
    enum Action {
        case cancel
        case delete
        case save(TranslationCatalog.Translation)
    }
    
    private let translation: TranslationCatalog.Translation?
    private let action: (Action) -> Void
    
    @State private var languageCode: LanguageCode = .default
    @State private var scriptCode: ScriptCode?
    @State private var regionCode: RegionCode?
    @State private var value: String = ""
    @State private var confirmDelete: Bool = false
    
    private let languages: [LanguageCode] = LanguageCode.allCases.sorted(by: { $0.name < $1.name })
    private let scripts: [ScriptCode] = ScriptCode.allCases.sorted(by: { $0.name < $1.name })
    private let regions: [RegionCode] = RegionCode.allCases.sorted(by: { $0.name < $1.name })
    
    private var localeIdentifier: Locale.Identifier {
        var output = languageCode.rawValue
        if let scriptCode = scriptCode?.rawValue {
            output += "-\(scriptCode)"
        }
        if let regionCode = regionCode?.rawValue {
            output += "_\(regionCode)"
        }
        return output
    }
    
    private var locale: Locale {
        Locale(identifier: localeIdentifier)
    }
    
    init(
        translation: TranslationCatalog.Translation?,
        action: @escaping (Action) -> Void
    ) {
        self.translation = translation
        self.action = action
        
        if let translation {
            _languageCode = State(wrappedValue: translation.languageCode)
            _scriptCode = State(wrappedValue: translation.scriptCode)
            _regionCode = State(wrappedValue: translation.regionCode)
            _value = State(wrappedValue: translation.value)
        }
    }
    
    var body: some View {
        VStack(spacing: 20.0) {
            Text("Locale")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Form {
                Picker("Language Code", selection: $languageCode) {
                    ForEach(languages) { code in
                        Text("\(code.name) (\(code.rawValue))").tag(code)
                    }
                }
                
                Picker("Script Code", selection: $scriptCode) {
                    Text("").tag(ScriptCode?.none)
                    
                    ForEach(scripts) { code in
                        Text("\(code.name) (\(code.rawValue))").tag(code as Optional<ScriptCode>)
                    }
                }
                
                Picker("Region Code", selection: $regionCode) {
                    Text("").tag(RegionCode?.none)
                    
                    ForEach(regions) { code in
                        Text("\(code.name) (\(code.rawValue))").tag(code as Optional<RegionCode>)
                    }
                }
            }
            
            HStack(alignment: .firstTextBaseline) {
                Text("Identifier:")
                    .font(.subheadline)
                
                Text(localeIdentifier)
                
                if let flag = locale.flag {
                    Text(flag)
                }
                
                Spacer()
            }
            
            VStack(alignment: .leading) {
                Text("Translated Value")
                    .font(.headline)
                
                TextEditor(text: $value)
                    .frame(minHeight: 200)
            }
            
            HStack {
                Button {
                    action(.cancel)
                } label: {
                    Text("Cancel")
                }
                
                if translation != nil {
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
                                action(.delete)
                            })
                        )
                    })
                }
                
                Button {
                    let translation = TranslationCatalog.Translation(
                        languageCode: languageCode,
                        scriptCode: scriptCode,
                        regionCode: regionCode,
                        value: value
                    )
                    action(.save(translation))
                } label: {
                    Text("Save")
                }
                .disabled(value.isEmpty)
            }
        }
        .padding()
        .frame(minWidth: 350)
    }
}

#Preview {
    ModifyTranslationView(
        translation: nil
    ) { _ in
    }
}
