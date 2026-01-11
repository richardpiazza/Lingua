import LocaleSupport
import SwiftUI
import TranslationCatalog

struct ExpressionFormView: View {

    var expression: TranslationCatalog.Expression
    var contentScheme: ContentScheme

    @Environment(\.storageContainer) private var storageContainer
    @State private var key: String = ""
    @State private var value: String = ""
    @State private var name: String = ""
    @State private var context: String = ""
    @State private var feature: String = ""
    @State private var defaultLanguage: Locale.LanguageCode = .default
    @State private var translations: [TranslationCatalog.Translation] = []
    @State private var translationToDelete: TranslationCatalog.Translation?
    @State private var confirmDelete: Bool = false

    var body: some View {
        Form {
            Section {
                TextField(
                    "Localization Key",
                    text: $key,
                    prompt: Text("Unique value that globally identifies this Expression"),
                    axis: .vertical,
                )
                .onChange(of: key) { _, newValue in
                    updateExpression(.key(newValue))
                }
                
                TextField(
                    "Value",
                    text: $value,
                    prompt: Text("Your reference to this Expression"),
                    axis: .vertical,
                )
                .bold()
                .onChange(of: value) { _, newValue in
                    updateExpression(.defaultValue(newValue))
                }
                
                Picker(
                    "Language",
                    selection: $defaultLanguage,
                ) {
                    ForEach(Locale.LanguageCode.allCases) { code in
                        Text(code.name)
                            .tag(code)
                    }
                }
                .onChange(of: defaultLanguage) { _, newValue in
                    updateExpression(.defaultLanguage(newValue))
                }
            } header: {
                Text("Expression")
                    .font(.headline)
            }
            
            Section {
                TextField(
                    "Display Name",
                    text: $name,
                    prompt: Text("Optional reference to this Expression"),
                    axis: .vertical,
                )
                .italic()
                .onChange(of: name) { _, newValue in
                    updateExpression(.name(newValue))
                }

                TextField(
                    "Comments",
                    text: $context,
                    prompt: Text("Hints to translators as to how this Expression is used"),
                    axis: .vertical,
                )
                .italic()
                .onChange(of: context) { _, newValue in
                    updateExpression(.context(newValue.isEmpty ? nil : newValue))
                }

                TextField(
                    "Tags",
                    text: $feature,
                    prompt: Text("Classification that groups this Expression with others in your App"),
                    axis: .vertical,
                )
                .italic()
                .onChange(of: feature) { _, newValue in
                    updateExpression(.feature(newValue.isEmpty ? nil : newValue))
                }
            } header: {
                Text("Metadata")
                    .font(.headline)
            }

            Section {
                ForEach(translations) { translation in
                    HStack(alignment: .firstTextBaseline) {
                        if let languageName = translation.language.localizedName {
                            Text(languageName)
                        }

                        Text(translation.locale.identifier)

                        if let flag = translation.region?.unicodeFlag {
                            Text(flag)
                        }

                        Text(translation.value)
                            .frame(maxWidth: .infinity, alignment: .trailing)

                        TranslationStateView(
                            state: translation.state,
                            matchesDefault: translation.value == value
                        )

                        Menu {
                            NavigationLink(value: translation) {
                                Label("Edit", systemImage: "pencil")
                            }
                            .labelStyle(.titleAndIcon)
                            
                            Button {
                                updateTranslation(translation, state: .translated)
                            } label: {
                                Label("Mark as Reviewed", systemImage: "checkmark")
                            }
                            .labelStyle(.titleAndIcon)
                            .disabled(translation.state == .translated)
                            
                            Button {
                                updateTranslation(translation, state: .needsReview)
                            } label: {
                                Label("Mark for Review", systemImage: "magnifyingglass")
                            }
                            .labelStyle(.titleAndIcon)
                            .disabled(translation.state == .needsReview)

                            Button(role: .destructive) {
                                translationToDelete = translation
                                confirmDelete = true
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                            .labelStyle(.titleAndIcon)
                        } label: {
                            Label("Translation Options", systemImage: "ellipsis.circle")
                        }
                        .buttonStyle(.plain)
                        .labelStyle(.iconOnly)
                    }
                }
            } header: {
                VStack {
                    HStack {
                        Text("Translations")
                            .frame(maxWidth: .infinity, alignment: .leading)

                        NavigationLink(value: newTranslation()) {
                            Label("Add Translation", systemImage: "plus.circle")
                        }
                        .buttonStyle(.plain)
                        .labelStyle(.iconOnly)
                    }
                    .font(.headline)
                }
            }
        }
        .formStyle(.grouped)
        .task(id: expression.id) {
            for await values in storageContainer.translations(for: expression.id) {
                translations = values
            }
        }
        .onChange(of: expression, initial: true) { _, newValue in
            key = newValue.key
            value = newValue.defaultValue
            name = newValue.name
            context = newValue.context ?? ""
            feature = newValue.feature ?? ""
            defaultLanguage = newValue.defaultLanguageCode
        }
        .alert(
            "Remove Translation",
            isPresented: $confirmDelete,
            presenting: translationToDelete,
            actions: { translation in
                Button(role: .cancel) {
                    translationToDelete = nil
                } label: {
                    Text("Cancel")
                }
                Button(role: .destructive) {
                    deleteTranslation(translation)
                    translationToDelete = nil
                } label: {
                    Text("Remove")
                }
            }, message: { _ in
                Text("Are you sure you want to remove this translation from the catalog?")
            },
        )
    }

    private func newTranslation() -> TranslationCatalog.Translation {
        TranslationCatalog.Translation(
            id: .zero,
            expressionId: expression.id,
            value: "",
            language: .default,
        )
    }

    private func updateExpression(_ update: GenericExpressionUpdate) {
        try? storageContainer.updateExpression(
            expression,
            update: update,
            contentScheme: contentScheme,
        )
    }
    
    private func updateTranslation(_ translation: TranslationCatalog.Translation, state: TranslationState) {
        let modified = TranslationCatalog.Translation(
            translation: translation,
            state: state
        )
        try? storageContainer.updateTranslation(modified)
    }

    private func createTranslation(_ translation: TranslationCatalog.Translation) {
        _ = try? storageContainer.createTranslation(translation)
    }

    private func deleteTranslation(_ translation: TranslationCatalog.Translation) {
        try? storageContainer.deleteTranslation(translation.id)
    }
}

#Preview {
    ExpressionFormView(
        expression: .add,
        contentScheme: .catalog,
    )
    .environment(\.storageContainer, .inMemoryContainer)
}
