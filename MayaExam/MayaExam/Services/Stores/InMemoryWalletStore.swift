//
//  InMemoryWalletStore.swift
//  MayaExam
//
//  Created by John Russel Usi on 4/9/26.
//

import Foundation

final class InMemoryWalletStore: WalletStoring {
    var balance: Decimal

    init(initialBalance: Decimal) {
        self.balance = initialBalance
    }
}

