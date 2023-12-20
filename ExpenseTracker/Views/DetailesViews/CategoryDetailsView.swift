//
//  CategoryDetailsView.swift
//  ExpenseTracker
//
//  Created by Robert-Dumitru Oprea on 08/12/2023.
//

import SwiftUI
import CoreData

struct CategoryDetailsView: View {
    @ObservedObject var viewModel: CategoryDetailsViewModel
    @State var child = [Category]()
    var body: some View {
        NavigationStack {
            Form {
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
                VStack {
                    NavigationLink{ SelectChildCategoriesView(selectedCategories: $child, viewModel: SelectChildCategoriesViewModel(storageProvider: viewModel.storageProvider, category: viewModel.category)) } label:
                    {
                        Text("Here")
                    }
                    
                    
                    List{
                        ForEach(child) { childCategory in
                            Text(childCategory.sanitisedName)
                            
                        }
                    }
                }
            }
                .navigationTitle("Category")
            #if os(iOS)
                .navigationBarTitleDisplayMode(.inline)
            #endif
        }
    }
}


class CategoryDetailsViewModel: NSObject, ObservableObject, NSFetchedResultsControllerDelegate {
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

