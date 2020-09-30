//
//  Networking.swift
//  MyAdidas
//
//  Created by Michael Borgmann on 30.09.20.
//

import Foundation

enum Task {
    case requestWithParameters(_ parameters: [URLQueryItem])
    case request(_ parameters: [URLQueryItem]? = nil)
}

enum HTTPMethod {
    case GET
    case POST
    case PUT
    case DELETE
}

protocol APIProtocol {
    
    /// The target's base `URL`.
    var baseURL: URL { get }
    
     /// The path to be appended to `baseURL` to form the full `URL`.
    var path: String { get }
    
    /// The HTTP method used in the request.
    var method: HTTPMethod { get }
    
    /// The type of HTTP task to be performed.
    var task: Task { get }
}

struct Networking<API: APIProtocol> {
    
    private func createSafeURL(api: API) -> URL? {
        
        var urlComponents = URLComponents(string: api.baseURL.absoluteString)
        
        urlComponents?.path += api.path
        
        switch api.task {
        case .requestWithParameters(let parameters):
            urlComponents?.queryItems = parameters
        default:
            break
        }
        
        return urlComponents?.url
    }
    
    private func decode<Model: Codable>(_ type: Model.Type, from data: Data) -> Model? {
        do {
            let decoded = try JSONDecoder().decode(Model.self, from: data)
            return decoded
        } catch {
            print(error)
            return nil
        }
    }
    
    func request<Model: Codable>(api: API, type: Model.Type, completion: ((_ response: Model) -> Void)?) {
        guard let url = createSafeURL(api: api) else {
            fatalError("URL not configured")
        }
        
        let task = URLSession(configuration: .default).dataTask(with: url) { data, response, error in
            
            if let _ = error {
                return
            }
            
            guard
                let data = data
            else {
                return
            }
            
            guard let decoded = self.decode(Model.self, from: data) else {
                return
            }
            
            completion?(decoded)
            
        }
        
        task.resume()
    }
    
}
