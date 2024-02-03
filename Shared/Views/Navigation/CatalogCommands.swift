import SwiftUI
import Infuse

struct CatalogCommands: Commands {
    
    class ViewModel: ObservableObject {
        @Published var requireCatalog: Bool = false
        
        @Resource private var catalogService: CatalogService
        
        init() {
            postInit()
        }
        
        private func postInit() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                guard let self = self else {
                    return
                }
                
                self.catalogService.catalogPublisher
                    .map { $0 == nil }
                    .receive(on: DispatchQueue.main)
                    .assign(to: &self.$requireCatalog)
            }
        }
        
        func resetStorage() {
            catalogService.resetStorage()
        }
    }
    
    @StateObject private var viewModel: ViewModel = .init()
    
    var body: some Commands {
        CommandMenu("Catalog") {
            Button {
                viewModel.resetStorage()
            } label: {
                Text("Reset Storage")
            }
            .keyboardShortcut(KeyEquivalent("R"), modifiers: .command)
            .disabled(viewModel.requireCatalog)
            
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
