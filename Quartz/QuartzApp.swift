//
//  QuartzApp.swift
//  Quartz
//
//  Created by Austin Firestone on 10/6/24.
//

import SwiftUI

@main
struct QuartzApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
