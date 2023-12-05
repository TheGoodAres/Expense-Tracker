//
//  AddBankAccountView.swift
//  ExpenseTracker
//
//  Created by Robert-Dumitru Oprea on 04/12/2023.
//

import SwiftUI
import Combine

struct AddBankAccountView: View {
    @EnvironmentObject var storageProvider: StorageProvider
    @State var bankAccountName = ""
    @State var initialBalance = ""
    @FocusState var initialBalanceKeyboardIsActive: Bool
    var body: some View {
        NavigationView{
            Form {
                Section("Add Bank Account") {
                    VStack(alignment: .leading) {
                        Text("Bank Account Name")
                            .font(.caption2)
                        TextField("Bank Account Name", text: $bankAccountName, prompt: Text("Required"))
                    }
                    VStack(alignment: .leading) {
                        Text("Initial Balance")
                            .font(.caption2)
                        TextField("Initial Balance", text: $initialBalance)
                            .keyboardType(.decimalPad)
                            .focused($initialBalanceKeyboardIsActive)
                            .toolbar {
                                ToolbarItemGroup(placement: .keyboard) {
                                    Spacer()
                                    
                                    Button("Done") {
                                        initialBalanceKeyboardIsActive = false
                                    }
                                }
                            }
                            .onReceive(Just(initialBalance)) { newValue in
                                let filtered = newValue.filter { "0123456789.".contains($0) }
                                if filtered != newValue {
                                    self.initialBalance = filtered
                                }
                            }
                    }
                }
            }
        }
    }
}

#Preview {
    AddBankAccountView().environmentObject(StorageProvider())
}
