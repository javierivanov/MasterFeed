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
