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
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.transactions) { transaction in
                    SmallTransactionView(transaction: transaction)
                }
                .onDelete(perform: viewModel.delete)
            }
            .navigationTitle("Transactions")
            
        }
    }
}

class ViewTransactionsModel: NSObject, ObservableObject {
    @Published var transactions = [Transaction]()
    
    let storageProvider: StorageProvider
    private let fetchResultsControler: NSFetchedResultsController<Transaction>
    init(storageProvider: StorageProvider) {
        self.storageProvider = storageProvider

        let fetchRequest: NSFetchRequest<Transaction> = Transaction.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Transaction.date, ascending: false)]
        self.fetchResultsControler = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: storageProvider.persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
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
