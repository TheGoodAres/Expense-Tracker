//
//  Category+CoreDataProperties.swift
//  ExpenseTracker
//
//  Created by Robert-Dumitru Oprea on 25/11/2023.
//
//

import Foundation
import CoreData


extension Category {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Category> {
        return NSFetchRequest<Category>(entityName: "Category")
    }

    @NSManaged public var name: String?
    @NSManaged public var transaction: NSSet?
    @NSManaged public var parentCategory: Category?
    @NSManaged public var childCategory: NSSet?

}

// MARK: Generated accessors for transaction
extension Category {

    @objc(addTransactionObject:)
    @NSManaged public func addToTransaction(_ value: Transaction)

    @objc(removeTransactionObject:)
    @NSManaged public func removeFromTransaction(_ value: Transaction)

    @objc(addTransaction:)
    @NSManaged public func addToTransaction(_ values: NSSet)

    @objc(removeTransaction:)
    @NSManaged public func removeFromTransaction(_ values: NSSet)

}

// MARK: Generated accessors for childCategory
extension Category {

    @objc(addChildCategoryObject:)
    @NSManaged public func addToChildCategory(_ value: Category)

    @objc(removeChildCategoryObject:)
    @NSManaged public func removeFromChildCategory(_ value: Category)

    @objc(addChildCategory:)
    @NSManaged public func addToChildCategory(_ values: NSSet)

    @objc(removeChildCategory:)
    @NSManaged public func removeFromChildCategory(_ values: NSSet)

}

extension Category : Identifiable {

}
