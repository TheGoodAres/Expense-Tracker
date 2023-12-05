//
//  ContentView.swift
//  ExpenseTracker
//
//  Created by Robert-Dumitru Oprea on 17/11/2023.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @EnvironmentObject var storageProvider: StorageProvider
    @State private var selection = 0
    @State private var isShown = false
    var body: some View {
        ZStack(alignment: .bottom){
            TabView(selection: $selection){
                ViewTransactions(viewModel: ViewTransactionsModel(storageProvider: storageProvider))
                    .padding()
                    .tabItem {
                        Label("Transactions", systemImage: "arrow.left.arrow.right.circle")
                    }
                    .tag(0)
                
                BankAccountsView(viewModel: BankAccountsViewModel(storageProvider: storageProvider))
                    .padding()
                    .tabItem {
                        Label("BankAccounts", systemImage: "house.circle")
                    }
                    .tag(1)
                Spacer()
                    .tabItem {
                        EmptyView()
                    }
                    .tag(2)
                DashboardView()
                    .padding()
                    .tabItem {
                        Label("Dashboard", systemImage: "chart.line.uptrend.xyaxis.circle.fill")
                    }
                    .tag(3)
                SettingsView()
                    .padding()
                    .tabItem {
                        Label("Settings", systemImage: "gear.circle")
                    }
                    .tag(4)
            }
            Button{
                isShown = true
            } label: {
                Image(systemName: "plus.circle")
                    .resizable()
                    .scaledToFit()
            }
            .frame(width: 60, height: 60)
            .clipShape(Circle())
        }
        .ignoresSafeArea(.keyboard)
        .onChange(of: selection) { oldValue, newValue in
            if newValue == 2 {
                self.selection = oldValue
            }
        }
        .sheet(isPresented: $isShown) {
            AddTransactionView(viewModel: AddTransctionViewModel(storageProvider: storageProvider))
        }
    }
}

