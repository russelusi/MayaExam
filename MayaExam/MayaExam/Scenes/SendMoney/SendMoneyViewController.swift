//
//  SendMoneyViewController.swift
//  MayaExam
//
//  Created by John Russel Usi on 4/9/26.
//

import Combine
import SnapKit
import UIKit

final class SendMoneyViewController: UIViewController {
    private let viewModel: SendMoneyViewModel
    private var cancellables = Set<AnyCancellable>()

    private let amountField = UITextField()
    private let submitButton = UIButton(type: .system)
    private let activityIndicator = UIActivityIndicatorView(style: .medium)

    init(viewModel: SendMoneyViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        title = "Send Money"
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
        amountField.borderStyle = .roundedRect
        amountField.placeholder = "Amount (PHP)"
        amountField.keyboardType = .decimalPad

        submitButton.setTitle("Submit", for: .normal)
        submitButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        submitButton.addTarget(self, action: #selector(didTapSubmit), for: .touchUpInside)

        activityIndicator.hidesWhenStopped = true

        let stack = UIStackView(arrangedSubviews: [amountField, submitButton, activityIndicator])
        stack.axis = .vertical
        stack.spacing = 12

        view.addSubview(stack)
        stack.snp.makeConstraints { make in
            make.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(20)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(24)
        }

        submitButton.snp.makeConstraints { make in
            make.height.equalTo(44)
        }
    }

    private func bind() {
        viewModel.$state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                guard let self else { return }
                self.submitButton.isEnabled = !state.isSubmitting
                if state.isSubmitting {
                    self.activityIndicator.startAnimating()
                } else {
                    self.activityIndicator.stopAnimating()
                }

                if let success = state.successMessage {
                    self.presentBottomSheet(title: "Success", message: success, style: .success)
                    self.viewModel.consumeMessages()
                } else if let error = state.errorMessage {
                    self.presentBottomSheet(title: "Error", message: error, style: .error)
                    self.viewModel.consumeMessages()
                }
            }
            .store(in: &cancellables)
    }

    @objc private func didTapSubmit() {
        viewModel.submit(amountText: amountField.text ?? "")
    }

    private func presentBottomSheet(title: String, message: String, style: BottomSheetViewController.Style) {
        let sheet = BottomSheetViewController(title: title, message: message, style: style)
        present(sheet, animated: true)
    }
}

