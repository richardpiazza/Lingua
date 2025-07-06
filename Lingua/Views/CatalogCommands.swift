import SwiftUI

struct CatalogCommands: Commands {
    
    @Binding var storageContainer: StorageContainer?
    
    var body: some Commands {
        CommandMenu("Catalog") {
            Button {
                storageContainer = nil
                StorageContainer.clearBookmark()
            } label: {
                Text("Reset Storage")
            }
            .keyboardShortcut(KeyEquivalent("R"), modifiers: .command)
            .disabled(storageContainer == nil)
            
            Divider()
            
            Button {
                
            } label: {
                Label("Import Translations", systemImage: "square.and.arrow.down")
            }
            .keyboardShortcut(KeyEquivalent("I"), modifiers: .command)
            .disabled(storageContainer == nil)
            
            Button {
                
            } label: {
                Label("Export Translations", systemImage: "square.and.arrow.down")
            }
            .keyboardShortcut(KeyEquivalent("E"), modifiers: .command)
            .disabled(storageContainer == nil)
        }
    }
}
