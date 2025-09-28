import SwiftUI

struct DescriptorKindView: View {
    
    var documentUrl: URL?
    var action: (CatalogDescriptor) -> Void
    
    @State private var kind: CatalogDescriptor.Kind? = .package
    @State private var file: String = ""
    @State private var directory: String = ""
    
    private var ready: Bool {
        switch kind {
        case .directory:
            !directory.isEmpty
        case .file:
            !file.isEmpty
        case .package:
            documentUrl != nil
        default:
            false
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                Text("How would you like to store your data?")
                    .font(.title3)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Button {
                    select(.package)
                } label: {
                    DescriptorKindButton(
                        kind: .package,
                        selected: kind == .package,
                        saved: documentUrl != nil
                    )
                }
                
                Button {
                    select(.file)
                } label: {
                    DescriptorKindButton(
                        kind: .file,
                        selected: kind == .file,
                        path: $file
                    )
                }
                
                Button {
                    select(.directory)
                } label: {
                    DescriptorKindButton(
                        kind: .directory,
                        selected: kind == .directory,
                        path: $directory
                    )
                }
            }
            .padding()
            .buttonStyle(.plain)
            
            Divider()
            
            VStack {
                Button {
                    getStarted()
                } label: {
                    Label("Get Started", systemImage: "arrow.forward.circle")
                }
                .disabled(!ready)
                .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .padding()
            .buttonStyle(.borderedProminent)
        }
    }
    
    private func select(_ kind: CatalogDescriptor.Kind) {
        if self.kind == kind {
            self.kind = nil
        } else {
            self.kind = kind
        }
    }
    
    private func getStarted() {
        let descriptor: CatalogDescriptor
        
        switch kind {
        case .directory:
            guard var url = URL(string: directory) else {
                return
            }
            
            if !url.absoluteString.hasSuffix("/") {
                url = url.appending(component: "/", directoryHint: .isDirectory)
            }
            
            do {
                descriptor = try CatalogDescriptor(
                    kind: .directory,
                    url: url
                )
            } catch {
                return
            }
        case .file:
            guard let url = URL(string: file) else {
                return
            }
            
            do {
                descriptor = try CatalogDescriptor(
                    kind: .file,
                    url: url
                )
            } catch {
                return
            }
        case .package:
            guard let documentUrl else {
                return
            }
            
            let url = documentUrl.appending(path: "", directoryHint: .notDirectory)
            
            do {
                descriptor = try CatalogDescriptor(
                    kind: .package,
                    url: url
                )
            } catch {
                return
            }
        case nil:
            return
        }
        
        action(descriptor)
    }
}

struct DescriptorKindButton: View {
    
    var kind: CatalogDescriptor.Kind
    var selected: Bool = false
    var saved: Bool = false
    var path: Binding<String>?
    
    @State private var presentFolderPicker: Bool = false
    
    var systemImage: String {
        switch kind {
        case .directory: "folder"
        case .file: "cylinder.split.1x2"
        case .package: "archivebox"
        }
    }
    
    var title: String {
        switch kind {
        case .directory: "Directory Reference"
        case .file: "External Database"
        case .package: "Internal Package"
        }
    }
    
    var description: String {
        switch kind {
        case .directory: "Provide a directory where JSON files will be created.\nBest for teams using source control."
        case .file: "Choose your own SQLite file on your filesystem.\nGreat for accessing with CLI tools."
        case .package: "Uses Core Data to store data in the file package.\nEverything in one place."
        }
    }
    
    var body: some View {
        HStack(alignment: .top) {
            Image(systemName: systemImage)
                .font(.largeTitle)
                .frame(minWidth: 20, idealWidth: 30, maxWidth: 40)
            
            VStack(alignment: .leading) {
                Text(title)
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Text(description)
                    .font(.caption)
                    .fixedSize()
                
                if let path, selected {
                    HStack {
                        TextField(text: path) {
                            Text(kind == .directory ? "JSON Directory" : "SQLite File")
                        }

                        Button {
                            selectURL()
                        } label: {
                            Image(systemName: "externaldrive")
                        }
                    }
                } else if kind == .package, selected {
                    HStack {
                        Image(systemName: saved ? "checkmark.circle" : "circle")
                        
                        Text("Save the document in order to get started.")
                            .font(.callout)
                    }
                }
            }
        }
        .padding()
        .background(selected ? Color.gray.opacity(0.2) : Color.background)
        .border(selected ? Color.accent : Color.black, width: 1.0)
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

        switch kind {
        case .file:
            panel.canChooseDirectories = true
            panel.canChooseFiles = true
        case .directory:
            panel.canChooseDirectories = true
            panel.canChooseFiles = false
        default:
            return
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
        switch kind {
        case .directory:
            path?.wrappedValue = url.path
        case .file:
            if url.hasDirectoryPath || !url.path.lowercased().hasSuffix("sqlite") {
                path?.wrappedValue = url.appendingPathComponent("Lingua.sqlite").path
            } else {
                path?.wrappedValue = url.path
            }
        default:
            break
        }
    }
}

#Preview {
    DescriptorKindView { _ in
    }
    .frame(height: 450)
}
