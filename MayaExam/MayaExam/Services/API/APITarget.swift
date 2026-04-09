//
//  APITarget.swift
//  MayaExam
//
//  Created by John Russel Usi on 4/9/26.
//

import Foundation
import Alamofire
import Moya

enum APITarget {
    case login(username: String, password: String)
    case listTransactions
    case sendMoney(amount: Decimal)
}

extension APITarget: TargetType {
    var baseURL: URL { URL(string: "https://jsonplaceholder.typicode.com")! }

    var path: String {
        switch self {
        case .login, .sendMoney:
            return "/posts"
        case .listTransactions:
            return "/posts"
        }
    }

    var method: Moya.Method {
        switch self {
        case .login, .sendMoney:
            return .post
        case .listTransactions:
            return .get
        }
    }

    var task: Task {
        switch self {
        case let .login(username, password):
            return .requestParameters(
                parameters: ["username": username, "password": password],
                encoding: JSONEncoding.default
            )
        case let .sendMoney(amount):
            return .requestParameters(
                parameters: ["amount": NSDecimalNumber(decimal: amount)],
                encoding: JSONEncoding.default
            )
        case .listTransactions:
            return .requestPlain
        }
    }

    var headers: [String: String]? {
        ["Content-Type": "application/json"]
    }

    var sampleData: Data { Data() }
}

