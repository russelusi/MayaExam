# MayaExam – Send Money (UIKit + MVVM)

Native iOS take-home project: a simple **send money** app built with **UIKit**, **MVVM**, **SnapKit**, and **Combine**, with mocked networking via **Moya**.

## Screens
- **Login**
  - Username + password authentication (mocked API)
  - Success → Dashboard, failure → alert
- **Dashboard**
  - Wallet balance (starts at **1000 PHP**) with show/hide toggle (`****`)
  - Send Money / View Transactions / Logout
- **Send Money**
  - Amount-only submission (recipient out of scope)
  - Validation: \(amount > 0\) and \(amount < balance\)
  - Success/error shown using a bottom sheet
  - Balance deducted on successful submit
- **Transaction History**
  - Fetches mocked transactions via GET
  - Displays amount, date, recipient

## Architecture
- **Coordinator**: `MayaExam/MayaExam/App/AppCoordinator.swift`
- **Dependency container**: `MayaExam/MayaExam/App/AppDependencies.swift`
- **Scenes**: `MayaExam/MayaExam/Scenes/*` (UIViewController + ViewModel per screen)
- **Services**: `MayaExam/MayaExam/Services/*` (Auth + Transactions via Moya)
- **Caching (bonus)**: `MayaExam/MayaExam/Services/Cache/*` (local disk cache for transactions)

## Mock API
Uses `jsonplaceholder.typicode.com` via `Moya` targets:
- `POST /posts` for login and send money
- `GET /posts` for transaction list (mapped to app `Transaction` models)

## Requirements
- Xcode with iOS Simulator
- CocoaPods

## Install & run
From the repo root:

```bash
cd MayaExam
pod install
open MayaExam.xcworkspace
```

Run the `MayaExam` scheme.

## Tests
Unit tests cover key view model behaviors (login success callback, send money balance deduction).

To run from CLI:

```bash
xcodebuild -workspace "MayaExam/MayaExam.xcworkspace" -scheme "MayaExam" -destination "platform=iOS Simulator,name=iPhone 17" test
```

