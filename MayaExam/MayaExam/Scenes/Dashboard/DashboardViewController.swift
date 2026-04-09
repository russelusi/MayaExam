//
//  DashboardViewController.swift
//  MayaExam
//
//  Created by John Russel Usi on 4/9/26.
//

import Combine
import SnapKit
import UIKit

final class DashboardViewController: UIViewController {
    private let viewModel: DashboardViewModel
    private var cancellables = Set<AnyCancellable>()

    private let balanceTitleLabel = UILabel()
    private let balanceValueLabel = UILabel()
    private let balanceToggleButton = UIButton(type: .system)

    private let sendMoneyButton = UIButton(type: .system)
    private let viewTransactionsButton = UIButton(type: .system)
    private let logoutButton = UIButton(type: .system)

    init(viewModel: DashboardViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        title = "Dashboard"
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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.refresh()
    }

    private func configureUI() {
        balanceTitleLabel.text = "Wallet Balance"
        balanceTitleLabel.font = .systemFont(ofSize: 15, weight: .medium)
        balanceTitleLabel.textColor = .secondaryLabel

        balanceValueLabel.font = .monospacedDigitSystemFont(ofSize: 28, weight: .bold)
        balanceValueLabel.textColor = .label

        balanceToggleButton.setTitle("Show/Hide", for: .normal)
        balanceToggleButton.addTarget(self, action: #selector(didTapToggleBalance), for: .touchUpInside)

        sendMoneyButton.setTitle("Send Money", for: .normal)
        sendMoneyButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        sendMoneyButton.addTarget(self, action: #selector(didTapSendMoney), for: .touchUpInside)

        viewTransactionsButton.setTitle("View Transactions", for: .normal)
        viewTransactionsButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        viewTransactionsButton.addTarget(self, action: #selector(didTapViewTransactions), for: .touchUpInside)

        logoutButton.setTitle("Logout", for: .normal)
        logoutButton.setTitleColor(.systemRed, for: .normal)
        logoutButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        logoutButton.addTarget(self, action: #selector(didTapLogout), for: .touchUpInside)

        let balanceRow = UIStackView(arrangedSubviews: [balanceValueLabel, balanceToggleButton])
        balanceRow.axis = .horizontal
        balanceRow.alignment = .center
        balanceRow.distribution = .equalSpacing

        let stack = UIStackView(arrangedSubviews: [
            balanceTitleLabel,
            balanceRow,
            sendMoneyButton,
            viewTransactionsButton,
            logoutButton
        ])
        stack.axis = .vertical
        stack.spacing = 16

        view.addSubview(stack)
        stack.snp.makeConstraints { make in
            make.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(20)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(24)
        }

        [sendMoneyButton, viewTransactionsButton, logoutButton].forEach { button in
            button.snp.makeConstraints { make in
                make.height.equalTo(44)
            }
        }
    }

    private func bind() {
        viewModel.$state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.balanceValueLabel.text = state.balanceText
            }
            .store(in: &cancellables)
    }

    @objc private func didTapToggleBalance() {
        viewModel.toggleBalanceVisibility()
    }

    @objc private func didTapSendMoney() {
        viewModel.didTapSendMoney()
    }

    @objc private func didTapViewTransactions() {
        viewModel.didTapViewTransactions()
    }

    @objc private func didTapLogout() {
        viewModel.didTapLogout()
    }
}

