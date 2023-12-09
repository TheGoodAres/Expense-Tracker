//
//  CategoryDetailsView.swift
//  ExpenseTracker
//
//  Created by Robert-Dumitru Oprea on 08/12/2023.
//

import SwiftUI
import CoreData

struct CategoryDetailsView: View {
    @State var viewModel: CategoryDetailsViewModel
    var body: some View {
        NavigationStack {
            Form{
                HStack {
                    Text("Category name: ")
                    Text(viewModel.category.sanitisedName)
                }
                if let parentCategory = viewModel.category.parentCategory {
                    HStack {
                        Text("Parent Company: ")
                        NavigationLink(destination: CategoryDetailsView(viewModel: CategoryDetailsViewModel(category: parentCategory, storageProvider: viewModel.storageProvider))) {
                            Text(parentCategory.sanitisedName)
                        }
                    }
                }
            }
            .navigationTitle("Category")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}


class CategoryDetailsViewModel: NSObject, ObservableObject, NSFetchedResultsControllerDelegate{
    let storageProvider: StorageProvider
    var categories = [Category]()
    let category: Category
    let fetchResultsController: NSFetchedResultsController<Category>
    init(category: Category, storageProvider: StorageProvider) {
        self.category = category
        self.storageProvider = storageProvider
        fetchResultsController = storageProvider.getCategoryNSFetchedResultsController()
        
        super.init()
        
        fetchResultsController.delegate = self
        try! fetchResultsController.performFetch()
        categories = fetchResultsController.fetchedObjects ?? []
        
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        categories = fetchResultsController.fetchedObjects ?? []
    }
}

