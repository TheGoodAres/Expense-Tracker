//
//  EditBankAccountView.swift
//  ExpenseTracker
//
//  Created by Robert-Dumitru Oprea on 20/12/2023.
//

import SwiftUI
import Combine

struct EditBankAccountView: View {
    @Binding var bankAccountName: String
    @Binding var initialBalance: String
    @Binding var bankAccountType: BankAccountType
    @FocusState var bankAccountNameFocus: Bool
    @FocusState var initialBalanceFocus: Bool

    var body: some View {
        NavigationStack {
            Form {
                VStack(alignment: .leading) {
                    Text("Bank Account Name")
                    TextField("Bank Account Name", text: $bankAccountName)
                        .focused($bankAccountNameFocus)
                }
                VStack(alignment: .leading) {
                    Text("Initial Balance")
                    #if os(iOS)
                        TextField("Initial Balance", text: $initialBalance)
                            .focused($initialBalanceFocus)
                            .keyboardType(.decimalPad)
                    #else
                        TextField("Initial Balance", text: $initialBalance)
                            .focused($initialBalanceFocus)
                    #endif
                            
                }
                VStack(alignment: .leading) {
                    Picker("Type", selection: $bankAccountType) {
                        ForEach(BankAccountType.allCases, id: \.rawValue) { accountType in
                            Text(accountType.rawValue.capitalized).tag(accountType)
                        }
                    }
                }

            }
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    
                    Button("Done") {
                        if bankAccountNameFocus {
                            bankAccountNameFocus.toggle()
                        }
                        if initialBalanceFocus {
                            initialBalanceFocus.toggle()
                        }
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


