import SwiftUI
import TranslationCatalog
import Infuse

struct MainWindow: View {
    
    class ViewModel: ObservableObject {
        @Published var requireCatalog: Bool = false
        
        @Resource private var catalogService: CatalogService
        
        init() {
            catalogService.catalogPublisher
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
