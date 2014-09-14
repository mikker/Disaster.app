//
//  File.swift
//  Disaster
//
//  Created by Mikkel Malmberg on 13/09/14.
//  Copyright (c) 2014 BRNBW. All rights reserved.
//

import Foundation

class DRMU {
  
  class var sharedClient : DRMU {
    struct Singleton {
      static let instance = DRMU()
    }
    return Singleton.instance
  }
  
  let baseURL = NSURL(string: "http://dr.dk")
  
  func GET(path :NSString, completionHandler:((NSURLResponse!, JSONValue!, NSError!) -> Void)!) {
    let request = self.requestWithMethod("GET", path: path)
    NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) { (response, data, error) in
      completionHandler(response, JSONValue(data), error)
    };
  }
  
  func requestWithMethod(method:String, path:String) -> NSURLRequest {
    var path = "/mu".stringByAppendingString(path)
    var url = NSURL(string: path, relativeToURL: baseURL)
    var request = NSURLRequest(URL: url)
    return request;
  }
  
}