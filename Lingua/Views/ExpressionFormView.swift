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
                    .Expression.View.Key.label,
                    text: $key,
                    prompt: Text(.Expression.View.Key.prompt),
                    axis: .vertical,
                )
                .onChange(of: key) { _, newValue in
                    updateExpression(.key(newValue))
                }

                TextField(
                    .Expression.View.Value.label,
                    text: $value,
                    prompt: Text(.Expression.View.Value.prompt),
                    axis: .vertical,
                )
                .bold()
                .onChange(of: value) { _, newValue in
                    updateExpression(.defaultValue(newValue))
                }

                Picker(
                    .Expression.View.languageLabel,
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
                Text(.Expression.View.expressionLabel)
                    .font(.headline)
            }

            Section {
                TextField(
                    .Expression.View.Display.label,
                    text: $name,
                    prompt: Text(.Expression.View.Display.prompt),
                    axis: .vertical,
                )
                .italic()
                .onChange(of: name) { _, newValue in
                    updateExpression(.name(newValue))
                }

                TextField(
                    .Expression.View.Comments.label,
                    text: $context,
                    prompt: Text(.Expression.View.Comments.prompt),
                    axis: .vertical,
                )
                .italic()
                .onChange(of: context) { _, newValue in
                    updateExpression(.context(newValue.isEmpty ? nil : newValue))
                }

                TextField(
                    .Expression.View.Classification.label,
                    text: $feature,
                    prompt: Text(.Expression.View.Classification.prompt),
                    axis: .vertical,
                )
                .italic()
                .onChange(of: feature) { _, newValue in
                    updateExpression(.feature(newValue.isEmpty ? nil : newValue))
                }
            } header: {
                Text(.Expression.View.metadataLabel)
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
                            matchesDefault: translation.value == value,
                        )

                        Menu {
                            NavigationLink(value: translation) {
                                Label(.Expression.View.editLabel, systemImage: "pencil")
                            }
                            .labelStyle(.titleAndIcon)

                            Button {
                                updateTranslation(translation, state: .translated)
                            } label: {
                                Label(.Expression.View.markReviewedLabel, systemImage: "checkmark")
                            }
                            .labelStyle(.titleAndIcon)
                            .disabled(translation.state == .translated)

                            Button {
                                updateTranslation(translation, state: .needsReview)
                            } label: {
                                Label(.Expression.View.needsReviewLabel, systemImage: "magnifyingglass")
                            }
                            .labelStyle(.titleAndIcon)
                            .disabled(translation.state == .needsReview)

                            Button(role: .destructive) {
                                translationToDelete = translation
                                confirmDelete = true
                            } label: {
                                Label(.ButtonTitle.delete, systemImage: "trash")
                            }
                            .labelStyle(.titleAndIcon)
                        } label: {
                            Label(.Expression.View.translationOptionsLabel, systemImage: "ellipsis.circle")
                        }
                        .buttonStyle(.plain)
                        .labelStyle(.iconOnly)
                    }
                }
            } header: {
                VStack {
                    HStack {
                        Text(.Expression.View.translationsLabel)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        NavigationLink(value: newTranslation()) {
                            Label(.Expression.View.addTranslationLabel, systemImage: "plus.circle")
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
            .RemoveExpressionView.title,
            isPresented: $confirmDelete,
            presenting: translationToDelete,
            actions: { translation in
                Button(role: .cancel) {
                    translationToDelete = nil
                } label: {
                    Text(.ButtonTitle.cancel)
                }
                Button(role: .destructive) {
                    deleteTranslation(translation)
                    translationToDelete = nil
                } label: {
                    Text(.ButtonTitle.remove)
                }
            }, message: { _ in
                Text(.RemoveExpressionView.message)
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
            state: state,
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
