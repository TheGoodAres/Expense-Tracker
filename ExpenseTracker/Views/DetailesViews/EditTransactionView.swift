//
//  EditTransactionView.swift
//  ExpenseTracker
//
//  Created by Robert-Dumitru Oprea on 07/12/2023.
//

import SwiftUI
import Combine
struct EditTransactionView: View {
    @Binding var transaction: Transaction
    @Binding var transactionDate: Date
    @Binding var transactionMerchant: String
    @Binding var transactionNote: String
    @Binding var type: TransactionType
    @Binding var transactionAmount: String
    @Binding var bankAccount: BankAccount?
    @Binding var category: Category?
    @Binding var categoryOn: Bool
    @FocusState var amountIsActive: Bool
    @FocusState var merchantIsActive: Bool
    @FocusState var noteIsActive: Bool
    @Binding var bankAccounts: [BankAccount]
    @Binding var categories: [Category]
    var body: some View {
        
        VStack{
            Picker("Bank Account", selection: $bankAccount) {
                ForEach(bankAccounts) { bankAccount in
                    Text(bankAccount.sanitisedName).tag(bankAccount as BankAccount?)
                }
            }
            Picker("Type", selection: $type) {
                ForEach(TransactionType.allCases, id: \.rawValue) { type in
                    Text(type.rawValue.capitalized).tag(type)
                }
            }
            HStack {
                Text("Category enabled:")
                Spacer()
                Button {
                    categoryOn.toggle()
                } label: {
                    Text(categoryOn ? "On" : "Off")
                }
            }
            //.tag was require to make the pickers in this view work
            Picker("Category", selection: $category) {
                ForEach(categories) { category in
                    Text(category.name?.capitalized ?? "No Name").tag(category as Category?)
                }
            }
            .disabled(!categoryOn)
            VStack(alignment: .leading, spacing: 0) {
                Text("Amount")
            #if os(iOS)
                TextField("Amount", text: $transactionAmount)
                    .focused($amountIsActive)
                    .keyboardType(.decimalPad)
                #else
                TextField("Amount", text: $transactionAmount)
                    .focused($amountIsActive)
    
                #endif
                   
            }
            
            DatePicker("Date:", selection: $transactionDate, displayedComponents: [.date])
            VStack(alignment: .leading, spacing: 0) {
                Text("Merchant Name")
                    .font(.caption2)
                TextField("Merchant Name", text: $transactionMerchant, prompt: Text("Required"))
                    .focused($merchantIsActive)
            }
            
            VStack(alignment: .leading, spacing: 0) {
                Text("Note")
                ZStack {
                    TextEditor(text: $transactionNote)
                        .background {
                            Color.primary.opacity(0.1)
                        }
                        .focused($noteIsActive)
                    
                    Text(transactionNote).opacity(0).padding(.all, 8)
                }
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                
                Button("Done") {
                    if amountIsActive {
                        amountIsActive.toggle()
                    }
                    if merchantIsActive {
                        merchantIsActive.toggle()
                    }
                    if noteIsActive {
                        noteIsActive.toggle()
                    }
                }
            }
        }
        .onReceive(Just(transactionAmount)) { newValue in
            let filtered = newValue.filter { "0123456789.".contains($0) }
            if filtered != newValue {
                self.transactionAmount = filtered
            }
        }
        
    }
}


