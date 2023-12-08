//
//  BankAccountView.swift
//  ExpenseTracker
//
//  Created by Robert-Dumitru Oprea on 02/12/2023.
//

import SwiftUI
import CoreData

struct BankAccountDetailsView: View {
    @ObservedObject var viewModel: BankAccountDetailsViewModel
    var body: some View {
        VStack {
            Text(viewModel.bankAccount.sanitisedName)
            Text(viewModel.bankAccount.type.rawValue)
            Text("Initial Balance: \(viewModel.bankAccount.initialBalance.formatted()) £")
            Text("Current Balanace: \(viewModel.bankAccount.currentBalance.formatted()) £")
            
            List {
                ForEach(viewModel.transactions) {transaction in
                    SmallTransactionView(transaction: transaction)
                }
                .onDelete(perform: viewModel.delete)
            }
        }
    }
}

class BankAccountDetailsViewModel: NSObject, ObservableObject {
    @Published var transactions: [Transaction] = []
    var bankAccount: BankAccount
    let storageProvider: StorageProvider
    private let fetchResultsControler: NSFetchedResultsController<Transaction>

    init(bankAccount: BankAccount, storageProvider: StorageProvider) {
        self.storageProvider = storageProvider
        self.bankAccount = bankAccount


        let fetchRequest: NSFetchRequest<Transaction> = Transaction.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "bankAccount == %@", bankAccount)
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

extension BankAccountDetailsViewModel : NSFetchedResultsControllerDelegate {
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        DispatchQueue.main.async {
            self.transactions = controller.fetchedObjects as? [Transaction] ?? []
        }
    }
}

