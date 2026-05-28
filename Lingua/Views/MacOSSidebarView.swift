import SwiftUI
import TranslationCatalog

#if os(macOS)
struct MacOSSidebarView: View {

    @Binding var contentScheme: ContentScheme

    @Environment(\.storageContainer) private var storageContainer
    @State private var projects: [Project] = []
    @State private var createProject: Bool = false
    @State private var projectName: String = ""
    @State private var confirmDelete: Bool = false
    @State private var deleteProject: Project?

    var body: some View {
        List(selection: $contentScheme) {
            Section {
                ForEach(ContentScheme.specialCases, id: \.self) { scheme in
                    ContentSchemeButton(
                        contentScheme: scheme,
                        selected: contentScheme == scheme,
                    ) {
                        contentScheme = scheme
                    }
                    .tag(scheme)
                }
            }

            Section(.SidebarView.projects) {
                ForEach(projects) { project in
                    Button {
                        contentScheme = .project(project.id)
                    } label: {
                        HStack {
                            Text(project.name)
                                .font(.headline)

                            Spacer()

                            Button {
                                deleteProject = project
                                confirmDelete = true
                            } label: {
                                Image(systemName: "minus.circle")
                            }
                            .buttonStyle(.borderless)
                        }
                    }
                    .buttonStyle(.plain)
                    .tag(ContentScheme.project(project.id))
                }

                Button {
                    createProject = true
                } label: {
                    HStack {
                        Text(.SidebarView.createProject)

                        Spacer()

                        Image(systemName: "plus.circle")
                    }
                    .foregroundStyle(Color.accentColor)
                }
                .buttonStyle(.borderless)
            }
            .foregroundStyle(Color.primary)
        }
        .listStyle(SidebarListStyle())
        .task {
            for await values in storageContainer.projects() {
                projects = values.sorted(using: storageContainer.projectComparator)
            }
        }
        .alert(.Create.ProjectView.title, isPresented: $createProject) {
            TextField(.Create.ProjectView.name, text: $projectName)

            Button(.ButtonTitle.cancel, role: .cancel) {}

            Button {
                createProjectNamed(projectName)
                projectName = ""
            } label: {
                Text(.ButtonTitle.create)
            }
            .disabled(projectName.isEmpty)
        } message: {
            Text(.Create.ProjectView.message)
        }
        .alert(.Delete.ProjectView.title, isPresented: $confirmDelete, presenting: deleteProject) { project in
            Button(.ButtonTitle.cancel, role: .cancel) {}
            Button(.ButtonTitle.remove, role: .destructive) {
                deleteProject(project.id)
            }
        } message: { project in
            Text(.Delete.ProjectView.message, project.name)
        }
    }

    private func createProjectNamed(_ name: String) {
        do {
            let project = try storageContainer.createProject(name)
            contentScheme = .project(project.id)
        } catch {}
    }

    private func deleteProject(_ id: Project.ID) {
        let resetSelection = contentScheme == .project(id)
        do {
            try storageContainer.deleteProject(id)
            if resetSelection {
                contentScheme = .catalog
            }
        } catch {}
    }
}

#Preview {
    @Previewable @State var contentScheme: ContentScheme = .catalog
    NavigationSplitView {
        MacOSSidebarView(
            contentScheme: $contentScheme,
        )
    } content: {
        EmptyView()
    } detail: {
        EmptyView()
    }
    .environment(\.storageContainer, .inMemoryContainer)
}
#endif
