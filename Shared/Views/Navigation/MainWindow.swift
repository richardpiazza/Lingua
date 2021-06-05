import SwiftUI
import TranslationCatalog

struct MainWindow: View {
    
    @State var contentMode: ContentMode? = .catalog
    
    var body: some View {
        NavigationView {
            ProjectNavigator(contentMode: $contentMode)
                .frame(minWidth: 200)
            
            ExpressionNavigator(viewModel: .init(contentMode: contentMode))
                .frame(minWidth: 250)
            
            TranslationNavigator(viewModel: .init())
        }
    }
}

struct MainWindow_Previews: PreviewProvider {
    static var previews: some View {
        MainWindow()
    }
}
