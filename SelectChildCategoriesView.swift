//
//  SelectChildCategories.swift
//  ExpenseTracker
//
//  Created by Robert-Dumitru Oprea on 18/12/2023.
//

import SwiftUI
import CoreData

struct SelectChildCategoriesView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var selectedCategories: [Category]
    @ObservedObject var viewModel: SelectChildCategoriesViewModel
    var body: some View {
        NavigationStack {
            Form {
                List {
                    ForEach(viewModel.categories) { category in
                        Button {
                            if (!selectedCategories.contains(category)) {
                                selectedCategories.append(category)
                            }
                        } label: {
                            HStack {
                                Text(category.sanitisedName)
                                Spacer()
                                Image(systemName: "checkmark.circle")
                                    .opacity(viewModel.category.childCategory?.contains(category) ?? false ? 1 : 0.1)
                            }
                        }
                    }
                }
            }
        }
    }
}

class SelectChildCategoriesViewModel: NSObject, ObservableObject, NSFetchedResultsControllerDelegate {
    let storageProvider: StorageProvider
    let category: Category
    @Published var categories = [Category]()

    let fetchResultsController: NSFetchedResultsController<Category>
    init(storageProvider: StorageProvider, category: Category) {
        self.storageProvider = storageProvider
        self.category = category

        fetchResultsController = storageProvider.getCategoryNSFetchedResultsController()
        fetchResultsController.fetchRequest.predicate = NSPredicate(format: "name != %@", category.sanitisedName)
        super.init()

        fetchResultsController.delegate = self
        try! fetchResultsController.performFetch()
        categories = fetchResultsController.fetchedObjects ?? []
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        categories = fetchResultsController.fetchedObjects ?? []
    }
}
