//
//  AuthServicing.swift
//  MayaExam
//
//  Created by John Russel Usi on 4/9/26.
//

import Combine
import Foundation

protocol AuthServicing {
    func login(username: String, password: String) -> AnyPublisher<UserSession, Error>
    func logout()
}

