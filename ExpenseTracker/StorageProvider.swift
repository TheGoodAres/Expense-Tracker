//
//  StorageProvider.swift
//  ExpenseTracker
//
//  Created by Robert-Dumitru Oprea on 25/11/2023.
//

import Foundation
import CoreData

class StorageProvider: ObservableObject {
    let persistentContainer: NSPersistentCloudKitContainer

    init() {

        persistentContainer = NSPersistentCloudKitContainer(name: "ExpenseTracker")

        persistentContainer.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        persistentContainer.persistentStoreDescriptions.first?.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
        NotificationCenter.default.addObserver(forName: .NSPersistentStoreRemoteChange, object: persistentContainer.persistentStoreCoordinator, queue: .main, using: remoteStoreChanged)


        persistentContainer.loadPersistentStores(completionHandler: { description, error in
            if let error = error {
                fatalError("CoreData failed to load with error: \(error)")
            }
        })

    }

    func addTransaction(bankAccount: BankAccount, type: TransactionType, category: Category?, amount: Double, date: Date, merchantName: String, note: String, categoryOn: Bool) {
        let transaction = Transaction(context: persistentContainer.viewContext)
        transaction.bankAccount = bankAccount
        transaction.type = type
        if categoryOn {
            transaction.category = category
        }
        transaction.amount = amount
        transaction.date = date
        transaction.merchant = merchantName
        if type == .expense {
            bankAccount.currentBalance -= amount
        } else {
            bankAccount.currentBalance += amount
        }
        save()

    }
    func addBankAccount(name: String, initialBalance: Double, type: String) {
        let bankAccount = BankAccount(context: persistentContainer.viewContext)
        bankAccount.name = name
        bankAccount.initialBalance = initialBalance
        bankAccount.currentBalance = initialBalance
        bankAccount.typeRaw = type
        save()
    }
    func addCategory(name: String, parentCategory: Category?) {
        let category = Category(context: persistentContainer.viewContext)
        category.name = name
        category.parentCategory = parentCategory
        save()
    }

    func getAllBankAccount() -> [BankAccount] {
        let fetchRequest: NSFetchRequest<BankAccount> = BankAccount.fetchRequest()
        do {
            return try persistentContainer.viewContext.fetch(fetchRequest)
        } catch {
            print("There was an error: \(error)")
            return []
        }
    }

    func mockBankAccount() {
        let category1 = Category(context: persistentContainer.viewContext)
        let category2 = Category(context: persistentContainer.viewContext)

        category1.name = "Test1"
        category2.name = "Test2"

        category1.addToChildCategory(category2)
        category2.parentCategory = category1

        let bankAccount = BankAccount(context: persistentContainer.viewContext)
        let bankAccount1 = BankAccount(context: persistentContainer.viewContext)
        bankAccount.name = "First"
        bankAccount1.name = "Second"

        bankAccount.initialBalance = 1000
        bankAccount1.initialBalance = 500

        bankAccount.typeRaw = "Debit"
        bankAccount.typeRaw = "Savings"

        let transaction1 = Transaction(context: persistentContainer.viewContext)
        let transaction2 = Transaction(context: persistentContainer.viewContext)
        transaction1.amount = 100
        transaction1.category = category1
        transaction1.date = Calendar.current.date(byAdding: .day, value: -1, to: .now)
        transaction2.date = Date.now
        transaction2.amount = 200
        transaction2.category = category2
        transaction1.typeRaw = "income"
        transaction2.typeRaw = "expense"
        transaction1.bankAccount = bankAccount
        transaction2.bankAccount = bankAccount1
        save()
    }

    func checkUniqueBankAccount(accountName: String) -> Bool {
        let fetchRequest: NSFetchRequest<BankAccount> = BankAccount.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name == %@", accountName)
        do {
            let results = try persistentContainer.viewContext.fetch(fetchRequest)
            if results.isEmpty {
                return true
            } else {
                return false
            }
        } catch {
            print("There was an error: \(error)")
            return false
        }
    }
    func checkUniqueCategory(name: String) -> Bool {
        let fetchRequest: NSFetchRequest<Category> = Category.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name == %@", name)
        do {
            let results = try persistentContainer.viewContext.fetch(fetchRequest)
            if results.isEmpty {
                return true
            } else {
                return false
            }
        } catch {
            print("There was an error: \(error)")
            return false
        }
    }
    func save() {
        if persistentContainer.viewContext.hasChanges {
            do {

                try persistentContainer.viewContext.save()
                print("Success")
            } catch {
                persistentContainer.viewContext.rollback()
                print("There was an error: \(error)")
            }
        } else {
            print("Had no changes")
        }
    }

    func delete(_ object: NSManagedObject) {
        objectWillChange.send()
        if let item = object as? Transaction {
            if item.type == .expense {
                item.bankAccount?.currentBalance += item.amount
            } else {
                item.bankAccount?.currentBalance -= item.amount
            }
        }
        persistentContainer.viewContext.delete(object)
        save()
    }

    private func delete(_ fetchRequest: NSFetchRequest<NSFetchRequestResult>) {
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        batchDeleteRequest.resultType = .resultTypeObjectIDs

        if let delete = try? persistentContainer.viewContext.execute(batchDeleteRequest) as? NSBatchDeleteResult {
            let changes = [NSDeletedObjectsKey: delete.result as? [NSManagedObjectID] ?? []]
            NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [persistentContainer.viewContext])
        }
    }
    func deleteAll() {
        let request1: NSFetchRequest<NSFetchRequestResult> = BankAccount.fetchRequest()
        delete(request1)
        let request2: NSFetchRequest<NSFetchRequestResult> = Transaction.fetchRequest()
        delete(request2)
        let request3: NSFetchRequest<NSFetchRequestResult> = Category.fetchRequest()
        delete(request3)
        save()
    }

    func remoteStoreChanged(_ notification: Notification) {
        objectWillChange.send()
    }

    func getCategoryNSFetchedResultsController() -> NSFetchedResultsController<Category> {
        let categoriesFetchRequest = Category.fetchRequest()
        categoriesFetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Category.name, ascending: false)]

        return NSFetchedResultsController(fetchRequest: categoriesFetchRequest, managedObjectContext: persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
    }
    func getTransactionNSFetchedResultsController() -> NSFetchedResultsController<Transaction> {
        let fetchRequest: NSFetchRequest<Transaction> = Transaction.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Transaction.date, ascending: false)]
        return NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
    }

    func getBankAccountNSFetchedResultsController() -> NSFetchedResultsController<BankAccount> {
        let request: NSFetchRequest<BankAccount> = BankAccount.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \BankAccount.name, ascending: false)]

        return NSFetchedResultsController(fetchRequest: request, managedObjectContext: persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
    }
    
    func updateBalance(bankAccount: BankAccount) {
        let fetchRequest : NSFetchRequest<Transaction> = Transaction.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "bankAccount == %@", bankAccount)
        bankAccount.currentBalance = bankAccount.initialBalance
        do {
            let transactions = try persistentContainer.viewContext.fetch(fetchRequest)
            for transaction in transactions {
                if transaction.type == .expense {
                    bankAccount.currentBalance -= transaction.amount
                } else {
                    bankAccount.currentBalance += transaction.amount
                }
            }
        } catch {
            print("Error: \(error)")
        }
    }
}
