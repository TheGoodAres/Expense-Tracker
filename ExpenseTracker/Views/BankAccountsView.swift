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
    var body: some View {
        NavigationStack {
            VStack {
                List {
                    ForEach(viewModel.bankAccounts) { bankAccount in
                        NavigationLink {
                            BankAccountDetailsView(viewModel: BankAccountDetailsViewModel(bankAccount: bankAccount, storageProvider: viewModel.storageProvider))
                        } label: {
                            Text(bankAccount.name ?? "Not known")
                        }
                    }
                }
                HStack {
                    Button {
                        viewModel.addData()
                    } label: {
                        Text("Add Data!")
                    }
                    Spacer()
                    Button {
                        isShowingAddBankAccountSheet.toggle()
                    } label: {
                        Text("Add Bank Account")
                    }
                }
                .sheet(isPresented: $isShowingAddBankAccountSheet) {
                    AddBankAccountView()
                }
            }
        }
    }}

class BankAccountsViewModel: NSObject, ObservableObject {
    
    @Published var bankAccounts = [BankAccount]()
    let storageProvider: StorageProvider
    private let fetchResultsController: NSFetchedResultsController<BankAccount>
    init(storageProvider: StorageProvider) {
        self.storageProvider = storageProvider
        let request: NSFetchRequest<BankAccount> = BankAccount.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \BankAccount.name, ascending: false)]

        self.fetchResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: storageProvider.persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)

        super.init()

        fetchResultsController.delegate = self
        try! fetchResultsController.performFetch()
        bankAccounts = fetchResultsController.fetchedObjects ?? []
    }


    func addData() {
        storageProvider.mockBankAccount()
    }
}

extension BankAccountsViewModel: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        DispatchQueue.main.async {
            self.bankAccounts = controller.fetchedObjects as? [BankAccount] ?? []
        }
    }
}

