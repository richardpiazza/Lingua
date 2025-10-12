import SwiftUI

struct CatalogCommands: Commands {

    var documentState: Document.State
    @Binding var showImport: Bool
    @Binding var showExport: Bool

    var body: some Commands {
        CommandMenu("Catalog") {
            Button {
                showImport = true
            } label: {
                Label("Import Translations", systemImage: "square.and.arrow.down")
            }
            .keyboardShortcut(KeyEquivalent("I"), modifiers: [.command, .option])
            .disabled(documentState == .new)

            Button {
                showExport = true
            } label: {
                Label("Export Translations", systemImage: "square.and.arrow.down")
            }
            .keyboardShortcut(KeyEquivalent("E"), modifiers: [.command, .option])
            .disabled(documentState == .new)
        }
    }
}
