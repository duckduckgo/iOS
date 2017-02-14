//
//  DDGUtility.swift
//  DuckDuckGo
//
//  Created by Sean Reilly on 2017.01.17.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//

import Foundation

class DDGUtility: NSObject {
  static var emailPredicate: NSPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
  
  class func agentDDG() -> String {
    return "DDG-iOS-".appending((CFBundleGetValueForInfoDictionaryKey(CFBundleGetMainBundle(), kCFBundleVersionKey) as! String))
  }
  
  class func request(with URL: URL) -> URLRequest {
    let request = NSMutableURLRequest(url:URL)
    if let host = URL.host, host.hasSuffix("duckduckgo.com") {
      request.setValue(DDGUtility.agentDDG(), forHTTPHeaderField: "User-Agent")
    }
    return request as URLRequest
  }
  
  class func looksLikeURL(_ text: String) -> Bool {
    return text.hasPrefix("http://") || text.hasPrefix("https://")
  }
  
  class func extractQuery(fromDDGURL url: URL) -> String? {
    // parse URL query components
    let queryComponentsArray = url.query?.components(separatedBy: "&")
    var queryComponents:Dictionary<String,String> = [:]
    if let queryComponentsArray = queryComponentsArray {
      for queryComponent: String in queryComponentsArray {
        var parameter = queryComponent.components(separatedBy: "=")
        if parameter.count > 1 {
          queryComponents[parameter[0]] = parameter[1]
        }
      }
    }
    
    // check whether we have a DDG search URL
    if (url.host! == "duckduckgo.com") {
      if var query = queryComponents["q"], (url.path == "/" || url.path == "/ioslinks") {
        // yep! extract the search query...
        query = query.replacingOccurrences(of: "+", with: "%20")
        query = query.removingPercentEncoding ?? query
        return query
      } else {
        // a URL on DDG.com, but not a search query
        return nil
      }
    } else {
      // no, just a plain old URL.
      return nil
    }
  }
  
  
  class func validURLString(from urlString: String) -> String? {
    // check whether the entered text is a URL or a search query
    if let url = URL(string: urlString), url.scheme?.lengthOfBytes(using: .utf8) ?? 0 > 0 {
      // it has a scheme, so it's probably a valid URL
      return urlString
    } else {
      
      // if it matches the email regex, consider it a query string and not a URL
      if self.emailPredicate.evaluate(with: urlString) {
        return nil
      }
      
      // check whether adding a scheme makes it a valid URL - default to use http instead of https.  Too soon to default to https?
      let urlStringWithSchema = "http://\(urlString)"
      if let url = URL(string: urlStringWithSchema), url.host?.range(of: ".") != nil {
        // it has a host with a dot ("xyz.com"), so it's probably a URL
        return urlStringWithSchema
      } else {
        // it can't be made into a valid URL
        return nil
      }
    }
  }
  
  class func isQuery(_ queryOrURL: String) -> Bool {
    return validURLString(from: queryOrURL) != nil
  }
  

}
