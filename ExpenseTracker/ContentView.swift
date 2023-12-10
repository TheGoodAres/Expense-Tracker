//
//  ContentView.swift
//  ExpenseTracker
//
//  Created by Robert-Dumitru Oprea on 17/11/2023.
//

import SwiftUI
import CoreData
import LocalAuthentication

struct ContentView: View {
    @EnvironmentObject var storageProvider: StorageProvider
    @State private var selection = 0
    @State private var isShown = false
    @State private var isAuthenticated = false
    var body: some View {
        VStack {

            ZStack(alignment: .bottom) {
                TabView(selection: $selection) {
                    ViewTransactions(viewModel: ViewTransactionsModel(storageProvider: storageProvider))

                        .tabItem {
                        Label("Transactions", systemImage: "arrow.left.arrow.right.circle")
                    }
                        .tag(0)

                    BankAccountsView(viewModel: BankAccountsViewModel(storageProvider: storageProvider), selectedTab: $selection) .tabItem {
                        Label("BankAccounts", systemImage: "house.circle")
                    }
                        .tag(1)
                    Spacer()
                        .tabItem {
                        EmptyView()
                    }
                        .tag(2)
                    DashboardView(viewModel: DashboardViewModel(storageProvider: storageProvider))
                        .tabItem {
                        Label("Dashboard", systemImage: "chart.line.uptrend.xyaxis.circle.fill")
                    }
                        .tag(3)
                    SettingsView()
                        .tabItem {
                        Label("Settings", systemImage: "gear.circle")
                    }
                        .tag(4)
                }
                Button {
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
            .blur(radius: (isAuthenticated ? 0 : 12))
            .allowsHitTesting(isAuthenticated)
            .onAppear(perform: authenticate)
    }

    func authenticate() {
        let context = LAContext()
        var error: NSError?

        // check whether biometric authentication is possible
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            // it's possible, so go ahead and use it
            let reason = "We need to unlock your data."

            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in
                // authentication has now completed
                if success {
                    isAuthenticated = true
                } else {
                    // there was a problem
                }
            }
        } else {
            // no biometrics
        }
    }
}

