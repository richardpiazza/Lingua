import SwiftUI
import TranslationCatalog
import TranslationCatalogIO

struct ExportExpressionsView: View {
    
    class ViewModel: ObservableObject {
        @Published var path: String = "" {
            didSet {
                url = URL(filePath: path, directoryHint: .isDirectory)
            }
        }
        @Published var presentFolderPicker: Bool = false
        
        private var url: URL?
        
        func selectURL() {
            #if os(macOS)
            let panel = NSOpenPanel()
            panel.allowsMultipleSelection = false
            panel.canChooseDirectories = true
            panel.canChooseFiles = false

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
        
        func setURL(_ url: URL) {
            path = url.path
        }
        
        func exportExpressions(_ expressions: [Expression], formats: Set<FileFormat>) {
            guard let url = self.url else {
                return
            }
            
            for format in formats {
                do {
                    let output = url.appendingPathComponent(format.defaultFileName)
                    let data = try ExpressionEncoder.encodeTranslations(for: expressions, fileFormat: format)
                    try data.write(to: output)
                } catch {
                    print(error)
                }
            }
        }
    }
    
    var expressions: [Expression]
    var completion: () -> Void
    
    @StateObject private var viewModel: ViewModel = .init()
    @State private var formats: Set<FileFormat> = [.appleStrings]
    @State private var apple: Bool = true
    @State private var android: Bool = false
    @State private var web: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10.0) {
            VStack(alignment: .leading) {
                Text("Export Expressions")
                    .font(.title)
                Text("Generate translation files for multiple languages & platforms.")
                    .font(.subheadline)
            }
            
            Divider()
            
            HStack(alignment: .top) {
                VStack(alignment: .leading) {
                    Text("Platforms")
                        .font(.title3)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    VStack {
                        Toggle(isOn: $apple) {
                            Text("Apple (.strings)")
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .onChange(of: apple) { newValue in
                            if newValue {
                                formats.insert(.appleStrings)
                            } else {
                                formats.remove(.appleStrings)
                            }
                        }
                        
                        Toggle(isOn: $android) {
                            Text("Android (.xml)")
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .onChange(of: android) { newValue in
                            if newValue {
                                formats.insert(.androidXML)
                            } else {
                                formats.remove(.androidXML)
                            }
                        }
                        
                        Toggle(isOn: $web) {
                            Text("Web (.json)")
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .onChange(of: web) { newValue in
                            if newValue {
                                formats.insert(.json)
                            } else {
                                formats.remove(.json)
                            }
                        }
                    }
                }
                
                Divider()
                
                VStack(alignment: .leading) {
                    Text("Languages")
                        .font(.title3)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            
            Divider()
            
            VStack(alignment: .leading) {
                Text("Location")
                    .font(.title3)
                
                HStack {
                    TextField(text: $viewModel.path) {
                        Text("Export Path")
                    }
                    
                    Button {
                        viewModel.selectURL()
                    } label: {
                        Image(systemName: "externaldrive")
                    }
                }
            }
            
            Divider()
            
            HStack {
                Button(role: .cancel) {
                    completion()
                } label: {
                    Text("Cancel")
                }
                
                Button {
                    viewModel.exportExpressions(expressions, formats: formats)
                } label: {
                    Text("Export")
                }
                .disabled(viewModel.path.isEmpty)
            }
            
        }
        .padding()
        #if os(iOS)
        .fullScreenCover(isPresented: $viewModel.presentFolderPicker) {
            FolderPickerView { result in
                switch result {
                case .none:
                    break
                case .failure(let error):
                    print(error)
                case .success(let url):
                    viewModel.setURL(url)
                }
            }
        }
        #endif
    }
}

private extension FileFormat {
    var defaultFileName: String {
        switch self {
        case .androidXML: return "android.\(rawValue)"
        case .appleStrings: return "apple.\(rawValue)"
        case .json: return "web.\(rawValue)"
        }
    }
}

#Preview {
    ExportExpressionsView(
        expressions: []
    ) {
    }
}
