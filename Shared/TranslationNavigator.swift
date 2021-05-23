import SwiftUI
import TranslationCatalog

struct TranslationNavigator: View {
    
    class ViewModel: ObservableObject {
        let appEnvironment: AppEnvironment
        let id: Expression.ID
        
        init(appEnvironment: AppEnvironment = .default, id: Expression.ID) {
            self.appEnvironment = appEnvironment
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
        TranslationNavigator(viewModel: .init(id: .zero))
            .environmentObject(AppEnvironment.default)
    }
}
