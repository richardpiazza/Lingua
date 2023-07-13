import SwiftUI
import TranslationCatalog

struct TranslationNavigator: View {
    
    @ObservedObject var viewModel: TranslationNavigatorViewModel = .init()
    
    @State private var confirmDelete: Bool = false
    @State private var showError: Bool = false
    @State private var error: Error?
    @State private var showAddTranslation: Bool = false
    
    var body: some View {
        ScrollView {
            if viewModel.expression.id == .zero {
                NoSelectedExpressionView()
            } else {
                VStack(spacing: 20.0) {
                    ExpressionView(viewModel.expression.id)
                    
                    Divider()
                    
                    Text("Translations")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    TranslationsView(viewModel: .init(expression: viewModel.expression))
                }
                .padding()
            }
        }
        .toolbar {
            if viewModel.expression.id != .zero {
                ToolbarItemGroup {
                    Button {
                        showAddTranslation.toggle()
                    } label: {
                        Image(systemName: "plus.bubble")
                    }
                    .keyboardShortcut(KeyEquivalent("T"), modifiers: .command)
                    .sheet(isPresented: $showAddTranslation, content: {
                        EditTranslationView(viewModel: .init(expression: viewModel.expression, translation: nil), showEdit: $showAddTranslation)
                    })
                    
                    Button(role: .destructive) {
                        confirmDelete = true
                    } label: {
                        Image(systemName: "trash")
                    }
                    .keyboardShortcut(KeyEquivalent("D"), modifiers: .command)
                    
                    Menu {
                        ForEach(viewModel.projects) { project in
                            let selected = project.expressions.contains(where: { $0.id == viewModel.expression.id })
                            Button {
                                viewModel.toggleExpressionOnProject(id: project.id, isSelected: selected)
                            } label: {
                                Text(project.name)
                            }
                            .buttonStyle(SelectableButtonStyle(selected: selected))
                        }
                    } label: {
                        Image(systemName: "link")
                    }
                    .keyboardShortcut(KeyEquivalent("L"), modifiers: .command)
                }
            }
        }
        .navigationTitle(viewModel.expression.name)
        .alert(isPresented: $showError) {
            Alert(
                title: Text(error?.localizedDescription ?? "Error")
            )
        }
        .alert(isPresented: $confirmDelete) {
            Alert(
                title: Text("Delete Expression?"),
                message: Text("Are you sure you want to remove this expression and all it's related translations?"),
                primaryButton: .destructive(Text("Delete"), action: {
                    viewModel.deleteExpression()
                }),
                secondaryButton: .cancel()
            )
        }
    }
}

struct TranslationNavigator_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            TranslationNavigator()
            TranslationNavigator(viewModel: .init(expression: .preview))
        }
    }
}

struct SelectableButtonStyle: ButtonStyle {
    let selected: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.label
            if (selected) {
                Image(systemName: "checkmark")
            }
        }
    }
}
