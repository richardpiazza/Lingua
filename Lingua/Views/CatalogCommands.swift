import SwiftUI

struct CatalogCommands: Commands {

    @Binding var storageContainer: StorageContainer?
    @Binding var showImport: Bool
    @Binding var showExport: Bool

    var body: some Commands {
        CommandMenu("Catalog") {
            Button {
                storageContainer = nil
                StorageContainer.clearBookmark()
            } label: {
                Label("Change Storage", systemImage: "externaldrive")
            }
            .keyboardShortcut(KeyEquivalent("R"), modifiers: .command)
            .disabled(storageContainer == nil)

            Divider()

            Button {
                showImport = true
            } label: {
                Label("Import Translations", systemImage: "square.and.arrow.down")
            }
            .keyboardShortcut(KeyEquivalent("I"), modifiers: [.command, .option])
            .disabled(storageContainer == nil)

            Button {
                showExport = true
            } label: {
                Label("Export Translations", systemImage: "square.and.arrow.down")
            }
            .keyboardShortcut(KeyEquivalent("E"), modifiers: [.command, .option])
            .disabled(storageContainer == nil)
        }
    }
}
