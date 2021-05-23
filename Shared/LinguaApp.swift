//
//  LinguaApp.swift
//  Shared
//
//  Created by Richard Piazza on 5/22/21.
//

import SwiftUI

@main
struct LinguaApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
//            ContentView()
//                .environment(\.managedObjectContext, persistenceController.container.viewContext)
            MainWindow()
                .environmentObject(AppEnvironment())
        }
    }
}
