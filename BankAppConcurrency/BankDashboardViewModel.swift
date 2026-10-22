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
    
    init(service: any BankServiceProtocol) {
        self.service = service
    }
    
    func loadData() async {
        guard !isLoading else { return }
        
        isLoading = true
        
        defer { isLoading = false }
        
        do {
            profile = try await service.fetchProfile()
            accounts = try await service.fetchAccounts()
            transactions = try await service.fetchTransactions()
            
            print("All data loaded")
            
        } catch {
           print("Loading failed: \(error)")
        }
    }
}
