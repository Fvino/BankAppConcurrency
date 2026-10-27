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
    
    @ObservationIgnored
    private var currentLoadID: UUID?
    
    init(service: any BankServiceProtocol) {
        self.service = service
    }
    
    func startLoading() {
        loadingTask?.cancel()
        
        let loadID = UUID()
        currentLoadID = loadID
        isLoading = true
        
        loadingTask = Task {
            
            defer {
                if currentLoadID == loadID {
                    isLoading = false
                    loadingTask = nil
                    currentLoadID = nil
                }
            }
            
            do {
                async let profileResult = service.fetchProfile()
                async let accountsResult = service.fetchAccounts()
                
                let (profile, accounts) = try await (
                    profileResult,
                    accountsResult
                )
                
                let transactions = try await loadTransactionsForAccount(accounts)
                
                try Task.checkCancellation()
                
                guard currentLoadID == loadID else { return }
                
                self.profile = profile
                self.accounts = accounts
                self.transactions = transactions
                
                print("Loaded \(loadID)")
                
            } catch is CancellationError {
                print("Loading canceled: \(loadID)")
                
            } catch {
                print("Loading failed: \(error)")
            }
        }
    }
    
    func cancelLoading() {
        print("Cancel requested")
        loadingTask?.cancel()
    }
    
    func loadTransactionsForAccount(_ accounts: [BankAccount]) async throws -> [BankTransaction] {
        
        let service = service
        
        return try await withThrowingTaskGroup(
            of: [BankTransaction].self
        ) {
            group in
            
            for account in accounts {
                
                group.addTask {
                    do {
                        return try await service.fetchTransations(accountID: account.id)
                        
                    } catch is CancellationError {
                        throw CancellationError()
                        
                    } catch {
                        print("Failed to load transactions for \(account.name)")
                        return []
                    }
                }
                
            }
            
            var allTransactions: [BankTransaction] = []
            
            for try await transactions in group {
                allTransactions.append(contentsOf: transactions)
            }
            return allTransactions
        }
    }
}
