//
//  NetworkMonitor.swift
//  MyAdidas
//
//  Created by Michael Borgmann on 15.10.20.
//

import Network

class NetworkMonitor {
    
    static public let shared = NetworkMonitor()
    
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")
    
    var isConnected: Bool {
        monitor.currentPath.status == .satisfied ? true : false
    }
    
    func start() {
        monitor.start(queue: queue)
    }
    
    func stop() {
        monitor.cancel()
    }
    
}
