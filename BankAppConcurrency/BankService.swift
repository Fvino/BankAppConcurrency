//
//  BankService.swift
//  BankAppConcurrency
//
//  Created by Valeriy Fomin on 22/10/26.
//

import Foundation

protocol BankServiceProtocol: Sendable {
    func fetchProfile() async throws -> BankProfile
    func fetchAccounts() async throws -> [BankAccount]
    func fetchTransactions() async throws -> [BankTransaction]
}

struct MockBankService: BankServiceProtocol {
    
    func fetchProfile() async throws -> BankProfile {
        try await Task.sleep(for: .seconds(1))
        
        return BankProfile(name: "Alex")
    }
    
    func fetchAccounts() async throws -> [BankAccount] {
        try await Task.sleep(for: .seconds(2))
        
        return [
            BankAccount(
                id: UUID(),
                name: "Current account",
                balance: 8250.80
            ),
            BankAccount(
                id: UUID(),
                name: "Savings",
                balance: 4200.00
            )
        ]
    }
    
    func fetchTransactions() async throws -> [BankTransaction] {
        try await Task.sleep(for: .seconds(3))
        
        return [
            BankTransaction(
                id: UUID(),
                title: "Mercadona",
                amount: -42.69
            ),
            
            BankTransaction(
                id: UUID(),
                title: "Salary",
                amount: 2850.00
            )
        ]
    }
}
