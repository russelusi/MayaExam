//
//  AppDependencies.swift
//  MayaExam
//
//  Created by John Russel Usi on 4/9/26.
//

import Foundation
import Moya

final class AppDependencies {
    let sessionStore: SessionStoring
    let walletStore: WalletStoring

    let authService: AuthServicing
    let transactionService: TransactionServicing

    init() {
        let provider = MoyaProvider<APITarget>()

        let sessionStore = InMemorySessionStore()
        let walletStore = InMemoryWalletStore(initialBalance: 1000)
        let transactionCache = FileTransactionCache()

        self.sessionStore = sessionStore
        self.walletStore = walletStore

        self.authService = AuthService(provider: provider, sessionStore: sessionStore)
        self.transactionService = TransactionService(provider: provider, cache: transactionCache)
    }
}

