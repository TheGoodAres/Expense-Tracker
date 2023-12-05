//
//  ExpenseTrackerApp.swift
//  ExpenseTracker
//
//  Created by Robert-Dumitru Oprea on 17/11/2023.
//

import SwiftUI

@main
struct ExpenseTrackerApp: App {
    @StateObject var storageProvider = StorageProvider()
    var body: some Scene {

        WindowGroup {
            ContentView()
                .environmentObject(storageProvider)
        }
    }
}
