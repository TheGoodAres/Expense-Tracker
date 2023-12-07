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
    var sanitisedAmount: Double {
        Double(amount)
    }
    var sanitisedMerchant: String {
        merchant ?? "No Merchant"
    }
    var sanitisedNote: String {
        note ?? ""
    }
    var sanitisedDate: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        return dateFormatter.string(from: date ?? Calendar.current.date(byAdding: .year, value: -10, to: .now)!)
        
    }
    var safeDate: Date {
        date ?? Date()
    }
    var bankAccountName: String {
        bankAccount?.sanitisedName ?? "Not associated with a bank account"
    }
}
