import SwiftUI

struct WelcomeView: View {
    
    @Environment(\.openWindow) private var openWindow
    @State private var recents: [StorageDescriptor] = StorageDescriptor.recents
    
    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            VStack(spacing: 16) {
                Image("Icon")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                
                VStack(spacing: 4) {
                    Text("Lingua")
                        .font(.largeTitle)
                        .bold()
                    
                    Text("Translation Catalog")
                        .font(.body)
                }
                .padding(.bottom)
                
                VStack(spacing: 8) {
                    Button {
                    } label: {
                        Label("Create New Catalog…", systemImage: "plus")
                            .symbolVariant(.square)
                            .padding(8)
                            .frame(maxWidth: 300)
                    }
                    .buttonStyle(.borderedProminent)
                    
                    Button {
                    } label: {
                        Label("Open Existing Catalog…", systemImage: "folder")
                            .padding(8)
                            .frame(maxWidth: 300)
                    }
                    .buttonStyle(.bordered)
                }
            }
            .padding()
            .frame(width: 460)
            .frame(maxHeight: .infinity)
            .background()
            
            VStack {
                if recents.isEmpty {
                    Text("No Recent Catalogs")
                        .font(.body)
                } else {
                    Text("Recent")
                        .font(.callout)
                        .frame(maxWidth: .infinity)
                    
                    ScrollView {
                        ForEach(recents) { descriptor in
                            Button {
                                openWindow(id: "MainWindow", value: descriptor)
                            } label: {
                                StorageDescriptorView(
                                    storageDescriptor: descriptor
                                )
                                .padding()
                                .background()
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

#Preview {
    WelcomeView()
        .containerBackground(.thinMaterial, for: .window)
        .frame(width: 750, height: 450)
}
