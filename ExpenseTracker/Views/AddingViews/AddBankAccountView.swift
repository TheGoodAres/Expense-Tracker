//
//  AddBankAccountView.swift
//  ExpenseTracker
//
//  Created by Robert-Dumitru Oprea on 04/12/2023.
//

import SwiftUI
import Combine

struct AddBankAccountView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var storageProvider: StorageProvider
    @State var bankAccountName = ""
    @State var initialBalance = ""
    @FocusState var initialBalanceIsActive: Bool
    @FocusState var accountNameIsActive: Bool
    @State var type: BankAccountType = .debit
    @State var showBankAccountAlreadyExists = false
    var body: some View {
        NavigationView{
            Form {
                Section("Add Bank Account") {
                    VStack(alignment: .leading) {
                        Text("Bank Account Name")
                            .font(.caption2)
                        TextField("Bank Account Name", text: $bankAccountName, prompt: Text("Required"))
                            .focused($accountNameIsActive)
                    }
                    VStack(alignment: .leading) {
                        Text("Initial Balance")
                            .font(.caption2)
                        #if os(iOS)
                        TextField("Initial Balance", text: $initialBalance)
                            .focused($initialBalanceIsActive)
                            .keyboardType(.decimalPad)
                            .onReceive(Just(initialBalance)) { newValue in
                                let filtered = newValue.filter { "0123456789.".contains($0) }
                                if filtered != newValue {
                                    self.initialBalance = filtered
                                }
                            }
                        #else
                        TextField("Initial Balance", text: $initialBalance)
                            .focused($initialBalanceIsActive)
                            .onReceive(Just(initialBalance)) { newValue in
                                let filtered = newValue.filter { "0123456789.".contains($0) }
                                if filtered != newValue {
                                    self.initialBalance = filtered
                                }
                            }
                        #endif
                    }
                    Picker("Type", selection: $type) {
                        ForEach(BankAccountType.allCases, id: \.rawValue) { accountType in
                            Text(accountType.rawValue).tag(accountType)
                            
                        }
                    }
                    Button("Submit") {
                        print("Submit pressed")
                        if storageProvider.checkUniqueBankAccount(accountName: bankAccountName) {
                            print("New account added: \(bankAccountName)")
                            storageProvider.addBankAccount(name: bankAccountName, initialBalance: Double(initialBalance) ?? 0, type: type.rawValue)
                            showBankAccountAlreadyExists = false
                            dismiss()
                        } else {
                            showBankAccountAlreadyExists = true
                        }
                    }
                }
                if showBankAccountAlreadyExists {
                    Text("A bank account with this name already exists, please try another!")
                        .foregroundStyle(Color.red)
                }
            }
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    
                    Button("Done") {
                        if initialBalanceIsActive {
                            initialBalanceIsActive.toggle()
                        } else if accountNameIsActive {
                            accountNameIsActive.toggle()
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
