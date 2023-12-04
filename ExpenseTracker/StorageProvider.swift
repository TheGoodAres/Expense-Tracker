//
//  StorageProvider.swift
//  ExpenseTracker
//
//  Created by Robert-Dumitru Oprea on 25/11/2023.
//

import Foundation
import CoreData

class StorageProvider: ObservableObject{
    let persistentContainer: NSPersistentContainer
    
    init() {
        
        persistentContainer = NSPersistentContainer(name:"ExpenseTracker")
        
        persistentContainer.loadPersistentStores(completionHandler: { description, error in
            if let error = error {
                fatalError("CoreData failed to load with error: \(error)")
            }
        })
    }
}

extension StorageProvider {
    func addBankAccount(name: String, initialBalance: Double) {
        let bankAccount = BankAccount(context: persistentContainer.viewContext)
        bankAccount.name = name
        bankAccount.initialBalance = initialBalance
        do {
            try persistentContainer.viewContext.save()
        } catch {
            persistentContainer.viewContext.rollback()
            print("There was an error: \(error)")
        }
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
        category1.childCategory?.adding(category2)
        category2.parentCategory = category1
        
        let bankAccount = BankAccount(context: persistentContainer.viewContext
        )
        let bankAccount1 = BankAccount(context: persistentContainer.viewContext)
        bankAccount.name = "First"
        bankAccount1.name = "Second"
        
        bankAccount.initialBalance = 1000
        bankAccount1.initialBalance = 500
        
        bankAccount.type = "Debit"
        bankAccount.type = "Savings"
        
        let transaction1 = Transaction(context: persistentContainer.viewContext)
        let transaction2 = Transaction(context: persistentContainer.viewContext)
        transaction1.amount = 100
        transaction1.category = category1
        transaction2.amount = 200
        transaction2.category = category2
        transaction1.bankAccount = bankAccount
        transaction2.bankAccount = bankAccount1
        do {
            try persistentContainer.viewContext.save()
        } catch {
            persistentContainer.viewContext.rollback()
            print("there was an error: \(error)")
        }
    }
}
