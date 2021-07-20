//
//  Reachability.swift
//  MasterFeed
//
//  Created by Javier Fuentes on 07-07-21.
//

import Foundation
import Network

class Reachability: ObservableObject {
    let monitor = NWPathMonitor()
    let queue = DispatchQueue(label: "network-monitor")
    @Published var isConnected: Bool = true
    
    init() {
        monitor.pathUpdateHandler = { path in
            switch path.status {
            case .satisfied:
                DispatchQueue.main.async { [weak self] in self?.isConnected = true }
            case .unsatisfied:
                DispatchQueue.main.async { [weak self] in self?.isConnected = false }
            case .requiresConnection:
                DispatchQueue.main.async { [weak self] in self?.isConnected = true }
            default:
                DispatchQueue.main.async { [weak self] in self?.isConnected = true }
            }
        }
        monitor.start(queue: queue)
    }
}
