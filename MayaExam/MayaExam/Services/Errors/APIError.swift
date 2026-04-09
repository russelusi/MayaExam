//
//  APIError.swift
//  MayaExam
//
//  Created by John Russel Usi on 4/9/26.
//

import Foundation

enum APIError: LocalizedError, Equatable {
    case httpStatus(Int)
    case decoding

    var errorDescription: String? {
        switch self {
        case let .httpStatus(code):
            return "Request failed (\(code))."
        case .decoding:
            return "Failed to decode server response."
        }
    }
}

