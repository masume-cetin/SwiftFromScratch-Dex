//
//  DexApp.swift
//  Dex
//
//  Created by masume çetin on 10.07.2025.
//

import SwiftUI

@main
struct DexApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
