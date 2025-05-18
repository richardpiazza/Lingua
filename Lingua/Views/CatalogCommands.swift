import SwiftUI
import Infuse

struct CatalogCommands: Commands {
    
    private let catalogService: CatalogService
    
    @State private var requireCatalog: Bool = false
    
    init(catalogService: CatalogService? = nil) {
        if let catalogService {
            self.catalogService = catalogService
        } else {
            @Resource var service: CatalogService
            self.catalogService = service
        }
    }
    
    var body: some Commands {
        CommandMenu("Catalog") {
            Button {
                catalogService.resetStorage()
            } label: {
                Text("Reset Storage")
            }
            .keyboardShortcut(KeyEquivalent("R"), modifiers: .command)
            .disabled(requireCatalog)
            .onReceive(catalogService.requireCatalogPublisher) { value in
                requireCatalog = value
            }
            
            Divider()
            
            Button {
                
            } label: {
                Label("Import Translations", systemImage: "square.and.arrow.down")
            }
            .keyboardShortcut(KeyEquivalent("I"), modifiers: .command)
            
            Button {
                
            } label: {
                Label("Export Translations", systemImage: "square.and.arrow.down")
            }
            .keyboardShortcut(KeyEquivalent("E"), modifiers: .command)
        }
    }
}
