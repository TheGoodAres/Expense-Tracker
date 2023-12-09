//
//  AddTransactionView.swift
//  ExpenseTracker
//
//  Created by Robert-Dumitru Oprea on 03/12/2023.
//

import SwiftUI
import CoreData
import Combine

struct AddTransactionView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: AddTransctionViewModel
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


                Button("Submit") {
                    viewModel.storageProvider.addTransaction(bankAccount: bankAccount!, type: type, category: category, amount: Double(transactionAmount) ?? 0.0, date: transactionDate, merchantName: transactionMerchant, note: transactionNote, categoryOn: categoryOn
                    )
                    dismiss()

                }
                    .disabled(transactionAmount.isEmpty || transactionMerchant.isEmpty || (viewModel.bankAccounts.isEmpty))

                if(viewModel.bankAccounts.isEmpty) {
                    Text("There are no bank accounts, please add at least one to be able to add a transaction!")
                        .font(.caption2)
                        .foregroundStyle(Color.red)
                }

            }
                .onAppear {
                category = viewModel.categories.first
                bankAccount = viewModel.bankAccounts.first

            }
        }
    }
}

class AddTransctionViewModel: NSObject, ObservableObject, NSFetchedResultsControllerDelegate {
    @Published var bankAccounts = [BankAccount]()
    @Published var categories = [Category]()
    let storageProvider: StorageProvider
    private let fetchResultsControllerBankAccounts: NSFetchedResultsController<BankAccount>
    private let fetchResultsControllerCategories: NSFetchedResultsController<Category>

    init(storageProvider: StorageProvider) {
        self.storageProvider = storageProvider

        self.fetchResultsControllerBankAccounts = storageProvider.getBankAccountNSFetchedResultsController()
        self.fetchResultsControllerCategories = storageProvider.getCategoryNSFetchedResultsController()

        super.init()

        fetchResultsControllerCategories.delegate = self
        try! fetchResultsControllerCategories.performFetch()
        categories = fetchResultsControllerCategories.fetchedObjects ?? []

        fetchResultsControllerBankAccounts.delegate = self
        try! fetchResultsControllerBankAccounts.performFetch()
        bankAccounts = fetchResultsControllerBankAccounts.fetchedObjects ?? []

    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        DispatchQueue.main.async {
            if controller == self.fetchResultsControllerCategories {
                self.categories = self.fetchResultsControllerCategories.fetchedObjects ?? []
            } else if controller == self.fetchResultsControllerBankAccounts {
                self.bankAccounts = self.fetchResultsControllerBankAccounts.fetchedObjects ?? []
            }
        }
    }
}

