//
//  DDGUtility.swift
//  DuckDuckGo
//
//  Created by Sean Reilly on 2017.01.17.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//

import Foundation
class DDGUtility: NSObject {
  class var emailPredicate: NSPredicate!
  

  class func agentDDG() -> String {
    return "DDG-iOS-".appending((CFBundleGetValueForInfoDictionaryKey(CFBundleGetMainBundle(), kCFBundleVersionKey) as! String))
  }
  
  class func request(with URL: URL) -> URLRequest {
    var request = MutableURLRequest(url:URL)
    if URL.host!.hasSuffix("duckduckgo.com") {
      request.setValue(DDGUtility.agentDDG(), forHTTPHeaderField: "User-Agent")
    }
    return request
  }
  
  class func looksLikeURL(_ text: String) -> Bool {
    return text.hasPrefix("http://") || text.hasPrefix("https://")
  }
  
  class func extractQuery(fromDDGURL url: URL) -> String? {
    // parse URL query components
    var queryComponentsArray = url.query!.components(separatedBy: "&")
    var queryComponents = [:]
    for queryComponent: String in queryComponentsArray {
      var parameter = queryComponent.components(separatedBy: "=")
      if parameter.count > 1 {
        queryComponents[parameter[0]] = parameter[1]
      }
    }
    
    // check whether we have a DDG search URL
    if (url.host! == "duckduckgo.com") {
      if (url.path == "/") || (url.path == "/ioslinks") && (queryComponents["q"] as! String) {
        // yep! extract the search query...
        var query = (queryComponents["q"] as! String)
        query = query.replacingOccurrences(of: "+", with: "%20")
        query = query.replacingPercentEscapes(using: String.Encoding.utf8)
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
    var url = URL(string: urlString)!
    if url && url.scheme! {
      // it has a scheme, so it's probably a valid URL
      return urlString
    } else {
      // check whether adding a scheme makes it a valid URL
      var urlStringWithSchema = "http://\(urlString)"
      url = URL(string: urlStringWithSchema)!
      if nil == self.emailPredicate {
        var regExPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        self.emailPredicate = regExPredicate
      }
      if self.emailPredicate.evaluate(withObject: urlString) {
        return nil
      }
      if url && url.host! && (url.host! as NSString).rangeOf(".").location != NSNotFound {
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
