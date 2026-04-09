//
//  TransactionsViewController.swift
//  MayaExam
//
//  Created by John Russel Usi on 4/9/26.
//

import Combine
import SnapKit
import UIKit

final class TransactionsViewController: UIViewController {
    private let viewModel: TransactionsViewModel
    private var cancellables = Set<AnyCancellable>()

    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private let activityIndicator = UIActivityIndicatorView(style: .medium)

    private var transactions: [Transaction] = []

    init(viewModel: TransactionsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        title = "Transactions"
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
        viewModel.load()
    }

    private func configureUI() {
        tableView.dataSource = self
        tableView.register(TransactionCell.self, forCellReuseIdentifier: TransactionCell.reuseIdentifier)

        activityIndicator.hidesWhenStopped = true

        view.addSubview(tableView)
        view.addSubview(activityIndicator)

        tableView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }

        activityIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }

    private func bind() {
        viewModel.$state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                guard let self else { return }
                if state.isLoading {
                    self.activityIndicator.startAnimating()
                } else {
                    self.activityIndicator.stopAnimating()
                }

                self.transactions = state.transactions
                self.tableView.reloadData()

                if let message = state.errorMessage {
                    self.presentError(message: message)
                }
            }
            .store(in: &cancellables)
    }

    private func presentError(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

extension TransactionsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        transactions.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TransactionCell.reuseIdentifier, for: indexPath) as? TransactionCell else {
            return UITableViewCell()
        }
        cell.configure(with: transactions[indexPath.row])
        return cell
    }
}

final class TransactionCell: UITableViewCell {
    static let reuseIdentifier = "TransactionCell"

    private let amountLabel = UILabel()
    private let recipientLabel = UILabel()
    private let dateLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none

        amountLabel.font = .monospacedDigitSystemFont(ofSize: 17, weight: .semibold)
        recipientLabel.font = .systemFont(ofSize: 15, weight: .regular)
        recipientLabel.textColor = .secondaryLabel
        dateLabel.font = .systemFont(ofSize: 13, weight: .regular)
        dateLabel.textColor = .tertiaryLabel

        let stack = UIStackView(arrangedSubviews: [amountLabel, recipientLabel, dateLabel])
        stack.axis = .vertical
        stack.spacing = 4

        contentView.addSubview(stack)
        stack.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(12)
        }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with transaction: Transaction) {
        amountLabel.text = "PHP \(NSDecimalNumber(decimal: transaction.amount))"
        recipientLabel.text = "To: \(transaction.recipient)"
        dateLabel.text = Self.dateFormatter.string(from: transaction.date)
    }

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
}

