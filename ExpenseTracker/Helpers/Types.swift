//
//  Types.swift
//  ExpenseTracker
//
//  Created by Robert-Dumitru Oprea on 02/12/2023.
//

import Foundation

enum BankAccountType: String, CaseIterable {
    case debit = "debit"
    case savings = "savings"
}

enum TransactionType: String, CaseIterable {
    case income = "income"
    case expense = "expense"
}
