//
//  ViewTransactionsToolbar.swift
//  ExpenseTracker
//
//  Created by Robert-Dumitru Oprea on 09/12/2023.
//

import SwiftUI

struct ViewTransactionsToolbar: View {
    @EnvironmentObject var storageProvider: StorageProvider
    
    var body: some View {
        Menu {
            Button {
                
            } label: {
                Text("Hello")
            }
        } label: {
            Label("Filter", systemImage: "line.3.horizontal.decrease.circle")
        }
    }
}

struct ContentViewToolbar_Previews: PreviewProvider {
    static var previews: some View {
        ViewTransactionsToolbar()
            .environmentObject(StorageProvider())
    }
}
