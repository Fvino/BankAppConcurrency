//
//  BankModels.swift
//  BankAppConcurrency
//
//  Created by Valeriy Fomin on 22/10/26.
//

import Foundation

struct BankProfile: Sendable {
    let name: String
}

struct BankAccount: Identifiable, Sendable {
    let id: UUID
    let name: String
    let balance: Decimal
}

struct BankTransaction: Identifiable, Sendable {
    let id: UUID
    let title: String
    let amount: Decimal
}
