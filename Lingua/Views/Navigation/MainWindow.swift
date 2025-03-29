import Infuse
import SwiftUI
import TranslationCatalog

struct MainWindow: View {

    private let catalogService: CatalogService
    
    @State private var requireCatalog: Bool = false
    
    init(
        catalogService: CatalogService? = nil
    ) {
        if let catalogService {
            self.catalogService = catalogService
        } else {
            @Resource var service: CatalogService
            self.catalogService = service
        }
    }
    
    var body: some View {
        NavigationSplitView {
            ProjectNavigator()
                .navigationSplitViewColumnWidth(ideal: 200)
        } content: {
            ExpressionNavigator(
                contentScheme: .catalog
            )
            .navigationSplitViewColumnWidth(ideal: 250)
        } detail: {
            TranslationNavigator(
                contentScheme: .catalog,
                expression: nil
            )
        }
        .sheet(isPresented: $requireCatalog) {
            StorageSelectorView()
        }
        .onReceive(catalogService.requireCatalogPublisher) { value in
            requireCatalog = value
        }
    }
}

#Preview {
    MainWindow()
}
