//
//  SendMoneyViewModel.swift
//  MayaExam
//
//  Created by John Russel Usi on 4/9/26.
//

import Combine
import Foundation

@MainActor
final class SendMoneyViewModel {
    struct State: Equatable {
        var isSubmitting: Bool = false
        var errorMessage: String?
        var successMessage: String?
    }

    @Published private(set) var state = State()

    private let walletStore: WalletStoring
    private let transactionService: TransactionServicing
    private var cancellables = Set<AnyCancellable>()

    init(walletStore: WalletStoring, transactionService: TransactionServicing) {
        self.walletStore = walletStore
        self.transactionService = transactionService
    }

    func submit(amountText: String) {
        state.errorMessage = nil
        state.successMessage = nil

        let sanitized = amountText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let amount = Decimal(string: sanitized), amount > 0 else {
            state.errorMessage = "Amount must be greater than zero."
            return
        }

        let balance = walletStore.balance
        guard amount < balance else {
            state.errorMessage = "Amount must be less than your wallet balance."
            return
        }

        state.isSubmitting = true

        transactionService.sendMoney(amount: amount)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self else { return }
                self.state.isSubmitting = false
                if case let .failure(error) = completion {
                    self.state.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] in
                guard let self else { return }
                self.walletStore.balance -= amount
                self.transactionService.appendLocalTransaction(amount: amount, recipient: "Recipient", date: Date())
                self.state.successMessage = "Sent PHP \(NSDecimalNumber(decimal: amount))."
            }
            .store(in: &cancellables)
    }

    func consumeMessages() {
        state.errorMessage = nil
        state.successMessage = nil
    }
}

