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
    @State private var languageCode: Locale.LanguageCode = .default
    @State private var scriptCode: Locale.Script?
    @State private var regionCode: Locale.Region?
    @State private var translationState: TranslationState = .new

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
        guard translationState == translation.state else {
            return true
        }

        return false
    }

    var body: some View {
        Form {
            Section {
                TextField(
                    .TranslationView.valueLabel,
                    text: $value,
                    axis: .vertical,
                )

                Picker(selection: $translationState) {
                    ForEach(TranslationState.allCases) { state in
                        Text(state.name)
                            .tag(state)
                    }
                } label: {
                    Text(.TranslationView.stateLabel)
                }
            } header: {
                Text(.TranslationView.translationLabel)
            }

            Section {
                Picker(selection: $languageCode) {
                    ForEach(languages) { code in
                        Text(code.name)
                            .tag(code)
                    }
                } label: {
                    Text(.TranslationView.languageLabel)
                }

                Picker(selection: $scriptCode) {
                    Text("")
                        .tag(Locale.Script?.none)

                    ForEach(scripts) { code in
                        Text(code.name)
                            .tag(code as Locale.Script?)
                    }
                } label: {
                    Text(.TranslationView.scriptLabel)
                }

                Picker(selection: $regionCode) {
                    Text("")
                        .tag(Locale.Region?.none)

                    ForEach(regions) { code in
                        Text(code.name)
                            .tag(code as Locale.Region?)
                    }
                } label: {
                    Text(.TranslationView.regionLabel)
                }
            } header: {
                HStack(alignment: .firstTextBaseline) {
                    Text(.TranslationView.localeLabel)
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
            translationState = newValue.state
        }
        .toolbar {
            ToolbarItemGroup {
                Button(role: .cancel) {
                    cancel()
                } label: {
                    Text(.ButtonTitle.cancel)
                }

                Button {
                    save()
                } label: {
                    Text(.ButtonTitle.save)
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
            value: value,
            language: languageCode,
            script: scriptCode,
            region: regionCode,
            state: translationState,
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
