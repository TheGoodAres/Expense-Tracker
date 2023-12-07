//
//  SmallTransactionView.swift
//  ExpenseTracker
//
//  Created by Robert-Dumitru Oprea on 06/12/2023.
//

import SwiftUI

struct SmallTransactionView: View {
    @EnvironmentObject var storageProvider: StorageProvider
    var transaction: Transaction
    var body: some View {
        NavigationLink(destination: TransactionDetailsView(viewModel: TransactionDetailsViewModel(storageProvider: storageProvider, transaction: transaction))) {
            HStack {
                VStack(alignment: .leading) {
                    Text(transaction.merchant ?? "No Merchant")
                        .font(.headline)
                    Text("\(transaction.sanitisedAmount.formatted()) £")
                        .font(.subheadline)
                }
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                Spacer()
                Text(transaction.category?.name ?? "No name category")
                Spacer()
                Text(transaction.sanitisedDate)
            }
        }
    }
}

