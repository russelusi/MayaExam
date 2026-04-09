//
//  BottomSheetViewController.swift
//  MayaExam
//
//  Created by John Russel Usi on 4/9/26.
//

import SnapKit
import UIKit

final class BottomSheetViewController: UIViewController {
    enum Style {
        case success
        case error
    }

    private let titleText: String
    private let messageText: String
    private let style: Style

    private let containerView = UIView()
    private let titleLabel = UILabel()
    private let messageLabel = UILabel()
    private let dismissButton = UIButton(type: .system)

    init(title: String, message: String, style: Style) {
        self.titleText = title
        self.messageText = message
        self.style = style
        super.init(nibName: nil, bundle: nil)

        modalPresentationStyle = .pageSheet
        if let sheet = sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.prefersGrabberVisible = true
        }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        configureUI()
    }

    private func configureUI() {
        containerView.backgroundColor = .secondarySystemBackground
        containerView.layer.cornerRadius = 16
        containerView.layer.cornerCurve = .continuous

        titleLabel.text = titleText
        titleLabel.font = .systemFont(ofSize: 20, weight: .bold)
        titleLabel.textAlignment = .center

        messageLabel.text = messageText
        messageLabel.font = .systemFont(ofSize: 16, weight: .regular)
        messageLabel.textAlignment = .center
        messageLabel.textColor = .secondaryLabel
        messageLabel.numberOfLines = 0

        dismissButton.setTitle("OK", for: .normal)
        dismissButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        dismissButton.addTarget(self, action: #selector(didTapDismiss), for: .touchUpInside)

        let indicator = UIView()
        indicator.backgroundColor = {
            switch style {
            case .success: return .systemGreen
            case .error: return .systemRed
            }
        }()
        indicator.layer.cornerRadius = 4

        view.addSubview(containerView)
        containerView.addSubview(indicator)
        containerView.addSubview(titleLabel)
        containerView.addSubview(messageLabel)
        containerView.addSubview(dismissButton)

        containerView.snp.makeConstraints { make in
            make.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(16)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(16)
        }

        indicator.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.centerX.equalToSuperview()
            make.width.equalTo(56)
            make.height.equalTo(8)
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(indicator.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
        }

        messageLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(16)
        }

        dismissButton.snp.makeConstraints { make in
            make.top.equalTo(messageLabel.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(44)
            make.bottom.equalToSuperview().inset(16)
        }
    }

    @objc private func didTapDismiss() {
        dismiss(animated: true)
    }
}

