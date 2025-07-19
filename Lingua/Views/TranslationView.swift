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
    @State private var languageCode: Locale.LanguageCode = .default
    @State private var scriptCode: Locale.Script?
    @State private var regionCode: Locale.Region?

    private let languages: [Locale.LanguageCode] = Locale.LanguageCode.allCases.sorted(by: { $0.name < $1.name })
    private let scripts: [Locale.Script] = Locale.Script.allCases.sorted(by: { $0.name < $1.name })
    private let regions: [Locale.Region] = Locale.Region.allCases.sorted(by: { $0.name < $1.name })

    private var locale: Locale {
        Locale(languageCode: languageCode, script: scriptCode, languageRegion: regionCode)
    }

    private var languageName: String {
        Locale.current.localizedString(forLanguageCode: languageCode.identifier) ?? locale.identifier
    }

    private var modified: Bool {
        guard value == translation.value else {
            return true
        }
        guard languageCode == translation.language else {
            return true
        }
        guard scriptCode == translation.script else {
            return true
        }
        guard regionCode == translation.region else {
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
                    axis: .vertical,
                )
                .textFieldStyle(.roundedBorder)
            } header: {
                Text("Translation")
            }

            Section {
                Picker(selection: $languageCode) {
                    ForEach(languages, id: \.identifier) { code in
                        Text(code.name)
                            .tag(code)
                    }
                } label: {
                    Text("Language Code")
                }

                Picker(selection: $scriptCode) {
                    Text("")
                        .tag(Locale.Script?.none)

                    ForEach(scripts, id: \.identifier) { code in
                        Text(code.name)
                            .tag(code as Locale.Script?)
                    }
                } label: {
                    Text("Script Code")
                }

                Picker(selection: $regionCode) {
                    Text("")
                        .tag(Locale.Region?.none)

                    ForEach(regions, id: \.identifier) { code in
                        Text(code.name)
                            .tag(code as Locale.Region?)
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

                        Text(locale.identifier)

                        if let flag = regionCode?.unicodeFlag {
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
            languageCode = newValue.language
            scriptCode = newValue.script
            regionCode = newValue.region
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
            language: languageCode,
            script: scriptCode,
            region: regionCode,
            value: value,
        )

        action(.save(translation))
    }
}

#Preview {
    NavigationStack {
        TranslationView(
            translation: .settings_es_ES,
        ) { _ in
        }
    }
}
