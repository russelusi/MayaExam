//
//  LoginViewModel.swift
//  MayaExam
//
//  Created by John Russel Usi on 4/9/26.
//

import Combine
import Foundation

@MainActor
final class LoginViewModel {
    struct State: Equatable {
        var isLoading: Bool = false
        var errorMessage: String?
    }

    @Published private(set) var state = State()

    var onLoginSuccess: (() -> Void)?

    private let authService: AuthServicing
    private var cancellables = Set<AnyCancellable>()

    init(authService: AuthServicing) {
        self.authService = authService
    }

    func login(username: String, password: String) {
        let trimmedUsername = username.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedPassword = password.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedUsername.isEmpty, !trimmedPassword.isEmpty else {
            state.errorMessage = "Please enter username and password."
            return
        }

        state.isLoading = true
        state.errorMessage = nil

        authService.login(username: trimmedUsername, password: trimmedPassword)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self else { return }
                self.state.isLoading = false
                if case let .failure(error) = completion {
                    self.state.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] _ in
                self?.onLoginSuccess?()
            }
            .store(in: &cancellables)
    }

    func consumeErrorMessage() {
        state.errorMessage = nil
    }
}

