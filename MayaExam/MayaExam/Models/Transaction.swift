//
//  Transaction.swift
//  MayaExam
//
//  Created by John Russel Usi on 4/9/26.
//

import Foundation

struct Transaction: Equatable, Codable, Identifiable {
    let id: String
    let amount: Decimal
    let recipient: String
    let date: Date
}

