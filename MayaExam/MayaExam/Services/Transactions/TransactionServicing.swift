//
//  TransactionServicing.swift
//  MayaExam
//
//  Created by John Russel Usi on 4/9/26.
//

import Combine
import Foundation

protocol TransactionServicing {
    func fetchTransactions() -> AnyPublisher<[Transaction], Error>
    func sendMoney(amount: Decimal) -> AnyPublisher<Void, Error>
    func appendLocalTransaction(amount: Decimal, recipient: String, date: Date)
}

