//
//  ExtensionsCoreData.swift
//  ExpenseTracker
//
//  Created by Robert-Dumitru Oprea on 02/12/2023.
//

import Foundation


extension BankAccount {

    var type: bankAccountType {
        get {
            return bankAccountType(rawValue: typeRaw ?? "") ?? .debit
        }

        set {
            typeRaw = newValue.rawValue
        }
    }

    var sanitisedName: String {
        name ?? "No name"
    }

}
