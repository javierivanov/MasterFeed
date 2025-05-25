//
//  ErrorHandling.swift
//  MasterFeed
//
//  Created by Javier Fuentes on 10-05-21.
//

import Foundation


enum FeedError: Error {
    case timeoutResponse
    case noNetwork
    case unhandledError(msg: String)
    case version
}

extension FeedError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .version:
            return NSLocalizedString("This version is not supported. Please Update The App In The AppStore.", comment: "Version error")
        case .noNetwork:
            // MODIFIED HERE
            return NSLocalizedString("No Internet Connection", comment: "No network error_message")
        case .unhandledError(let msg):
            return NSLocalizedString("\(msg)", comment: "") // This typically should also have a unique key if localizing
        case .timeoutResponse:
            // MODIFIED HERE
            return NSLocalizedString("The request timed out. Please try again.", comment: "Timeout error message")
        }
    }
}

enum UserError: Error {
    case errorCode(code: Int, description: String)
    case malformedDict
    case unhandledError(error: Error)
}

enum KeychainError: Error {
    case noPassword
    case unexpectedPasswordData
    case unhandledError(status: OSStatus)
}
