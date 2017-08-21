//
//  NetworkManager.swift
//  NetworkManager
//
//  Created by Akhilesh on 21/08/17.
//  Copyright © 2017 Akhilesh Gandotra. All rights reserved.
//

import Foundation


enum HTTPMethod: String {
    case put = "PUT"
    case post = "POST"
    case get = "GET"
    case delete = "DELETE"
}

enum ResponseType {
    case success([String: Any])
    case failure(Error)
}

class NetworkManager {
    
    
    //MARK: Variables
    private var showAlert = true
    private var headers = [String : String]()
    private var baseUrl = ""
    private var extendedUrl = ""
    private var fullUrlString = ""
    private var httpMethod: HTTPMethod = .get
    private var requestTimeOutInterval:TimeInterval = 40
    private var parametres: [String: Any]?

    
    typealias networkHandler = (ResponseType) -> ()
    private var completionCallBack: networkHandler?
    
    init() {
    }
    
    // MARK: For additional functionality
    @discardableResult
    func addHeaders(headers: [String: String]) -> NetworkManager {
        self.headers.appendDictionary(other: headers)
        return self
    }
    
    @discardableResult
    func configure(showAlert:Bool, requestTimeOutInterval: TimeInterval) -> NetworkManager {
        self.showAlert = showAlert
        self.requestTimeOutInterval = requestTimeOutInterval
        return self
    }
    
    convenience init(httpMethod:HTTPMethod, extendedUrl: String, params: [String: Any]?) {
        self.init()
        self.httpMethod = httpMethod
        self.extendedUrl = extendedUrl
        guard let encodedUrl = extendedUrl.addingPercentEncoding(withAllowedCharacters:NSCharacterSet.urlQueryAllowed) else {
            return
        }
        self.fullUrlString = baseUrl + encodedUrl
        self.parametres = params
        
    }
    
    convenience init(httpMethod:HTTPMethod, fullUrlString: String, params: [String: Any]?) {
        self.init()
        self.httpMethod = httpMethod
        guard let encodedUrl = fullUrlString.addingPercentEncoding(withAllowedCharacters:NSCharacterSet.urlQueryAllowed) else {
            return
        }
        self.fullUrlString = encodedUrl
        self.parametres = params
    }
    
    // MARK: Completion handler
    func completion(callback: @escaping networkHandler) {
        completionCallBack = callback
        startRequest()
    }
    
    
     // MARK: Creating Request
    private func startRequest() {
        guard let url = URL(string: fullUrlString),
        var request = URLRequest(url: url) as? URLRequest else {
            return
        }

        request.httpMethod = httpMethod.rawValue
        request.timeoutInterval = self.requestTimeOutInterval
        let session = URLSession(configuration: .default)
    
        switch httpMethod {
        case .post, .put:
            do {
                if let params = parametres {
                   request.httpBody = try JSONSerialization.data(withJSONObject: params, options: [])
                }
                
            } catch {
                
            }
            
        default:
            print("other methods")
        }
        
        //for adding headers
        for (key, value) in headers {
             request.addValue(value, forHTTPHeaderField: key)
        }
        
        startDataTask(session: session, request: request)

    }
    
    // MARK: for completing task
    private func startDataTask(session: URLSession, request: URLRequest) {
        let task = session.dataTask(with: request) { (data, response, error) in
            guard error == nil else {
                self.completionCallBack?(ResponseType.failure(error!))
                return
            }
            var jsonObject: [String: Any]?
            guard let data = data else {
                return
            }
            do {
                if let  json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    jsonObject = json
                }
            } catch {
                let error = self.errorWithDescription(description: "Serialization error", code: 20)
                self.completionCallBack?(ResponseType.failure(error))
                return
            }
            guard let response = response as? HTTPURLResponse else {
                return
            }
            self.handleCases(statusCode: response.statusCode, json: jsonObject)
        }
        task.resume()
    }
    
    // MARK: Handling cases
    func handleCases(statusCode: Int, json: [String: Any]?) {
        guard let json = json else {
            return
        }
        
        switch statusCode {
        case 200...300:
            self.completionCallBack?(ResponseType.success(json))
        case 401:
            print("unauthorised")
        default:
            handleErrorCases(json: json, statusCode: statusCode)
        }
    }
    
    
    private func handleErrorCases(json: [String: Any], statusCode: Int) {
        guard let message = json["message"] as? String else {
            let error = errorWithDescription(description: "Error", code: statusCode)
            self.completionCallBack?(ResponseType.failure(error))
            return
        }
        let error = errorWithDescription(description: message, code: statusCode)
        self.completionCallBack?(ResponseType.failure(error))
    }
    
    private func errorWithDescription(description: String, code: Int) -> Error {
        let userInfo = [NSLocalizedDescriptionKey: description]
        return NSError(domain: "app", code: code, userInfo: userInfo) as Error
    }

}

extension Dictionary {
    
    //Append Dictionary
    mutating func appendDictionary(other: Dictionary) {
        for (key, value) in other {
            self.updateValue(value, forKey:key)
        }
    }
    
    static func += <K, V> ( left: inout [K:V], right: [K:V]) {
        for (k, v) in right {
            left.updateValue(v, forKey: k)
        }
    }
    
}

extension DispatchQueue {
    class func performAction(after seconds: TimeInterval, callBack: @escaping ((Bool) -> (Void)) ) {
        DispatchQueue.delay(delay: seconds) {
            callBack(true)
        }
    }
    private class func delay(delay: TimeInterval, closure: @escaping () -> Void) {
        let when = DispatchTime.now() + delay
        DispatchQueue.main.asyncAfter(deadline: when, execute: closure)
    }

}
