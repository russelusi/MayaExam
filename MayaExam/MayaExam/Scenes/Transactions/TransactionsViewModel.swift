//
//  TransactionsViewModel.swift
//  MayaExam
//
//  Created by John Russel Usi on 4/9/26.
//

import Combine
import Foundation

@MainActor
final class TransactionsViewModel {
    struct State: Equatable {
        var isLoading: Bool = false
        var transactions: [Transaction] = []
        var errorMessage: String?
    }

    @Published private(set) var state = State()

    private let transactionService: TransactionServicing
    private var cancellables = Set<AnyCancellable>()

    init(transactionService: TransactionServicing) {
        self.transactionService = transactionService
    }

    func load() {
        state.isLoading = true
        state.errorMessage = nil

        transactionService.fetchTransactions()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self else { return }
                self.state.isLoading = false
                if case let .failure(error) = completion {
                    self.state.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] transactions in
                self?.state.transactions = transactions
            }
            .store(in: &cancellables)
    }
}

