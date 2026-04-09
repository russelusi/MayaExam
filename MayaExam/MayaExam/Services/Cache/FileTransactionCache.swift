//
//  FileTransactionCache.swift
//  MayaExam
//
//  Created by John Russel Usi on 4/9/26.
//

import Foundation

final class FileTransactionCache: TransactionCaching {
    private let fileURL: URL
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init(fileName: String = "transactions.json") {
        let directory = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let bundleID = Bundle.main.bundleIdentifier ?? "MayaExam"
        let appDirectory = directory.appendingPathComponent(bundleID, isDirectory: true)
        try? FileManager.default.createDirectory(at: appDirectory, withIntermediateDirectories: true)
        self.fileURL = appDirectory.appendingPathComponent(fileName)

        encoder.outputFormatting = [.prettyPrinted]
        decoder.dateDecodingStrategy = .iso8601
        encoder.dateEncodingStrategy = .iso8601
    }

    func loadTransactions() -> [Transaction] {
        guard let data = try? Data(contentsOf: fileURL) else { return [] }
        return (try? decoder.decode([Transaction].self, from: data)) ?? []
    }

    func saveTransactions(_ transactions: [Transaction]) {
        guard let data = try? encoder.encode(transactions) else { return }
        try? data.write(to: fileURL, options: [.atomic])
    }
}

