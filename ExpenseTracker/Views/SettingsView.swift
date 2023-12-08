//
//  SettingsView.swift
//  ExpenseTracker
//
//  Created by Robert-Dumitru Oprea on 03/12/2023.
//

import SwiftUI
import CoreData

struct SettingsView: View {
    @EnvironmentObject var storageProvider: StorageProvider
    var body: some View {
        NavigationStack {
            Form {
                Section("Settings") {
                    List {
                        NavigationLink(destination: BankAccountsView(viewModel: BankAccountsViewModel(storageProvider: storageProvider))) {
                            Text("Bank Accounts")
                        }
                        NavigationLink(destination: CategoriesView(viewModel: CategoriesViewModel(storageProvider: storageProvider))) {
                            Text("Categories")
                        }

                    }
                }
            }
        }
    }
}


