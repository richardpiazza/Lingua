import SwiftUI

struct CatalogCommands: Commands {

    var documentState: Document.State
    @Binding var showCreate: Bool
    @Binding var showImport: Bool
    @Binding var showExport: Bool

    var body: some Commands {
        CommandMenu(.MenuCatalog.title) {
            Button {
                showCreate = true
            } label: {
                Label(.MenuCatalog.addExpression, systemImage: "plus.square")
            }
            .keyboardShortcut(KeyEquivalent("A"), modifiers: [.command, .option])
            .disabled(documentState == .new)

            Divider()

            Button {
                showImport = true
            } label: {
                Label(.MenuCatalog.importTranslations, systemImage: "square.and.arrow.down")
            }
            .keyboardShortcut(KeyEquivalent("I"), modifiers: [.command, .option])
            .disabled(documentState == .new)

            Button {
                showExport = true
            } label: {
                Label(.MenuCatalog.exportTranslations, systemImage: "square.and.arrow.down")
            }
            .keyboardShortcut(KeyEquivalent("E"), modifiers: [.command, .option])
            .disabled(documentState == .new)
        }
    }
}
