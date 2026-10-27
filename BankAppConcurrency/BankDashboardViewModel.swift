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
                async let transacionsResult = service.fetchTransactions()
                
                let (profile, accounts, transactions) = try await (
                    profileResult,
                    accountsResult,
                    transacionsResult
                )
                
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
}
