//
//  NetworkMonitor.swift
//  MyAdidas
//
//  Created by Michael Borgmann on 15.10.20.
//

import Network

protocol NetworkMonitorDelegate: class {
    func onConnect()
    func onDisconnect()
}

class NetworkMonitor {
    
    static public let shared = NetworkMonitor()
    
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")
    
    weak var delegate: NetworkMonitorDelegate?
    
    private init() {
        monitor.start(queue: queue)
    }
    
    var isConnected: Bool {
        monitor.currentPath.status == .satisfied ? true : false
    }
    
    func start() {
        monitor.pathUpdateHandler = { path in
            if path.status == .satisfied {
                self.delegate?.onConnect()
            } else {
                self.delegate?.onDisconnect()
            }
        }
    }
    
    func stop() {
        monitor.cancel()
    }
    
}
