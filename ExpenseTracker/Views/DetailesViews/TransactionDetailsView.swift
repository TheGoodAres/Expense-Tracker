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
    @Environment(\.editMode) var editMode
    @ObservedObject var viewModel: TransactionDetailsViewModel

    @State var transactionDate = Date()
    @State var transactionMerchant = ""
    @State var transactionNote = ""
    @State var type: TransactionType = .expense
    @State var transactionAmount = ""
    @State var bankAccount: BankAccount?
    @State var category: Category?
    @State var categoryOn = true
    @FocusState var amountIsActive: Bool
    @FocusState var merchantIsActive: Bool
    @FocusState var noteIsActive: Bool

    var body: some View {
        NavigationStack {
            Form {
                if (editMode?.wrappedValue.isEditing == false) {
                    VStack(alignment: .leading) {
                        Text("Merchant: \(viewModel.transaction.sanitisedMerchant)")
                        Text("Amount: \(viewModel.transaction.amount)")
                        Text("Date: \(viewModel.transaction.sanitisedDate)")
                        Text("Bank Account: \(viewModel.transaction.bankAccountName)")
                        if let category = viewModel.transaction.category {
                            Text("Category:\(category.sanitisedName)")
                        } else {
                            Text("Uncategorized")
                        }
                    }
                } else {
                    Section("Add Transaction") {

                        Picker("Bank Account", selection: $bankAccount) {
                            ForEach(viewModel.bankAccounts) { bankAccount in
                                Text(bankAccount.sanitisedName).tag(bankAccount as BankAccount?)
                            }
                        }
                        Picker("Type", selection: $type) {
                            ForEach(TransactionType.allCases, id: \.rawValue) { type in
                                Text(type.rawValue.capitalized).tag(type)
                            }
                        }
                        HStack {
                            Text("Category enabled:")
                            Spacer()
                            Button {
                                categoryOn.toggle()
                            } label: {
                                Text(categoryOn ? "On" : "Off")
                            }
                        }
                        //.tag was require to make the pickers in this view work
                        Picker("Category", selection: $category) {
                            ForEach(viewModel.categories) { category in
                                Text(category.name?.capitalized ?? "No Name").tag(category as Category?)
                            }
                        }
                            .disabled(!categoryOn)
                        VStack(alignment: .leading, spacing: 0) {
                            Text("Amount")
                            TextField("Amount", text: $transactionAmount)
                                .keyboardType(.decimalPad)
                                .focused($amountIsActive)
                                .toolbar {
                                ToolbarItemGroup(placement: .keyboard) {
                                    Spacer()

                                    Button("Done") {
                                        if amountIsActive {
                                            amountIsActive.toggle()
                                        }
                                        if merchantIsActive {
                                            merchantIsActive.toggle()
                                        }
                                        if noteIsActive {
                                            noteIsActive.toggle()
                                        }
                                    }
                                }
                            }
                                .onReceive(Just(transactionAmount)) { newValue in
                                let filtered = newValue.filter { "0123456789.".contains($0) }
                                if filtered != newValue {
                                    self.transactionAmount = filtered
                                }
                            }
                        }

                        DatePicker("Date:", selection: $transactionDate, displayedComponents: [.date])
                        VStack(alignment: .leading, spacing: 0) {
                            Text("Merchant Name")
                                .font(.caption2)
                            TextField("Merchant Name", text: $transactionMerchant, prompt: Text("Required"))
                                .focused($merchantIsActive)
                        }

                        VStack(alignment: .leading, spacing: 0) {
                            Text("Note")
                            ZStack {
                                TextEditor(text: $transactionNote)
                                    .focused($noteIsActive)

                                Text(transactionNote).opacity(0).padding(.all, 8)
                            }
                        }
                    }
                }


            }
                .onChange(of: editMode?.wrappedValue) { oldValue, newValue in
                if (newValue?.isEditing == false) {
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
                EditButton()

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

