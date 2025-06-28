import AsyncPlus
import Combine
import Foundation
import TranslationCatalog

class CatalogContainer {
    
    private let catalog: any Catalog
    
    private var projectsSubject = CurrentValueAsyncSubject<[Project]>([])
    private var expressionsSubject = CurrentValueAsyncSubject<[Project]>([])
    
    init(catalog: any Catalog) async {
        self.catalog = catalog
    }
}
