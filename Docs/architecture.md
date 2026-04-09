# Design documentation

## High-level structure
- **Coordinator**: owns navigation and composes view controllers.
- **Scene**: `UIViewController` + `ViewModel` (MVVM).
- **Services**: `AuthServicing`, `TransactionServicing` abstractions for testability.
- **Stores**: in-memory session + wallet balance.
- **Cache (bonus)**: local disk cache for transactions.

## Class diagram (simplified)
```mermaid
classDiagram
  class AppCoordinator
  class AppDependencies
  class AuthServicing
  class AuthService
  class TransactionServicing
  class TransactionService
  class WalletStoring
  class InMemoryWalletStore
  class SessionStoring
  class InMemorySessionStore
  class TransactionCaching
  class FileTransactionCache

  AppCoordinator --> AppDependencies
  AppDependencies --> AuthServicing
  AppDependencies --> TransactionServicing
  AppDependencies --> WalletStoring
  AppDependencies --> SessionStoring
  AuthService ..|> AuthServicing
  TransactionService ..|> TransactionServicing
  InMemoryWalletStore ..|> WalletStoring
  InMemorySessionStore ..|> SessionStoring
  FileTransactionCache ..|> TransactionCaching
  TransactionService --> TransactionCaching
```

## Sequence: login
```mermaid
sequenceDiagram
  participant User
  participant LoginVC
  participant LoginVM
  participant AuthService
  participant AppCoordinator

  User->>LoginVC: tapLogin
  LoginVC->>LoginVM: login(username,password)
  LoginVM->>AuthService: login(request)
  AuthService-->>LoginVM: publisher(successOrError)
  LoginVM-->>LoginVC: stateUpdate(isLoading/error)
  LoginVM-->>AppCoordinator: onLoginSuccess()
  AppCoordinator-->>User: showDashboard
```

## Sequence: send money
```mermaid
sequenceDiagram
  participant User
  participant SendVC
  participant SendVM
  participant TxService
  participant WalletStore

  User->>SendVC: tapSubmit(amount)
  SendVC->>SendVM: submit(amountText)
  SendVM->>SendVM: validate(amount>0 && amount<balance)
  SendVM->>TxService: sendMoney(amount)
  TxService-->>SendVM: publisher(successOrError)
  SendVM->>WalletStore: deductBalance(onSuccess)
  SendVM-->>SendVC: stateUpdate(successOrError)
  SendVC-->>User: bottomSheet(success/error)
```

