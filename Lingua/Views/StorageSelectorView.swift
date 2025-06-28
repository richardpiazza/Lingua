import SwiftUI
import Infuse
import TranslationCatalog

struct StorageSelectorView: View {
    
    var catalogService: CatalogService?
    
    @State private var presentFolderPicker: Bool = false
    @State private var selectedMedium: StorageMedium = .sqlite
    @State private var path: String = ""
    
    private var resolvedCatalogService: CatalogService {
        if let catalogService {
            catalogService
        } else {
            try! ResourceCache.shared.resolve()
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10.0) {
            VStack(alignment: .leading) {
                Text("Catalog Storage")
                    .font(.title)
                Text("Select how and where the information in the catalog is stored.")
                    .font(.subheadline)
            }
            
            Divider()
            
            Picker(selection: $selectedMedium) {
                ForEach(StorageMedium.allCases, id: \.self) { medium in
                    Text(medium.id)
                }
            } label: {
                Text("Storage Medium")
            }
            
            HStack {
                TextField(text: $path) {
                    Text(selectedMedium == .sqlite ? "SQLite File" : "JSON Directory")
                }
                
                Button {
                    selectURL()
                } label: {
                    Image(systemName: "externaldrive")
                }
            }
            
            Button {
                setStorageMode()
            } label: {
                Text("Save")
            }
            .disabled(path.isEmpty)
        }
        .padding()
        #if os(iOS)
        .fullScreenCover(isPresented: $presentFolderPicker) {
            FolderPickerView { result in
                switch result {
                case .none:
                    break
                case .failure(let error):
                    print(error)
                case .success(let url):
                    setURL(url)
                }
            }
        }
        #endif
    }
    
    private func selectURL() {
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
                setURL(url)
            }
        default:
            break
        }
        #else
        presentFolderPicker = true
        #endif
    }
    
    private func setURL(_ url: URL) {
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
    
    private func setStorageMode() {
        guard let url = URL(string: self.path) else {
            return
        }
        
        switch selectedMedium {
        case .sqlite:
            resolvedCatalogService.setStorageMode(.sqlite(url))
        case .json:
            if url.absoluteString.hasSuffix("/") {
                resolvedCatalogService.setStorageMode(.json(url))
            } else if let newURL = URL(string: url.absoluteString.appending("/")) {
                resolvedCatalogService.setStorageMode(.json(newURL))
            }
        }
    }
}

#Preview {
    StorageSelectorView()
}
