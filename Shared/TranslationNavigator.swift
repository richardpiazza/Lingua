import SwiftUI
import TranslationCatalog

struct TranslationNavigator: View {
    
    class ViewModel: ObservableObject {
        let catalog: Catalog
        let id: Expression.ID
        
        init(catalog: Catalog, id: Expression.ID) {
            self.catalog = catalog
            self.id = id
        }
    }
    
    @EnvironmentObject private var appEnvironment: AppEnvironment
    @StateObject var viewModel: ViewModel
    
    var body: some View {
        ScrollView {
            VStack {
                Text("Expression")
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Text(viewModel.id.uuidString)
            }
            .padding()
        }
    }
}

struct TranslationNavigator_Previews: PreviewProvider {
    static var previews: some View {
        TranslationNavigator(viewModel: .init(catalog: LocalCatalog.default, id: .zero))
            .environmentObject(AppEnvironment())
    }
}
