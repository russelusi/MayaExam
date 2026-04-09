//
//  AuthService.swift
//  MayaExam
//
//  Created by John Russel Usi on 4/9/26.
//

import Combine
import Foundation
import Moya

final class AuthService: AuthServicing {
    private let provider: MoyaProvider<APITarget>
    private let sessionStore: SessionStoring

    init(provider: MoyaProvider<APITarget>, sessionStore: SessionStoring) {
        self.provider = provider
        self.sessionStore = sessionStore
    }

    func login(username: String, password: String) -> AnyPublisher<UserSession, Error> {
        provider.requestPublisher(.login(username: username, password: password))
            .tryMap { response -> UserSession in
                guard (200..<300).contains(response.statusCode) else {
                    throw APIError.httpStatus(response.statusCode)
                }
                let session = UserSession(username: username, createdAt: Date())
                self.sessionStore.session = session
                return session
            }
            .eraseToAnyPublisher()
    }

    func logout() {
        sessionStore.session = nil
    }
}

