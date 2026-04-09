//
//  MayaExamTests.swift
//  MayaExamTests
//
//  Created by John Russel Usi on 4/9/26.
//

import Combine
import Foundation
import Testing
@testable import MayaExam

struct MayaExamTests {

    @MainActor
    final class FlagBox {
        var value: Bool = false
    }

    final class MockAuthService: AuthServicing {
        enum Mode {
            case success
            case failure(Error)
        }

        var mode: Mode = .success
        private(set) var didLogout: Bool = false

        func login(username: String, password: String) -> AnyPublisher<UserSession, Error> {
            switch mode {
            case .success:
                return Just(UserSession(username: username, createdAt: Date()))
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            case let .failure(error):
                return Fail(error: error).eraseToAnyPublisher()
            }
        }

        func logout() {
            didLogout = true
        }
    }

    final class MockWalletStore: WalletStoring {
        var balance: Decimal

        init(balance: Decimal) {
            self.balance = balance
        }
    }

    final class MockTransactionService: TransactionServicing {
        var fetchResult: Result<[Transaction], Error> = .success([])
        var sendResult: Result<Void, Error> = .success(())

        private(set) var lastSendAmount: Decimal?
        private(set) var appendedTransactions: [(amount: Decimal, recipient: String, date: Date)] = []

        func fetchTransactions() -> AnyPublisher<[Transaction], Error> {
            switch fetchResult {
            case let .success(value):
                return Just(value).setFailureType(to: Error.self).eraseToAnyPublisher()
            case let .failure(error):
                return Fail(error: error).eraseToAnyPublisher()
            }
        }

        func sendMoney(amount: Decimal) -> AnyPublisher<Void, Error> {
            lastSendAmount = amount
            switch sendResult {
            case .success:
                return Just(()).setFailureType(to: Error.self).eraseToAnyPublisher()
            case let .failure(error):
                return Fail(error: error).eraseToAnyPublisher()
            }
        }

        func appendLocalTransaction(amount: Decimal, recipient: String, date: Date) {
            appendedTransactions.append((amount: amount, recipient: recipient, date: date))
        }
    }

    @Test func loginSuccessCallsOnLoginSuccess() async throws {
        let auth = MockAuthService()
        auth.mode = .success

        let viewModel = await LoginViewModel(authService: auth)

        let didNavigate = await FlagBox()
        await MainActor.run {
            viewModel.onLoginSuccess = { didNavigate.value = true }
            viewModel.login(username: "user", password: "pass")
        }

        try await Task.sleep(nanoseconds: 50_000_000)
        let value = await MainActor.run { didNavigate.value }
        #expect(value == true)
    }

    @Test func sendMoneyValidAmountDeductsBalanceOnSuccess() async throws {
        let wallet = MockWalletStore(balance: 1000)
        let tx = MockTransactionService()
        tx.sendResult = .success(())

        let viewModel = await SendMoneyViewModel(walletStore: wallet, transactionService: tx)
        await MainActor.run {
            viewModel.submit(amountText: "100")
        }

        try await Task.sleep(nanoseconds: 50_000_000)
        #expect(wallet.balance == 900)
        #expect(tx.lastSendAmount == 100)
        #expect(tx.appendedTransactions.count == 1)
    }

}
