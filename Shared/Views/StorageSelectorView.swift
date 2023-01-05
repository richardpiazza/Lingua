import SwiftUI
import CodeQuickKit
import TranslationCatalog

struct StorageSelectorView: View {
    
    class ViewModel: ObservableObject {
        @Published var selectedMedium: Medium = .sqlite
        @Published var path: String = ""
        
        @Dependency private var catalogService: CatalogService
        
        init() {
        }
        
        func selectURL() {
            #if os(macOS)
            let panel = NSOpenPanel()
            panel.allowsMultipleSelection = false
            
            switch selectedMedium {
            case .sqlite:
                panel.canChooseDirectories = true
                panel.canChooseFiles = true
            case .json:
                panel.canChooseDirectories = true
                panel.canChooseFiles = false
            }
            
            switch panel.runModal() {
            case .OK:
                if let url = panel.url {
                    switch selectedMedium {
                    case .json:
                        self.path = url.path
                    case .sqlite:
                        if url.hasDirectoryPath || !url.path.lowercased().hasSuffix("sqlite") {
                            self.path = url.appendingPathComponent("Lingua.sqlite").path
                        } else {
                            self.path = url.path
                        }
                    }
                }
            default:
                break
            }
            #endif
        }
        
        func setStorageMode() {
            guard let url = URL(string: self.path) else {
                return
            }
            
            switch selectedMedium {
            case .sqlite:
                catalogService.setStorageMode(.sqlite(url))
            case .json:
                if url.absoluteString.hasSuffix("/") {
                    catalogService.setStorageMode(.json(url))
                } else if let newURL = URL(string: url.absoluteString.appending("/")) {
                    catalogService.setStorageMode(.json(newURL))
                }
            }
        }
    }
    
    enum Medium: Identifiable, CaseIterable {
        case sqlite
        case json
        
        var id: String { String(describing: self) }
    }
    
    @StateObject private var viewModel: ViewModel = .init()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10.0) {
            VStack(alignment: .leading) {
                Text("Catalog Storage")
                    .font(.title)
                Text("Select how and where the information in the catalog is stored.")
                    .font(.subheadline)
            }
            
            Divider()
            
            Picker(selection: $viewModel.selectedMedium) {
                ForEach(Medium.allCases, id: \.self) { medium in
                    Text(medium.id)
                }
            } label: {
                Text("Storage Medium")
            }
            
            HStack {
                TextField(text: $viewModel.path) {
                    Text(viewModel.selectedMedium == .sqlite ? "SQLite File" : "JSON Directory")
                }
                
                Button {
                    viewModel.selectURL()
                } label: {
                    Image(systemName: "externaldrive")
                }
            }
            
            Button {
                viewModel.setStorageMode()
            } label: {
                Text("Save")
            }
            .disabled(viewModel.path.isEmpty)
        }
        .padding()
    }
}

struct StorageSelectorView_Previews: PreviewProvider {
    static var previews: some View {
        StorageSelectorView()
    }
}
