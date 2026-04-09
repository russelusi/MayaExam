//
//  TransactionCaching.swift
//  MayaExam
//
//  Created by John Russel Usi on 4/9/26.
//

import Foundation

protocol TransactionCaching: AnyObject {
    func loadTransactions() -> [Transaction]
    func saveTransactions(_ transactions: [Transaction])
}

