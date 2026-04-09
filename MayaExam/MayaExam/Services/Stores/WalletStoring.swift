//
//  WalletStoring.swift
//  MayaExam
//
//  Created by John Russel Usi on 4/9/26.
//

import Foundation

protocol WalletStoring: AnyObject {
    var balance: Decimal { get set }
}

