//
//  TransactionExtensions.swift
//  ExpenseTracker
//
//  Created by Robert-Dumitru Oprea on 02/12/2023.
//

import Foundation
import CoreData

extension Transaction {
    var type: TransactionType {
        get {
            return TransactionType(rawValue: typeRaw ?? "") ?? .expense
        }
        set {
            typeRaw = newValue.rawValue
        }
    }
}
