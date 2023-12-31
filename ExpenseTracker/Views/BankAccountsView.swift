//
//  BankAccountsView.swift
//  ExpenseTracker
//
//  Created by Robert-Dumitru Oprea on 03/12/2023.
//

import SwiftUI
import CoreData

struct BankAccountsView: View {
    @ObservedObject var viewModel: BankAccountsViewModel
    @State var isShowingAddBankAccountSheet = false
    @Binding var selectedTab: Int
    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.bankAccounts) { bankAccount in
                    NavigationLink {
                        BankAccountDetailsView(viewModel: BankAccountDetailsViewModel(bankAccount: bankAccount, storageProvider: viewModel.storageProvider))
                    } label: {
                        Text(bankAccount.name ?? "Not known")
                    }
                }
                    .onDelete(perform: viewModel.delete)
            }
//                HStack {
//                    Button {
//                        viewModel.addData()
//                    } label: {
//                        Text("Add Data!")
//                    }
//                    Spacer()
//
//                    Button {
//                        viewModel.storageProvider.deleteAll()
//                    } label: {
//                        Text("Delete All")
//                    }
//                }
            .sheet(isPresented: $isShowingAddBankAccountSheet) {
                AddBankAccountView()
            }
                .toolbar {
                if selectedTab == 1 {
                    Button {
                        isShowingAddBankAccountSheet.toggle()
                    } label: {
                        Image(systemName: "plus.circle")
                    }
                }
            }
                .navigationTitle("Bank Accounts")
            #if os(iOS)
                .navigationBarTitleDisplayMode(.inline)
            #endif
        }
    } }

class BankAccountsViewModel: NSObject, ObservableObject, NSFetchedResultsControllerDelegate {

    @Published var bankAccounts = [BankAccount]()
    let storageProvider: StorageProvider
    private let fetchResultsController: NSFetchedResultsController<BankAccount>
    init(storageProvider: StorageProvider) {
        self.storageProvider = storageProvider
        self.fetchResultsController = storageProvider.getBankAccountNSFetchedResultsController()

        super.init()

        fetchResultsController.delegate = self
        try! fetchResultsController.performFetch()
        bankAccounts = fetchResultsController.fetchedObjects ?? []
    }


    func addData() {
        storageProvider.mockBankAccount()
    }

    func delete(_ offsets: IndexSet) {
        for offset in offsets {
            let item = bankAccounts[offset]
            storageProvider.delete(item)
        }
    }
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        DispatchQueue.main.async {
            self.bankAccounts = controller.fetchedObjects as? [BankAccount] ?? []
        }
    }
}


