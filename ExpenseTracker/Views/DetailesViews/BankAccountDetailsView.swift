//
//  BankAccountView.swift
//  ExpenseTracker
//
//  Created by Robert-Dumitru Oprea on 02/12/2023.
//

import SwiftUI
import CoreData
import Charts

struct BankAccountDetailsView: View {
    @ObservedObject var viewModel: BankAccountDetailsViewModel

    @State var editing = false
    @State var bankAccountName: String = ""
    @State var initialAmount: String = ""
    @State var bankAccountType: BankAccountType = .debit
    private let chartColors: [Color] = [Color.green, Color.red]
    var body: some View {
        NavigationStack {
            VStack {
                if (!editing) {
                    VStack {
                        Text(viewModel.bankAccount.sanitisedName)
                        Text(viewModel.bankAccount.type.rawValue.capitalized)
                        Text("Initial Balance: \(viewModel.bankAccount.initialBalance.formatted()) £")
                        Text("Current Balanace: \(viewModel.bankAccount.currentBalance.formatted()) £")
                        Chart {
                            ForEach(viewModel.chartValues, id:\.name) { category in
                                SectorMark(
                                    angle: .value("sum", category.sum),
                                    angularInset: 0.5                        )
                                .foregroundStyle(by: .value("Test", category.name))
                                .annotation(position: .overlay) {
                                    if (category.sum > 0 ){
                                        Text("\(category.sum.formatted())")
                                            .font(.headline)
                                            .foregroundStyle(.white)
                                    }
                                }
                            
                            }
                        }
                        .chartForegroundStyleScale(domain: .automatic, range: chartColors)
                        List {
                            ForEach(viewModel.transactions) { transaction in
                                SmallTransactionView(transaction: transaction)
                                    .listRowBackground(transaction.type == .income ? Color.green : Color.red)
                            }
                                .onDelete(perform: viewModel.delete)
                        }
                    }
                } else {
                    EditBankAccountView(bankAccountName: $bankAccountName, initialBalance: $initialAmount, bankAccountType: $bankAccountType)
                }
            }
                .toolbar {
                Button {
                    editing.toggle()
                } label: {
                    Text(editing ? "Done" : "Edit")
                }
                    .onChange(of: editing) { oldValue, newValue in
                    if (editing == false) {
                        viewModel.updateBankAccount(accountName: bankAccountName, accountType: bankAccountType, initialBalance: initialAmount)
                    } else {
                        let bankAccount = viewModel.bankAccount
                        bankAccountName = bankAccount.sanitisedName
                        initialAmount = String(bankAccount.initialBalance)
                        bankAccountType = bankAccount.type
                    }
                }
            }
        }
    }
}

class BankAccountDetailsViewModel: NSObject, ObservableObject, NSFetchedResultsControllerDelegate {
    @Published var transactions: [Transaction] = []
    @Published var chartValues: [PieChartData] = []
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
        updateChartData()
    }

    func delete(_ offsets: IndexSet) {
        for offset in offsets {
            let item = transactions[offset]
            storageProvider.delete(item)
        }
    }
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.transactions = controller.fetchedObjects as? [Transaction] ?? []
        updateChartData()
    }
    func updateBankAccount(accountName: String, accountType: BankAccountType, initialBalance: String) {
        bankAccount.name = accountName
        bankAccount.type = accountType
        bankAccount.initialBalance = Double(initialBalance) ?? 0.0
        storageProvider.updateBalance(bankAccount: bankAccount)
        storageProvider.save()

    }
    func updateChartData() {
        chartValues = []
        var incomeChart = PieChartData(name: "Income", sum: 0.0)
        var expenseChart = PieChartData(name: "Expense", sum: 0.0)
        for transaction in transactions {
            if transaction.type == .expense {
                expenseChart.sum += transaction.amount
            } else {
                incomeChart.sum += transaction.amount
            }
        }
        chartValues.append(incomeChart)
        chartValues.append(expenseChart)
    }
}


