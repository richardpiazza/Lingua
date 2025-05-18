import LocaleSupport
import SwiftUI
import TranslationCatalog

struct TranslationView: View {
    
    enum Action {
        case cancel
        case save(TranslationCatalog.Translation)
    }
    
    var translation: TranslationCatalog.Translation
    var action: (Action) -> Void
    
    @State private var value: String = ""
    @State private var languageCode: LanguageCode = .default
    @State private var scriptCode: ScriptCode?
    @State private var regionCode: RegionCode?
    
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
    
    private var languageName: String {
        Locale.current.localizedString(forLanguageCode: languageCode.rawValue) ?? locale.identifier
    }
    
    private var modified: Bool {
        guard value == translation.value else {
            return true
        }
        guard languageCode == translation.languageCode else {
            return true
        }
        guard scriptCode == translation.scriptCode else {
            return true
        }
        guard regionCode == translation.regionCode else {
            return true
        }
        
        return false
    }
    
    var body: some View {
        Form {
            Section {
                TextField(
                    "Translated Value",
                    text: $value,
                    axis: .vertical
                )
            } header: {
                Text("Translation")
            }
            
            Section {
                Picker(selection: $languageCode) {
                    ForEach(languages) { code in
                        Text("\(code.name) (\(code.rawValue))")
                            .tag(code)
                    }
                } label: {
                    Text("Language Code")
                }
                
                Picker(selection: $scriptCode) {
                    Text("")
                        .tag(ScriptCode?.none)
                    
                    ForEach(scripts) { code in
                        Text("\(code.name) (\(code.rawValue))")
                            .tag(code as Optional<ScriptCode>)
                    }
                } label: {
                    Text("Script Code")
                }
                
                Picker(selection: $regionCode) {
                    Text("")
                        .tag(RegionCode?.none)
                    
                    ForEach(regions) { code in
                        Text("\(code.name) (\(code.rawValue))")
                            .tag(code as Optional<RegionCode>)
                    }
                } label: {
                    Text("Region Code")
                }
            } header: {
                HStack(alignment: .firstTextBaseline) {
                    Text("Locale")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    HStack(alignment: .firstTextBaseline) {
                        Text(languageName)
                        
                        Text(localeIdentifier)
                        
                        if let flag = locale.flag {
                            Text(flag)
                        }
                    }
                    .font(.caption)
                }
            }
        }
        .formStyle(.grouped)
        .onChange(of: translation, initial: true) { _, newValue in
            value = newValue.value
            languageCode = newValue.languageCode
            scriptCode = newValue.scriptCode
            regionCode = newValue.regionCode
        }
        .toolbar {
            ToolbarItemGroup {
                Button(role: .cancel) {
                    cancel()
                } label: {
                    Text("Cancel")
                }
                
                Button {
                    save()
                } label: {
                    Text("Save")
                }
                .buttonStyle(.borderedProminent)
                .disabled(value.isEmpty || !modified)
            }
        }
    }
    
    private func cancel() {
        action(.cancel)
    }
    
    private func save() {
        let translation = TranslationCatalog.Translation(
            id: translation.id,
            expressionId: translation.expressionId,
            languageCode: languageCode,
            scriptCode: scriptCode,
            regionCode: regionCode,
            value: value
        )
        
        action(.save(translation))
    }
}

#Preview {
    NavigationStack {
        TranslationView(
            translation: .es
        ) { _ in
        }
    }
}
