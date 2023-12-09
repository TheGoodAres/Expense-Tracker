//
//  AddCategory.swift
//  ExpenseTracker
//
//  Created by Robert-Dumitru Oprea on 08/12/2023.
//

import SwiftUI
import CoreData
struct AddCategoryView: View {
    @Environment(\.dismiss) var dismiss
    @State var viewModel: AddCategoryViewModel
    @State var categoryName = ""
    @State var hasParentCategory = true
    @State var parentCategory : Category?
    var body: some View {
        NavigationStack {
            Form {
                Section("Add category") {
                    
                        HStack {
                            Text("Category Name:")
                            TextField("Category Name", text: $categoryName, prompt: Text("Required"))
                        }
                        VStack {
                            HStack {
                                Text("Has parent category:")
                                Spacer()
                                Button {
                                    hasParentCategory.toggle()
                                } label: {
                                    Text(hasParentCategory ? "yes" : "no")
                                }
                            }
                        }
                        VStack {
                            Picker("Parent Category", selection: $parentCategory) {
                                ForEach(viewModel.categories) {category in
                                    Text(category.sanitisedName).tag(category as Category?)
                                }
                            }
                            .disabled(!hasParentCategory)
                        }
                    Button{
                        if viewModel.storageProvider.checkUniqueCategory(name: categoryName) {
                            viewModel.storageProvider.addCategory(name: categoryName, parentCategory: parentCategory)
                            dismiss()
                        } else {
                            print("Not unique")
                        }
                    } label: {
                        Text("Submit")
                    }

                    
                }
            }
        }
        .onAppear {
            parentCategory = viewModel.categories.first
        }
    }
}

class AddCategoryViewModel: NSObject, ObservableObject, NSFetchedResultsControllerDelegate {
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

}
