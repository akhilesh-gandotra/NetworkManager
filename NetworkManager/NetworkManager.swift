//
//  NetworkManager.swift
//  NetworkManager
//
//  Created by Akhilesh on 21/08/17.
//  Copyright © 2017 Akhilesh Gandotra. All rights reserved.
//

import Foundation
import UIKit //for activity indicator on status bar
import SystemConfiguration

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

struct MultipartFile {
    var name: String
    var mimeType: String
    var data: Data
    var fileName: String
}

class NetworkManager {
    
    
    //MARK: Variables
    private var showAlert = true
    private var headers = [String : String]()
    private var baseUrl = ""
    private var extendedUrl = ""
    private var fullUrlString = ""
    private var httpMethod: HTTPMethod = .get
    private var requestTimeOutInterval:TimeInterval = 70
    private var parametres: [String: Any]?
    private var files = [MultipartFile]()
    
    
    typealias networkHandler = (ResponseType) -> ()
    private var completionCallBack: networkHandler?
    
    init() {
       headers = ["authorization": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjExZTc5MzI5YjZkZGEyNTBiZjMyMTU4ODA5NjFlOTVmIiwiZGF0ZSI6MTUwNDcxOTMwMjkwMSwiaWF0IjoxNTA0NzE5MzAyfQ.tBEEdpbzB371f0EBOWr7wONWRKjgjTCMldZW0NzQC9Q"]
    }
    
    
    // MARK: For additional functionality
    @discardableResult
    public func addHeaders(headers: [String: String]) -> NetworkManager {
        self.headers.appendDictionary(other: headers)
        return self
    }
    
    @discardableResult
    public func configure(showAlert:Bool, requestTimeOutInterval: TimeInterval) -> NetworkManager {
        self.showAlert = showAlert
        self.requestTimeOutInterval = requestTimeOutInterval
        return self
    }
    
     convenience init(httpMethod:HTTPMethod, fullUrlString: String, params: [String: Any]?, files: [MultipartFile]) {
        self.init()
        self.httpMethod = httpMethod
        guard let encodedUrl = fullUrlString.addingPercentEncoding(withAllowedCharacters:NSCharacterSet.urlQueryAllowed) else {
            return
        }
        self.files = files
        self.fullUrlString = encodedUrl
        self.parametres = params
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
    public func completion(callback: @escaping networkHandler) {
        completionCallBack = callback
        if files.isEmpty {
            startRequest()
            return
        }
        startMultipartRequest()
    }
    
    
    // MARK: Creating Request
    private func startRequest() {
        guard let url = URL(string: fullUrlString) else {
                return
        }
        var request = URLRequest(url: url)
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
    
    private func startMultipartRequest() {
        
        let boundary = "----WebKitFormBoundarycC4YiaUFwM44F6rT"
        var body = Data()
        if let params = self.parametres {
            for (key, value) in params {
                body.append(("--\(boundary)\r\n").data(using: String.Encoding.utf8, allowLossyConversion: true)!)
                body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: String.Encoding.utf8, allowLossyConversion: true)!)
                body.append("\(value)\r\n".data(using: String.Encoding.utf8, allowLossyConversion: true)!)
            }
        }
        for file in self.files {
            body.append(("--\(boundary)\r\n").data(using: String.Encoding.utf8, allowLossyConversion: true)!)
            body.append("Content-Disposition: form-data; name=\"\(file.name)\"; filename=\"\(file.fileName)\"\r\n" .data(using: String.Encoding.utf8, allowLossyConversion: true)!)
            body.append("Content-Type: \(file.mimeType)\r\n\r\n".data(using: String.Encoding.utf8, allowLossyConversion: true)!)
            body.append(file.data)
            body.append("\r\n".data(using: String.Encoding.utf8, allowLossyConversion: true)!)
        }
        
        body.append("--\(boundary)--".data(using: String.Encoding.utf8, allowLossyConversion: true)!)
        guard let url = URL(string: fullUrlString) else {
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod.rawValue
        request.httpBody = body
        request.timeoutInterval = self.requestTimeOutInterval
        request.addValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        //for adding headers
        for (key, value) in headers {
            request.addValue(value, forHTTPHeaderField: key)
        }
        let session = URLSession(configuration: .default)
        
        startDataTask(session: session, request: request)
        
    }
    
    // MARK: for completing task
    private func startDataTask(session: URLSession, request: URLRequest) {

        if showAlert {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        }
        let task = session.dataTask(with: request) { (data, response, error) in
            DispatchQueue.main.async {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                guard error == nil else {
                    self.completionCallBack?(ResponseType.failure(error!))
                    return
                }
                var jsonObject: [String: Any]?
                guard let data = data else {
                    return
                }
                do {
                    let  json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                    jsonObject = json
                    
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
        }
        
        task.resume()
    }
    
    
    // MARK: Handling cases
    private func handleCases(statusCode: Int, json: [String: Any]?) {
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
