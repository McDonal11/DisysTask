//
//  Singleton.swift
//  task
//
//  Created by Gopal on 10/08/19.
//  Copyright © 2019 Gopal. All rights reserved.
//

import UIKit
import Foundation
import SystemConfiguration

class Singleton: NSObject {
    
    static let shared = Singleton()
    
    let baseURL = "https://api.qa.mrhe.gov.ae/mrhecloud/v1.4/api/"
    let consumer_key = "mobile_dev"
    let consumer_secret = "20891a1b4504ddc33d42501f9c8d2215fbe85008"
    
    func apiCall(apiType: String, apiURL: String, parameters: [String: Any], completion: @escaping ([String: Any]?, Error?) -> Void) {
        
        let url = URL(string: apiURL)!
        
        let session = URLSession.shared
        
        var request = URLRequest(url: url)
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        if apiType == "GET" {
            
            request.addValue(consumer_key, forHTTPHeaderField: "consumer-key")
            request.addValue(consumer_secret, forHTTPHeaderField: "consumer-secret")
            
        }
        else {
            
            request.httpMethod = "POST"
            request.addValue(consumer_key, forHTTPHeaderField: "consumer-key")
            
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
            } catch let error {
                print(error.localizedDescription)
                completion(nil, error)
            }
        }
        
        let task = session.dataTask(with: request, completionHandler: { data, response, error in
            
            guard error == nil else {
                completion(nil, error)
                return
            }
            
            guard let data = data else {
                completion(nil, NSError(domain: "dataNilError", code: -100001, userInfo: nil))
                return
            }
            
            do {
                //create json object from data
                guard let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers ) as? [String: Any] else {
                    completion(nil, NSError(domain: "invalidJSONTypeError", code: -100009, userInfo: nil))
                    return
                }
                //print("JSONNN_____     ",json)
                completion(json, nil)
                
            } catch let error {
                print(error.localizedDescription)
                completion(nil, error)
            }
        })
        
        task.resume()
    }
    
}


public class Reachability {
    public func isConnectedToNetwork() -> Bool {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }) else {
            return false
        }
        
        var flags: SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            return false
        }
        if flags.isEmpty {
            return false
        }
        
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        
        return (isReachable && !needsConnection)
    }
}
