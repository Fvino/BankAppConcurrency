//
//  BankDashboardView.swift
//  BankAppConcurrency
//
//  Created by Valeriy Fomin on 22/10/26.
//

import SwiftUI

struct BankDashboardView: View {
    
    @State private var viewModel = BankDashboardViewModel(service: MockBankService())
    
    var body: some View {
        VStack(spacing: 20) {
            
            Text("Mini Banking App")
                .font(.title)
            
            if viewModel.isLoading {
                ProgressView("Loading...")
            }
            
            Text("Hello, \(viewModel.profile?.name ?? "Guest")")
            Text("Accounts: \(viewModel.accounts.count)")
            Text("Transactions: \(viewModel.transactions.count)")
            
            Button("Load Data / Reload Data") {
                viewModel.startLoading()
            }
           
            Button("Cancel") {
                viewModel.cancelLoading()
            }
            .disabled(!viewModel.isLoading)
        }
        .padding()
    }
}
