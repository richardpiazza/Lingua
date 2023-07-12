import SwiftUI
import TranslationCatalog
import CodeQuickKit

struct MainWindow: View {
    
    class ViewModel: ObservableObject {
        @Published var requireCatalog: Bool = false
        
        @Dependency private var catalogService: CatalogService
        
        init() {
            catalogService.$catalog
                .map { $0 == nil }
                .receive(on: DispatchQueue.main)
                .assign(to: &$requireCatalog)
        }
    }
    
    @StateObject private var viewModel: ViewModel = .init()
    
    var body: some View {
        NavigationSplitView {
            ProjectNavigator()
                .frame(minWidth: 200)
        } content: {
            ExpressionNavigator()
                .frame(minWidth: 250)
        } detail: {
            TranslationNavigator()
        }
        .sheet(isPresented: $viewModel.requireCatalog) {
            StorageSelectorView()
        }
    }
}

struct MainWindow_Previews: PreviewProvider {
    static var previews: some View {
        MainWindow()
    }
}
