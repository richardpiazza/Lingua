import Foundation
import SwiftUI
import TranslationCatalog

class AppEnvironment: ObservableObject {
    
    enum State {
        case sandbox
    }
    
    enum ContentMode: Hashable {
        case catalog
        case project(Project.ID)
        case search(String)
    }
    
    @Published var state: State = .sandbox
    @Published var contentMode: ContentMode? = .catalog
    @Published var selectedExpression: Expression.ID? = nil
    
    let catalog: Catalog = LocalCatalog.default
}
