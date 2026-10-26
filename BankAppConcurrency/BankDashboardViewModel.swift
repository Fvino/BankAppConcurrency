//
//  BankDashboardViewModel.swift
//  BankAppConcurrency
//
//  Created by Valeriy Fomin on 22/10/26.
//

import Foundation
import Observation

@Observable
@MainActor
final class BankDashboardViewModel {
    
    private let service: any BankServiceProtocol
    
    private(set) var profile: BankProfile?
    private(set) var accounts: [BankAccount] = []
    private(set) var transactions: [BankTransaction] = []
    private(set) var isLoading = false
    
    @ObservationIgnored
    private var loadingTask: Task<Void, Never>?
    
    init(service: any BankServiceProtocol) {
        self.service = service
    }
    
    func startLoading() {
        guard !isLoading else {
            print("Already loading")
            return
        }
        
        print("Start loading")
        isLoading = true
        
        loadingTask = Task {
            
            
            defer {
                print("Task finished")
                isLoading = false
                loadingTask = nil
            }
            
            do {
                async let profileResult = service.fetchProfile()
                async let accountsResult = service.fetchAccounts()
                async let transacionsResult = service.fetchTransactions()
                
                let (profile, accounts, transactions) = try await (
                    profileResult,
                    accountsResult,
                    transacionsResult
                )
                
                try Task.checkCancellation()
                
                self.profile = profile
                self.accounts = accounts
                self.transactions = transactions
                
                print("Success")
                
            } catch is CancellationError {
                print("Loading canceled")
                
            } catch {
                print("Loading failed: \(error)")
            }
        }
    }
    
    func cancelLoading() {
        print("Cancel requested")
        loadingTask?.cancel()
    }
}
