//
//  CategoriesView.swift
//  ExpenseTracker
//
//  Created by Robert-Dumitru Oprea on 08/12/2023.
//

import SwiftUI
import CoreData
struct CategoriesView: View {

    @ObservedObject var viewModel: CategoriesViewModel
    @State var showSheet = false
    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.categories) { category in
                    NavigationLink(destination: CategoryDetailsView(viewModel: CategoryDetailsViewModel(category: category, storageProvider: viewModel.storageProvider))) {
                        Text(category.sanitisedName)
                    }
                }
                    .onDelete(perform: viewModel.delete)
            }
        }
            .navigationTitle("Categories")
        #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
        #endif
        .sheet(isPresented: $showSheet) {
            AddCategoryView(viewModel: AddCategoryViewModel(storageProvider: viewModel.storageProvider))
        }
            .toolbar {
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

        self.fetchResultsController = storageProvider.getCategoryNSFetchedResultsController()

        super.init()

        fetchResultsController.delegate = self
        try! fetchResultsController.performFetch()
        categories = fetchResultsController.fetchedObjects ?? []
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        categories = fetchResultsController.fetchedObjects ?? []
    }

    func delete(_ offsets: IndexSet) {
        for offset in offsets {
            let item = categories[offset]
            storageProvider.delete(item)
        }
    }
}
