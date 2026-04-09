//
//  LoginViewController.swift
//  MayaExam
//
//  Created by John Russel Usi on 4/9/26.
//

import Combine
import SnapKit
import UIKit

final class LoginViewController: UIViewController {
    private let viewModel: LoginViewModel
    private var cancellables = Set<AnyCancellable>()

    private let usernameField = UITextField()
    private let passwordField = UITextField()
    private let loginButton = UIButton(type: .system)
    private let activityIndicator = UIActivityIndicatorView(style: .medium)

    init(viewModel: LoginViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        title = "Login"
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        configureUI()
        bind()
    }

    private func configureUI() {
        usernameField.borderStyle = .roundedRect
        usernameField.placeholder = "Username"
        usernameField.autocapitalizationType = .none
        usernameField.textContentType = .username
        usernameField.returnKeyType = .next
        usernameField.delegate = self

        passwordField.borderStyle = .roundedRect
        passwordField.placeholder = "Password"
        passwordField.isSecureTextEntry = true
        passwordField.textContentType = .password
        passwordField.returnKeyType = .done
        passwordField.delegate = self

        loginButton.setTitle("Login", for: .normal)
        loginButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        loginButton.addTarget(self, action: #selector(didTapLogin), for: .touchUpInside)

        activityIndicator.hidesWhenStopped = true

        let stack = UIStackView(arrangedSubviews: [usernameField, passwordField, loginButton, activityIndicator])
        stack.axis = .vertical
        stack.spacing = 12

        view.addSubview(stack)
        stack.snp.makeConstraints { make in
            make.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(20)
            make.centerY.equalToSuperview()
        }

        loginButton.snp.makeConstraints { make in
            make.height.equalTo(44)
        }
    }

    private func bind() {
        viewModel.$state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                guard let self else { return }
                self.loginButton.isEnabled = !state.isLoading
                if state.isLoading {
                    self.activityIndicator.startAnimating()
                } else {
                    self.activityIndicator.stopAnimating()
                }

                if let message = state.errorMessage {
                    self.presentError(message: message)
                    self.viewModel.consumeErrorMessage()
                }
            }
            .store(in: &cancellables)
    }

    @objc private func didTapLogin() {
        viewModel.login(username: usernameField.text ?? "", password: passwordField.text ?? "")
    }

    private func presentError(message: String) {
        let alert = UIAlertController(title: "Login Failed", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField === usernameField {
            passwordField.becomeFirstResponder()
            return true
        }
        if textField === passwordField {
            passwordField.resignFirstResponder()
            didTapLogin()
            return true
        }
        return false
    }
}

