//
//  TransactionDetailsView.swift
//  ExpenseTracker
//
//  Created by Robert-Dumitru Oprea on 05/12/2023.
//

import SwiftUI
import CoreData
import Combine

struct TransactionDetailsView: View {

    @ObservedObject var viewModel: TransactionDetailsViewModel

    @State var transactionDate = Date()
    @State var transactionMerchant = ""
    @State var transactionNote = ""
    @State var type: TransactionType = .expense
    @State var transactionAmount = ""
    @State var bankAccount: BankAccount?
    @State var category: Category?
    @State var categoryOn = true
    @State var editing = false

    var body: some View {
        NavigationStack {
            Form {

                if (!editing) {
                    VStack {
                        Text("Merchant: \(viewModel.transaction.sanitisedMerchant)")
                    }
                    VStack {
                        Text("Amount: \(viewModel.transaction.amount)")
                    }
                    VStack {
                        Text("Date: \(viewModel.transaction.sanitisedDate)")
                    }
                    VStack {
                        Text("Bank Account: \(viewModel.transaction.bankAccountName)")
                    }
                    VStack {
                        if let category = viewModel.transaction.category {
                            Text("Category:\(category.sanitisedName)")
                        } else {
                            Text("Uncategorized")
                        }
                    }
                    if let note = viewModel.transaction.note {
                        VStack(alignment: .leading) {
                            Text("Note")
                            Text(note)
                                .frame(maxWidth: .infinity)
                                .background {
                                Color.primary.opacity(0.1)
                            }
                        }
                    }

                } else {
                    EditTransactionView(transaction: $viewModel.transaction, transactionDate: $transactionDate, transactionMerchant: $transactionMerchant, transactionNote: $transactionNote, type: $type, transactionAmount: $transactionAmount, bankAccount: $bankAccount, category: $category, categoryOn: $categoryOn, bankAccounts: $viewModel.bankAccounts, categories: $viewModel.categories)


                }

            }
                .navigationTitle(editing ? "Edit Transaction" : "Transaction Details")
            #if os(iOS)
                .navigationBarTitleDisplayMode(.inline)
            #endif
            .onChange(of: editing) { oldValue, newValue in
                if (editing == false) {
                    viewModel.updateTransaction(bankAccount: bankAccount!, type: type, category: category!, amount: Double(transactionAmount) ?? 0.0, date: transactionDate, merchantName: transactionMerchant, note: transactionNote, categoryOn: categoryOn)
                } else {
                    let transaction = viewModel.transaction
                    bankAccount = transaction.bankAccount
                    transactionDate = transaction.safeDate
                    transactionMerchant = transaction.sanitisedMerchant
                    transactionNote = transaction.sanitisedNote
                    type = transaction.type
                    transactionAmount = String(transaction.sanitisedAmount)
                    if let tCategory = transaction.category {
                        categoryOn = true
                        category = tCategory
                    } else {
                        self.category = viewModel.categories.first
                        categoryOn = false
                    }
                }
            }
                .toolbar {
                Button {
                    editing.toggle()
                } label: {
                    Text(editing ? "Done" : "Edit")
                }

            }
        }

    }
}

class TransactionDetailsViewModel: NSObject, ObservableObject, NSFetchedResultsControllerDelegate {
    @Published var bankAccounts = [BankAccount]()
    @Published var categories = [Category]()
    var transaction: Transaction
    let storageProvider: StorageProvider
    let categoriesFetchResultsController: NSFetchedResultsController<Category>
    let bankAccountFetchResultsController: NSFetchedResultsController<BankAccount>

    init(storageProvider: StorageProvider, transaction: Transaction) {
        self.storageProvider = storageProvider
        self.transaction = transaction
        self.categoriesFetchResultsController = storageProvider.getCategoryNSFetchedResultsController()
        self.bankAccountFetchResultsController = storageProvider.getBankAccountNSFetchedResultsController()

        super.init()

        bankAccountFetchResultsController.delegate = self
        try! bankAccountFetchResultsController.performFetch()
        bankAccounts = bankAccountFetchResultsController.fetchedObjects ?? []

        categoriesFetchResultsController.delegate = self
        try! categoriesFetchResultsController.performFetch()
        categories = categoriesFetchResultsController.fetchedObjects ?? []
    }

    func updateTransaction(bankAccount: BankAccount, type: TransactionType, category: Category, amount: Double, date: Date, merchantName: String, note: String, categoryOn: Bool) {
        transaction.bankAccount = bankAccount
        transaction.type = type
        if categoryOn {
            transaction.category = category
        }
        transaction.amount = amount
        transaction.date = date
        transaction.merchant = merchantName
        transaction.note = note
        storageProvider.save()
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {

        if controller == categoriesFetchResultsController {
            categories = categoriesFetchResultsController.fetchedObjects ?? []
        } else if controller == bankAccountFetchResultsController {
            bankAccounts = bankAccountFetchResultsController.fetchedObjects ?? []
        }

    }
}

