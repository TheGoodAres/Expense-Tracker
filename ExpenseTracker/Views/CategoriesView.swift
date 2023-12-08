//
//  CategoriesView.swift
//  ExpenseTracker
//
//  Created by Robert-Dumitru Oprea on 08/12/2023.
//

import SwiftUI
import CoreData
struct CategoriesView: View {

    @State var viewModel: CategoriesViewModel
    @State var showSheet = false
    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.categories) { category in
                    Text(category.sanitisedName)
                }
            }
        }
        .sheet(isPresented: $showSheet) {
            AddCategoryView(viewModel: AddCategoryViewModel(storageProvider: viewModel.storageProvider))
        }
        .toolbar{
            Button {
                showSheet.toggle()
            } label: {
                Image(systemName: "plus.circle")
            }
        }

    }
}

class CategoriesViewModel: NSObject, ObservableObject, NSFetchedResultsControllerDelegate {
    @Published var categories = [Category]()
    let storageProvider: StorageProvider
    let fetchResultsController: NSFetchedResultsController<Category>
    
    init(storageProvider: StorageProvider) {
        self.storageProvider = storageProvider
        let categoriesFetchRequest = Category.fetchRequest()
        categoriesFetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Category.name, ascending: false)]
        
        self.fetchResultsController = NSFetchedResultsController(fetchRequest: categoriesFetchRequest, managedObjectContext: storageProvider.persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        
        super.init()
        
        fetchResultsController.delegate = self
        try! fetchResultsController.performFetch()
        categories = fetchResultsController.fetchedObjects ?? []
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        categories = fetchResultsController.fetchedObjects ?? []
    }
}
