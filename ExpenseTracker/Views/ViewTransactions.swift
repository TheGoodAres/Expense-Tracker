//
//  ViewTransactions.swift
//  ExpenseTracker
//
//  Created by Robert-Dumitru Oprea on 02/12/2023.
//

import SwiftUI
import CoreData

struct ViewTransactions: View {
    @ObservedObject var viewModel: ViewTransactionsModel
    @State var searchText = ""
    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.transactions.filter {
                    if let categoryName = $0.category?.sanitisedName {
                        $0.bankAccountName.contains(searchText) || $0.sanitisedMerchant.contains(searchText) || String($0.sanitisedAmount).contains(searchText) || $0.sanitisedDate.contains(searchText) || searchText == "" || categoryName.contains(searchText) }
                    else {
                        $0.bankAccountName.contains(searchText) || $0.sanitisedMerchant.contains(searchText) || String($0.sanitisedAmount).contains(searchText) || $0.sanitisedDate.contains(searchText) || searchText == ""
                    }
                }) { transaction in
                    SmallTransactionView(transaction: transaction)
                        .listRowBackground(transaction.type == .expense ? Color.red : Color.green)
                }
                    .onDelete(perform: viewModel.delete)
            }
                .navigationTitle("Transactions")
            #if os(iOS)
                .navigationBarTitleDisplayMode(.inline)
            #endif

        }
            .searchable(text: $searchText)
    }
}

class ViewTransactionsModel: NSObject, ObservableObject {
    @Published var transactions = [Transaction]()

    let storageProvider: StorageProvider
    private let fetchResultsControler: NSFetchedResultsController<Transaction>
    init(storageProvider: StorageProvider) {
        self.storageProvider = storageProvider


        self.fetchResultsControler = storageProvider.getTransactionNSFetchedResultsController()
        super.init()

        fetchResultsControler.delegate = self
        try! fetchResultsControler.performFetch()
        transactions = fetchResultsControler.fetchedObjects ?? []
    }

    func delete(_ offsets: IndexSet) {
        for offset in offsets {
            let item = transactions[offset]

            storageProvider.delete(item)
        }
    }
}

extension ViewTransactionsModel: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        DispatchQueue.main.async {

            self.transactions = controller.fetchedObjects as? [Transaction] ?? []
        }
    }
}
