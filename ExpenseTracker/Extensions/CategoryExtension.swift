//
//  CategoryExtension.swift
//  ExpenseTracker
//
//  Created by Robert-Dumitru Oprea on 05/12/2023.
//

import Foundation
extension Category {
    var sanitisedName: String {
        name ?? "No Category"
    }
}
