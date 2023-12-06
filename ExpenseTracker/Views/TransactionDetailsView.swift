//
//  TransactionDetailsView.swift
//  ExpenseTracker
//
//  Created by Robert-Dumitru Oprea on 05/12/2023.
//

import SwiftUI
import CoreData

struct TransactionDetailsView: View {
    @ObservedObject var viewModel: TransactionDetailsViewModel
    var body: some View {
        VStack {
            Text("Merchant: \(viewModel.transaction.sanitisedMerchant)")
            Text("Amount: \(viewModel.transaction.sanitisedAmount.formatted())")
            Text("Date: \(viewModel.transaction.sanitisedDate)")
            if let  category = viewModel.transaction.category {
                Text("Category:\(category.sanitisedName)")
            } else {
                Text("Uncategorized")
            }
        }
    }
}

class TransactionDetailsViewModel: NSObject, ObservableObject {
    @Published var bankAccounts = [BankAccount]()
    @Published var categories = [Category]()
    var transaction: Transaction
    let storageProvider: StorageProvider
    let categoriesFetchResultsController: NSFetchedResultsController<Category>
    let bankAccountFetchResultsController: NSFetchedResultsController<BankAccount>

    init(storageProvider: StorageProvider, transaction: Transaction) {
        self.storageProvider = storageProvider
        self.transaction = transaction
        let categoriesFetchRequest = Category.fetchRequest()
        let bankAccountFetchRequest = BankAccount.fetchRequest()
        categoriesFetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Category.name, ascending: false)]
        bankAccountFetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \BankAccount.name, ascending: false)]

        self.categoriesFetchResultsController = NSFetchedResultsController(fetchRequest: categoriesFetchRequest, managedObjectContext: storageProvider.persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        self.bankAccountFetchResultsController = NSFetchedResultsController(fetchRequest: bankAccountFetchRequest, managedObjectContext: storageProvider.persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)

        super.init()

        bankAccountFetchResultsController.delegate = self
        try! bankAccountFetchResultsController.performFetch()
        bankAccounts = bankAccountFetchResultsController.fetchedObjects ?? []

        categoriesFetchResultsController.delegate = self
        try! categoriesFetchResultsController.performFetch()
        categories = categoriesFetchResultsController.fetchedObjects ?? []
    }
}

extension TransactionDetailsViewModel: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        if controller == categoriesFetchResultsController {
            categories = categoriesFetchResultsController.fetchedObjects ?? []
        } else if controller == bankAccountFetchResultsController {
            bankAccounts = bankAccountFetchResultsController.fetchedObjects ?? []
        }
    }
}
