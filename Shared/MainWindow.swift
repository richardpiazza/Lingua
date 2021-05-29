import SwiftUI

struct MainWindow: View {
    @EnvironmentObject private var appEnvironment: AppEnvironment
    
    var body: some View {
        NavigationView {
            ProjectNavigator(viewModel: .init(appEnvironment: appEnvironment))
                .toolbar {
                    createProject
                }
            
            ExpressionNavigator(viewModel: .init(appEnvironment: appEnvironment))
                .toolbar {
                    createExpression
                }
            
            TranslationNavigator(viewModel: .init(state: .noSelection))
        }
    }
    
    private var createProject: some ToolbarContent {
        let placement: ToolbarItemPlacement
        #if os(macOS)
        placement = .status
        #else
        placement = .navigationBarTrailing
        #endif
        
        return ToolbarItem(placement: placement) {
            Button(action: {
                
            }, label: {
                Image(systemName: "folder.badge.plus")
            })
        }
    }
    
    private var createExpression: some ToolbarContent {
        let placement: ToolbarItemPlacement
        #if os(macOS)
        placement = .status
        #else
        placement = .navigationBarTrailing
        #endif
        
        return ToolbarItem(placement: placement) {
            Button(action: {
                
            }, label: {
                Image(systemName: "square.and.pencil")
            })
        }
    }
}

struct MainWindow_Previews: PreviewProvider {
    static var previews: some View {
        MainWindow()
            .environmentObject(AppEnvironment.default)
    }
}
