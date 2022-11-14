import SwiftUI
import CodeQuickKit

struct CatalogCommands: Commands {
    
    class ViewModel: ObservableObject {
        @Published var requireCatalog: Bool = false
        
        @Dependency private var catalogService: CatalogService
        
        init() {
            catalogService.$catalog
                .map { $0 == nil }
                .receive(on: DispatchQueue.main)
                .assign(to: &$requireCatalog)
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
            .disabled(viewModel.requireCatalog)
        }
    }
}
