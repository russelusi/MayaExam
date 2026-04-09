//
//  DashboardViewModel.swift
//  MayaExam
//
//  Created by John Russel Usi on 4/9/26.
//

import Combine
import Foundation

@MainActor
final class DashboardViewModel {
    struct State: Equatable {
        var isBalanceHidden: Bool = false
        var balanceText: String = ""
    }

    @Published private(set) var state = State()

    var onSendMoney: (() -> Void)?
    var onViewTransactions: (() -> Void)?
    var onLogout: (() -> Void)?

    private let walletStore: WalletStoring
    private let authService: AuthServicing

    init(walletStore: WalletStoring, authService: AuthServicing) {
        self.walletStore = walletStore
        self.authService = authService
        refresh()
    }

    func refresh() {
        state.balanceText = formattedBalance(hidden: state.isBalanceHidden)
    }

    func toggleBalanceVisibility() {
        state.isBalanceHidden.toggle()
        refresh()
    }

    func didTapSendMoney() {
        onSendMoney?()
    }

    func didTapViewTransactions() {
        onViewTransactions?()
    }

    func didTapLogout() {
        authService.logout()
        onLogout?()
    }

    private func formattedBalance(hidden: Bool) -> String {
        if hidden { return "****" }
        return "PHP \(NSDecimalNumber(decimal: walletStore.balance))"
    }
}

