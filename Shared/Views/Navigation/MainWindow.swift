import SwiftUI
import TranslationCatalog

struct MainWindow: View {
    
    enum ContentMode: Hashable {
        case catalog
        case project(Project.ID)
        case search(String)
    }
    
    @State var contentMode: ContentMode? = .catalog
    
    var body: some View {
        NavigationView {
            ProjectNavigator(contentMode: $contentMode)
                .frame(minWidth: 200)
            
            ExpressionNavigator(viewModel: .init(contentMode: contentMode))
                .frame(minWidth: 250)
            
            TranslationNavigator(expression: .constant(.init()))
        }
    }
}

struct MainWindow_Previews: PreviewProvider {
    static var previews: some View {
        MainWindow()
    }
}
