import Infuse
import LocaleSupport
import SwiftUI
import TranslationCatalog

struct ExpressionFormView: View {
    
    var expression: TranslationCatalog.Expression
    var contentScheme: ContentScheme
    var expressionService: ExpressionService?
    var translationService: TranslationService?
    
    @State private var name: String = ""
    @State private var key: String = ""
    @State private var context: String = ""
    @State private var feature: String = ""
    @State private var defaultLanguage: LocaleSupport.LanguageCode = .default
    @State private var translations: [TranslationCatalog.Translation] = []
    @State private var translationToDelete: TranslationCatalog.Translation?
    @State private var confirmDelete: Bool = false
    
    private let translationSort = TranslationComparator()
    
    private var resolvedExpressionService: ExpressionService {
        if let expressionService {
            expressionService
        } else {
            try! ResourceCache.shared.resolve()
        }
    }
    
    private var resolvedTranslationService: TranslationService {
        if let translationService {
            translationService
        } else {
            try! ResourceCache.shared.resolve()
        }
    }
    
    var body: some View {
        Form {
            Section {
                TextField(
                    "Localization Key",
                    text: $key,
                    prompt: Text("Unique value that globally identifies this Expression"),
                    axis: .vertical
                )
                .onChange(of: key) { _, newValue in
                    updateExpression(.key(newValue))
                }
                
                TextField(
                    "Name",
                    text: $name,
                    prompt: Text("Your reference to this Expression"),
                    axis: .vertical
                )
                .onChange(of: name) { _, newValue in
                    updateExpression(.name(newValue))
                }
                
                TextField(
                    "Context",
                    text: $context,
                    prompt: Text("Hints to translators as to how this Expression is used"),
                    axis: .vertical
                )
                .onChange(of: context) { _, newValue in
                    updateExpression(.context(newValue.isEmpty ? nil : newValue))
                }
                
                TextField(
                    "Feature",
                    text: $feature,
                    prompt: Text("Classification that groups this Expression with others in your App"),
                    axis: .vertical
                )
                .onChange(of: feature) { _, newValue in
                    updateExpression(.feature(newValue.isEmpty ? nil : newValue))
                }
                
                Picker(
                    "Default Language",
                    selection: $defaultLanguage
                ) {
                    ForEach(LocaleSupport.LanguageCode.allCases) { code in
                        Text("\(code.name) (\(code.rawValue))")
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
                ForEach(translations) { translation in
                    HStack(alignment: .firstTextBaseline) {
                        Text(translation.languageName)
                            .bold(translation.languageCode == defaultLanguage)
                        
                        Text(translation.localeIdentifier)
                        
                        if let flag = translation.locale.flag {
                            Text(flag)
                        }
                        
                        Text(translation.value)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                        
                        Menu {
                            NavigationLink(value: translation) {
                                Label("Edit", systemImage: "pencil")
                            }
                            .labelStyle(.titleAndIcon)
                            
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
        .onChange(of: expression, initial: true) { _, newValue in
            name = newValue.name
            key = newValue.key
            context = newValue.context ?? ""
            feature = newValue.feature ?? ""
            Task {
                let stream = await resolvedTranslationService.translations(for: expression.id)
                for await values in stream {
                    translations = values.sorted(using: translationSort)
                }
            }
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
            }
        )
    }
    
    private func newTranslation() -> TranslationCatalog.Translation {
        TranslationCatalog.Translation(
            expressionId: expression.id
        )
    }
    
    private func updateExpression(_ update: GenericExpressionUpdate) {
        try? resolvedExpressionService.updateExpression(
            expression,
            update: update,
            contentScheme: contentScheme
        )
    }
    
    private func createTranslation(_ translation: TranslationCatalog.Translation) {
        Task {
            let _ = try? await resolvedTranslationService.createTranslation(translation)
        }
    }
    
    private func modifyTranslation(_ translation: TranslationCatalog.Translation) {
        Task {
            try? await resolvedTranslationService.updateTranslation(translation)
        }
    }
    
    private func deleteTranslation(_ translation: TranslationCatalog.Translation) {
        Task {
            try? await resolvedTranslationService.deleteTranslation(translation.id)
        }
    }
}

#Preview {
    ExpressionFormView(
        expression: .preview,
        contentScheme: .catalog,
        translationService: EmulatedTranslationService(
            translations: [
                .en,
                .es
            ]
        )
    )
}
