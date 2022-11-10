import SwiftUI
import TranslationCatalog

struct MainWindow: View {
    
    var body: some View {
        NavigationView {
            ProjectNavigator()
                .frame(minWidth: 200)
            
            ExpressionNavigator()
                .frame(minWidth: 250)
            
            TranslationNavigator()
        }
    }
}

struct MainWindow_Previews: PreviewProvider {
    static var previews: some View {
        MainWindow()
    }
}
