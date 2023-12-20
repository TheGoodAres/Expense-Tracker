//
//  Reset.swift
//  ExpenseTracker
//
//  Created by Robert-Dumitru Oprea on 18/12/2023.
//

import SwiftUI

struct TestingView: View {
    @EnvironmentObject var storageProvider: StorageProvider
    var body: some View {
        VStack {
            Button("Add Mock Data") {
                storageProvider.mockBankAccount()
            }
            Button("Delete everythings") {
                storageProvider.deleteAll()
            }
        }
        
    }
}



