//
//  HTTPRequestManager.swift
//  Rendezvous
//
//  Created by Admin on 6/30/16.
//  Copyright © 2016 Trose Technologies. All rights reserved.
//

import UIKit

class HTTPRequestManager: NSObject {
  
  // Singleton so any other class can access this one instance of the class
  static let sharedInstance = HTTPRequestManager()
  
  var statusCode: Int?
  
  override init() {
    super.init()
  }
  
  func makeHTTPPOSTCall(url urlString: String, data: NSDictionary, completionHandler: @escaping (NSDictionary)->Void){
    
    var convertedDict: NSDictionary!
    // Creates URL to be used through the NSURLSession with variable url from method call
    var request = URLRequest(url: URL(string: "http://45.55.175.57:5000/\(urlString)")!)
    // Session runs on the singleton session of NSURLSession class that manages under the hood networking
    let session = URLSession.shared
    request.httpMethod = "POST"
    // Ignores an locally cached data from the same URL
    request.cachePolicy = .reloadIgnoringLocalCacheData
    // Do-catch to serialize the Swift Dictionary into JSON object
    do {
      request.httpBody = try JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
    }
    catch {
      print("failure")
    }
    // Add headers to the URLRequest
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.addValue("JWT " + (KeychainWrapper.standard.string(forKey: "access_token") ?? ""), forHTTPHeaderField: "Authorization")
    // The task controls the actually connection handling(send and receive)
    // to the URL with the request
    let task = session.dataTask(with: request, completionHandler: {
      // Inside the completionHandler for dataTaskWithRequest
      // Handles all the data after a connection
      data, response, error in
      // Check for error
      if error != nil
      {
        print("error=\(error)")
        return
      }
      // Handles the server code to allows other classes
      // to check for 200,400,404,401 codes
      if let httpResponse = response as? HTTPURLResponse {
        self.statusCode = httpResponse.statusCode
        // do whatever with the status code
      }
      
      // Print out response string
      let responseString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
      print("responseString = \(responseString)")
      
      
      // Convert server json response to NSDictionary
      do {
        if let convertedJsonIntoDict = try JSONSerialization.jsonObject(with: data!, options: []) as? NSDictionary {
          
          // Print out dictionary
          print(convertedJsonIntoDict)
          convertedDict = convertedJsonIntoDict
        }
      }
      catch let error as NSError {
        print(error.localizedDescription)
      }
      // Creates dictionary to be passed to makeHTTPPostCall's
      // completion handler with the server code and converted dictionary
      let dict: NSDictionary = ["serverCode": self.statusCode ?? 0, "convertedDict": convertedDict ?? [:]]
      // Forces the non generic method calls to wait for the
      // asynchronous network call in order to have proper data handling
      
      completionHandler(dict)
    })
    // Required to start the task and connect to the URL
    task.resume()
  }
  
  func makeHTTPGETCall(_ name: String, op: String, value: String, completionHandler: @escaping (NSDictionary)->Void) {
    
    var convertedDict: NSDictionary!
    // RestlessAPI search querying
    let url = "{\"filters\":[{\"name\":\"\(name)\",\"op\":\"\(op)\",\"val\":\"\(value)\"}]}"
    var urlString: String = url.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
    urlString = "api/user?q=" + urlString
    var request = URLRequest(url: URL(string: "http://45.55.175.57:5000/\(urlString)")!)
    let session = URLSession.shared
    request.httpMethod = "GET"
    request.cachePolicy = .reloadIgnoringLocalCacheData
    
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.addValue("JWT " + (KeychainWrapper.standard.string(forKey: "access_token") ?? ""), forHTTPHeaderField: "Authorization")
    let task = session.dataTask(with: request, completionHandler: {
      data, response, error in
      // Check for error
      if error != nil
      {
        print("error=\(error)")
        return
      }
      
      if let httpResponse = response as? HTTPURLResponse {
        self.statusCode = httpResponse.statusCode
        // do whatever with the status code
      }
      
      // Print out response string
      let responseString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
      print("responseString = \(responseString)")
      
      
      // Convert server json response to NSDictionary
      do {
        if let convertedJsonIntoDict = try JSONSerialization.jsonObject(with: data!, options: []) as? NSDictionary {
          
          // Print out dictionary
          print(convertedJsonIntoDict)
          convertedDict = convertedJsonIntoDict
        }
      }
      catch let error as NSError {
        print(error.localizedDescription)
      }
      let dict: NSDictionary = ["serverCode": self.statusCode ?? 0, "convertedDict": convertedDict ?? [:]]
      completionHandler(dict)
    })
    
    task.resume()
  }
  
  func makeHTTPPATCHCall(_ url: String, data: Any, completionHandler: @escaping (NSDictionary) -> Void) {
    var convertedDict: NSDictionary!
    // Creates URL to be used through the NSURLSession with variable url from method call
    var request = URLRequest(url: URL(string: "http://45.55.175.57:5000/\(url)")!)
    // Session runs on the singleton session of NSURLSession class that manages under the hood networking
    let session = URLSession.shared
    request.httpMethod = "PATCH"
    // Ignores an locally cached data from the same URL
    request.cachePolicy = .reloadIgnoringLocalCacheData
    // Do-catch to serialize the Swift Dictionary into JSON object
    do {
      request.httpBody = try JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
    }
    catch {
      print("failure")
    }
    // Add headers to the URLRequest
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.addValue("JWT " + (KeychainWrapper.standard.string(forKey: "access_token") ?? ""), forHTTPHeaderField: "Authorization")
    // The task controls the actually connection handling(send and receive)
    // to the URL with the request
    let task = session.dataTask(with: request, completionHandler: {
      // Inside the completionHandler for dataTaskWithRequest
      // Handles all the data after a connection
      data, response, error in
      // Check for error
      if error != nil
      {
        print("error=\(error)")
        return
      }
      // Handles the server code to allows other classes
      // to check for 200,400,404,401 codes
      if let httpResponse = response as? HTTPURLResponse {
        self.statusCode = httpResponse.statusCode
        // do whatever with the status code
      }
      
      // Print out response string
      let responseString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
      print("responseString = \(responseString)")
      
      
      // Convert server json response to NSDictionary
      do {
        if let convertedJsonIntoDict = try JSONSerialization.jsonObject(with: data!, options: []) as? NSDictionary {
          
          // Print out dictionary
          print(convertedJsonIntoDict)
          convertedDict = convertedJsonIntoDict
        }
      }
      catch let error as NSError {
        print(error.localizedDescription)
      }
      // Creates dictionary to be passed to makeHTTPPostCall's
      // completion handler with the server code and converted dictionary
      let dict: NSDictionary = ["serverCode": self.statusCode ?? 0, "convertedDict": convertedDict ?? [:]]
      // Forces the non generic method calls to wait for the
      // asynchronous network call in order to have proper data handling
      
      completionHandler(dict)
    })
    // Required to start the task and connect to the URL
    task.resume()
  }
}
