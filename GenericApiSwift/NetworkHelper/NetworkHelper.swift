//
//  NetworkManager.swift
//  GenericApiSwift
//
//  Created by Apple on 03/06/23.
//

import UIKit

public enum HttpMethods: String {
    case GET = "GET"
    case POST = "POST"
}

public enum ApiEndPoints : String {
    case homepage = "uc"
}

public let kNetworkingErrorDomain = "kNetworkingErrorDomain"
fileprivate let kUnknownResponseError = NSLocalizedString("The server returned an unknown response.", comment: "The error message shown when the server produces something unintelligible.")


public enum Environment:String {
    case Development
    case Production
}


public class NetworkManager {
    /// This is private, you should use the shared singleton instead of creating your own instance.
    fileprivate init() { }

    /// Access the  API through the shared singleton.
    public static let shared: NetworkManager = NetworkManager()
    
    fileprivate let appEnvironment: Environment = .Development
    
    fileprivate var APIBaseUrl: URL {
        switch appEnvironment {
        case .Development:
            return URL(string: "https://drive.google.com/")!
        case .Production:
            return URL(string: "http://google.com/api/")!
        }
    }
    
    /// Manage API Response Block
    fileprivate typealias APIResponseBlock = (_ error: NSError?, _ dataResponse: Data?) -> Void

    
    // MARK: Networking Utilities
    
    /**
     Send a request
     
     - parameter request:    The request to send.
     - parameter completion: The completion block to call when done.
     */
    fileprivate func sendApi(request: URLRequest, completion: APIResponseBlock?) {
        ActivityIndicator.shared.showActivityIndicator()
        let APIStartTime = NSDate().timeIntervalSince1970
        
        URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
            
            ActivityIndicator.shared.hideActivityIndicator()
            
            let requestURLString = request.url?.absoluteString
            let requestTime = NSDate().timeIntervalSince1970 - APIStartTime
            
            print("API Request: \(requestURLString!) completed in: \(requestTime)")
            
            // Check for network error
            guard error == nil else {
                
                completion?(error as NSError?, nil)
                return;
            }
            
            // Check for valid response
            guard let httpResponse = response as? HTTPURLResponse else {
                
                let error = NSError(domain: kNetworkingErrorDomain, code: (response as? HTTPURLResponse)?.statusCode ?? -1, userInfo: [NSLocalizedDescriptionKey : kUnknownResponseError])
                
                completion?(error, nil)
                
                return;
            }
            
            // Check the network error code
            guard httpResponse.statusCode >= 200 && httpResponse.statusCode < 300 else {
                
                
                let error = NSError(domain: kNetworkingErrorDomain, code: httpResponse.statusCode, userInfo: [
                    NSLocalizedDescriptionKey : kUnknownResponseError
                ])
                
                completion?(error, data)
                return;
            }
            
            // It looks like we have a valid response in the 200 range.
            completion?(nil, data)
        }).resume()
    }
    
    
    /// Create a basic network error with a given description.
    ///
    /// - parameter description: The description for the error
    ///
    /// - returns: The created error
    fileprivate func networkError(description: String) -> NSError {
        return NSError(domain: kNetworkingErrorDomain, code: 0, userInfo: [NSLocalizedDescriptionKey : description])
    }
    
    
    fileprivate func createRequest(baseURL: URL, endPoint: ApiEndPoints, method: HttpMethods, params: [String : Any]?) -> URLRequest {
        var request = URLRequest(url: URL(string: endPoint.rawValue, relativeTo: baseURL)!)
        
        request.httpMethod = method.rawValue
        
        if let localParams = params as [String : AnyObject]? {
            if method == .GET {
                // GET params
                var queryItems = [URLQueryItem]()
                
                for (key, value) in localParams {
                    let stringValue = (value as? String) ?? String(describing: value)
                    queryItems.append(URLQueryItem(name: key, value: stringValue))
                }
                
                var components = URLComponents(url: request.url!, resolvingAgainstBaseURL: false)!
                
                components.queryItems = queryItems
                request.url = components.url
                
            } else {
                
                // JSON params
                let jsonData = try? JSONSerialization.data(withJSONObject: localParams, options: JSONSerialization.WritingOptions())
                request.httpBody = jsonData
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            }
        }
        
        return request
    }
}

// MARK: - Public API
public extension NetworkManager {

    func request<T: Decodable>(type: T.Type,apiEndPoint: ApiEndPoints,method: HttpMethods = .POST,params:[String: Any] , completion:  @escaping (T?, Error?) ->()) {
        
        let request = createRequest(baseURL: APIBaseUrl, endPoint: apiEndPoint, method: method, params: params)
        
        sendApi(request: request) { [unowned self] (error, response) in
            
            guard let validResponse = response else {
                DispatchQueue.main.async {
                    completion(nil, error ?? self.networkError(description: kUnknownResponseError))
                }
                return
            }
            
#if DEBUG
            self.printJsonResponse(data: validResponse, endPoint: request.url?.description)
#endif
            
            do {
                let returnedResponse = try JSONDecoder().decode(T.self, from: validResponse)
                completion(returnedResponse,nil)
                
            } catch let error {
                print("error.localizedDescription",error.localizedDescription)
                completion(nil, error)
            }
        }
    }
    
    func printJsonResponse(data: Data,endPoint: String?){
        do {
            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                // try to read out a dictionary
                print("endPoint:",endPoint ?? "")
                print("data response:",json["status"] ?? "")
            }
        } catch let error {
            print("error.localizedDescription",error.localizedDescription)
        }
    }
    
    // MARK: - Get file size from Remote URL
    func getRemoteFileSize(url: URL, completion: @escaping (Int64?) -> Void) {
        var request = URLRequest(url: url)
        request.httpMethod = "HEAD"

        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let httpResponse = response as? HTTPURLResponse,
               let contentLength = httpResponse.allHeaderFields["Content-Length"] as? String,
               let fileSize = Int64(contentLength) {
                completion(fileSize)
            } else {
                completion(nil)
            }
        }

        task.resume()
    }
}
