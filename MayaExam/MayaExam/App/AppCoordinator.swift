//
//  AppCoordinator.swift
//  MayaExam
//
//  Created by John Russel Usi on 4/9/26.
//

import UIKit

final class AppCoordinator {
    private let window: UIWindow
    private let dependencies: AppDependencies
    private let navigationController: UINavigationController

    init(window: UIWindow, dependencies: AppDependencies = AppDependencies()) {
        self.window = window
        self.dependencies = dependencies
        self.navigationController = UINavigationController()
    }

    func start() {
        navigationController.navigationBar.prefersLargeTitles = true
        window.rootViewController = navigationController
        window.makeKeyAndVisible()

        routeToInitial()
    }

    private func routeToInitial() {
        showLogin()
    }

    private func showLogin() {
        let viewModel = LoginViewModel(authService: dependencies.authService)
        viewModel.onLoginSuccess = { [weak self] in
            self?.showDashboard()
        }

        let viewController = LoginViewController(viewModel: viewModel)
        navigationController.setViewControllers([viewController], animated: false)
    }

    private func showDashboard() {
        let viewModel = DashboardViewModel(walletStore: dependencies.walletStore, authService: dependencies.authService)
        viewModel.onSendMoney = { [weak self] in
            self?.showSendMoney()
        }
        viewModel.onViewTransactions = { [weak self] in
            self?.showTransactions()
        }
        viewModel.onLogout = { [weak self] in
            self?.showLogin()
        }

        let viewController = DashboardViewController(viewModel: viewModel)
        navigationController.setViewControllers([viewController], animated: true)
    }

    private func showSendMoney() {
        let viewModel = SendMoneyViewModel(walletStore: dependencies.walletStore, transactionService: dependencies.transactionService)
        let viewController = SendMoneyViewController(viewModel: viewModel)
        navigationController.pushViewController(viewController, animated: true)
    }

    private func showTransactions() {
        let viewModel = TransactionsViewModel(transactionService: dependencies.transactionService)
        let viewController = TransactionsViewController(viewModel: viewModel)
        navigationController.pushViewController(viewController, animated: true)
    }
}

