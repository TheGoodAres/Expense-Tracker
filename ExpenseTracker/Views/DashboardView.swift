//
//  DashboardView.swift
//  ExpenseTracker
//
//  Created by Robert-Dumitru Oprea on 04/12/2023.
//

import SwiftUI
import CoreData
import Charts

struct DashboardView: View {
    @ObservedObject var viewModel: DashboardViewModel
    var body: some View {
        NavigationStack{
            VStack{
                Button("Change to \(viewModel.income ? "expense" : "income")") {
                    viewModel.income.toggle()
                    viewModel.getPieChartData()
                    
                }
                Chart {
                    ForEach(viewModel.pieChartData, id:\.name) { category in
                        SectorMark(
                            angle: .value("sum", category.sum),
                            angularInset: 0.5                        )
                        .foregroundStyle(by: .value("Test", category.name))
                        .annotation(position: .overlay) {
                            if (category.sum > 0) {
                                Text("\(category.sum.formatted())")
                                    .font(.headline)
                                    .foregroundStyle(.white)
                            }
                        }
                    
                    }
                }
                .frame(width: 300, height: 300)
                List {
                    ForEach(viewModel.pieChartData, id: \.name) {category in
                        HStack {
                            Text(category.name)
                            Spacer()
                            Text(category.sum.formatted())
                            Text("")
                        }
                    }
                }
            }
            .navigationTitle(viewModel.income ? "Income" : "Expense")
        }
    }
    
}

class DashboardViewModel: NSObject, ObservableObject, NSFetchedResultsControllerDelegate {
    @Published var transactions = [Transaction]()
    @Published var categories = [Category]()
    @Published var pieChartData = [PieChartData]()
    @Published var income = false
    let storageProvider: StorageProvider
    let fetchedResultsControllerCategory: NSFetchedResultsController<Category>
    let fetchedResultsControllerTransactions: NSFetchedResultsController<Transaction>
    
    init(storageProvider: StorageProvider) {
        self.storageProvider = storageProvider
        self.fetchedResultsControllerCategory = storageProvider.getCategoryNSFetchedResultsController()
        self.fetchedResultsControllerTransactions =
        storageProvider.getTransactionNSFetchedResultsController()
        super.init()
        fetchedResultsControllerCategory.delegate = self
        try! fetchedResultsControllerCategory.performFetch()
        categories = fetchedResultsControllerCategory.fetchedObjects ?? []
        
        fetchedResultsControllerTransactions.delegate = self
        try! fetchedResultsControllerTransactions.performFetch()
        transactions = fetchedResultsControllerTransactions.fetchedObjects ?? []
        getPieChartData()
    }
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        if controller == fetchedResultsControllerTransactions{
            self.transactions = controller.fetchedObjects as? [Transaction] ?? []
        } else if controller == fetchedResultsControllerCategory {
            self.categories = controller.fetchedObjects as? [Category] ?? []
        }
        getPieChartData()
    }
    
    func getPieChartData(){
        var data: [PieChartData] = [PieChartData]()
        for x in 0..<(categories.count) {
            let category = categories[x]
            let fetchRequest = Transaction.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "category == %@", category)
            
            let transactions = try? storageProvider.persistentContainer.viewContext.fetch(fetchRequest)
            var sum = 0.0
            for y in 0..<(transactions?.count ?? 0) {
                if let transaction = transactions?[y]{
                    if transaction.type == (self.income ? .income : .expense) {
                        sum += transaction.sanitisedAmount
                    }
                }
            }
            let pieChartData = PieChartData(name: category.sanitisedName, sum: sum)
            data.append(pieChartData)
        }
        
        self.pieChartData = data
    }
}

struct PieChartData {
    var name: String
    var sum: Double
}
