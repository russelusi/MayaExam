//
//  TransactionService.swift
//  MayaExam
//
//  Created by John Russel Usi on 4/9/26.
//

import Combine
import Foundation
import Moya

final class TransactionService: TransactionServicing {
    private struct PlaceholderTransactionDTO: Decodable {
        let id: Int
        let userId: Int?
        let title: String?
        let body: String?
    }

    private let provider: MoyaProvider<APITarget>
    private let cache: TransactionCaching

    init(provider: MoyaProvider<APITarget>, cache: TransactionCaching) {
        self.provider = provider
        self.cache = cache
    }

    func fetchTransactions() -> AnyPublisher<[Transaction], Error> {
        let cached = cache.loadTransactions()
        return provider.requestPublisher(.listTransactions)
            .tryMap { response -> [Transaction] in
                guard (200..<300).contains(response.statusCode) else {
                    throw APIError.httpStatus(response.statusCode)
                }
                let dtos = try JSONDecoder().decode([PlaceholderTransactionDTO].self, from: response.data)
                let now = Date()
                let remote = dtos.prefix(20).enumerated().map { idx, dto in
                    Transaction(
                        id: "\(dto.id)",
                        amount: Decimal(50 + (dto.id % 10) * 10),
                        recipient: "Recipient \(dto.id)",
                        date: Calendar.current.date(byAdding: .day, value: -idx, to: now) ?? now
                    )
                }
                let merged = (cached + remote)
                    .reduce(into: [String: Transaction]()) { dict, tx in dict[tx.id] = tx }
                    .values
                    .sorted(by: { $0.date > $1.date })
                self.cache.saveTransactions(merged)
                return merged
            }
            .prepend(cached)
            .eraseToAnyPublisher()
    }

    func sendMoney(amount: Decimal) -> AnyPublisher<Void, Error> {
        provider.requestPublisher(.sendMoney(amount: amount))
            .tryMap { response -> Void in
                guard (200..<300).contains(response.statusCode) else {
                    throw APIError.httpStatus(response.statusCode)
                }
            }
            .eraseToAnyPublisher()
    }

    func appendLocalTransaction(amount: Decimal, recipient: String, date: Date) {
        var existing = cache.loadTransactions()
        existing.insert(Transaction(id: UUID().uuidString, amount: amount, recipient: recipient, date: date), at: 0)
        cache.saveTransactions(existing)
    }
}

