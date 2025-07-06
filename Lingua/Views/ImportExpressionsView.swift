import LocaleSupport
import SwiftUI
import TranslationCatalog
import TranslationCatalogIO

struct ImportExpressionsView: View {
    
    var completion: () -> Void
    
    @Environment(\.storageContainer) private var storageContainer
    @State private var path: String = ""
    @State private var url: URL?
    @State private var fileFormat: FileFormat?
    @State private var defaultLanguage: LanguageCode = .default
    @State private var languageCode: LanguageCode?
    @State private var scriptCode: ScriptCode?
    @State private var regionCode: RegionCode?
    @State private var isSaving: Bool = false
    @State private var error: Error?
    @FocusState private var focused: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10.0) {
            VStack(alignment: .leading) {
                Text("Import Expressions")
                    .font(.title)
                
                Text("Add translations to the catalog.")
                    .font(.subheadline)
            }
            
            Picker(selection: $defaultLanguage) {
                ForEach(LanguageCode.allCases, id: \.self) { code in
                    Text("\(code.rawValue) (\(code.name))")
                        .tag(code)
                }
            } label: {
                Text("Default/Development Language")
            }
            .fixedSize()
            
            Divider()
            
            VStack(alignment: .leading) {
                Text("File")
                    .font(.title3)
                
                HStack {
                    TextField(text: $path) {
                        Text("File Path")
                    }
                    .focused($focused)
                    .onChange(of: path) { _, value in
                        url = URL(filePath: value, directoryHint: .notDirectory)
                    }
                    
                    Button {
                        selectURL()
                    } label: {
                        Image(systemName: "externaldrive")
                    }
                }
                
                Picker(selection: $fileFormat) {
                    Text("Select")
                        .tag(FileFormat?.none)
                    
                    ForEach(FileFormat.linguaFormats, id: \.self) { format in
                        Text(format.displayName)
                            .tag(FileFormat?.some(format))
                    }
                } label: {
                    Text("Format")
                        .font(.headline)
                }
                .fixedSize()
            }
            
            Divider()
            
            Text("Locale Identifier")
                .font(.title3)
            
            HStack(alignment: .top) {
                VStack(alignment: .leading) {
                    Text("Language")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Picker(selection: $languageCode) {
                        Text("Select")
                            .tag(LanguageCode?.none)
                        
                        ForEach(LanguageCode.allCases, id: \.self) { code in
                            Text("\(code.rawValue) (\(code.name))")
                                .tag(LanguageCode?.some(code))
                        }
                    } label: {}
                }
                
                VStack(alignment: .leading) {
                    Text("Script")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Picker(selection: $scriptCode) {
                        Text("")
                            .tag(ScriptCode?.none)
                        
                        ForEach(ScriptCode.allCases, id: \.self) { code in
                            Text("\(code.rawValue) (\(code.name))")
                                .tag(ScriptCode?.some(code))
                        }
                    } label: {}
                }
                
                VStack(alignment: .leading) {
                    Text("Region")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Picker(selection: $regionCode) {
                        Text("")
                            .tag(RegionCode?.none)
                        
                        ForEach(RegionCode.allCases, id: \.self) { code in
                            Text("\(code.rawValue) (\(code.name))")
                                .tag(RegionCode?.some(code))
                        }
                    } label: {}
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
                    performImport()
                } label: {
                    Text("Import")
                }
                .buttonStyle(.borderedProminent)
                .disabled(url == nil || fileFormat == nil || languageCode == nil)
                
                ProgressView()
                    .progressViewStyle(.circular)
                    .controlSize(.small)
                    .padding(.leading, 8)
                    .opacity(isSaving ? 1 : 0)
            }
            
            if let error {
                Text(error.localizedDescription)
                    .foregroundStyle(.red)
            }
        }
        .padding()
    }
    
    private func selectURL() {
        #if os(macOS)
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.canChooseFiles = true

        switch panel.runModal() {
        case .OK:
            if let url = panel.url {
                setURL(url)
            }
        default:
            setURL(nil)
        }
        #endif
    }
    
    private func setURL(_ url: URL?) {
        self.url = url
        path = url?.path ?? ""
    }
    
    private func performImport() {
        guard let url else {
            return
        }
        
        guard let fileFormat else {
            return
        }
        
        guard let languageCode else {
            return
        }
        
        error = nil
        isSaving = true
        defer {
            isSaving = false
        }
        
        do {
            let data = try Data(contentsOf: url)
            
            let expressions = try ExpressionDecoder.decodeExpressions(
                from: data,
                fileFormat: fileFormat,
                defaultLanguage: defaultLanguage,
                languageCode: languageCode,
                scriptCode: scriptCode,
                regionCode: regionCode
            )
            
            try storageContainer.importExpressions(expressions)
            
            completion()
        } catch {
            self.error = error
        }
    }
}

#Preview {
    ImportExpressionsView {
    }
    .environment(\.storageContainer, .inMemoryContainer)
}
