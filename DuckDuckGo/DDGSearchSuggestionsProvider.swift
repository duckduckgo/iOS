//
// Created by Sean Reilly on 2017.01.20.
// Copyright (c) 2017 DuckDuckGo. All rights reserved.
//

import Foundation

let kDDGSuggestionsURLString = "https://duckduckgo.com/ac/?q=";

class DDGSearchSuggestionsProvider {
  
  var suggestionsCache: [String : [String]] = [:]
  let session: Foundation.URLSession
  var serverRequest: NSMutableURLRequest
  var bangs: [String : String] = [:]
  
  static var sharedProvider: DDGSearchSuggestionsProvider?
  
  class func shared() -> DDGSearchSuggestionsProvider {
    if sharedProvider==nil {
      sharedProvider = DDGSearchSuggestionsProvider()
    }
    return sharedProvider!
  }
  
  init() {
    session = URLSession(configuration: URLSessionConfiguration.ephemeral)
    serverRequest = NSMutableURLRequest(url: URL(string:  "https://ac.duckduckgo.com/")!,
                                        cachePolicy: .reloadIgnoringLocalCacheData,
                                        timeoutInterval:5)
    serverRequest.httpMethod = "POST"
    serverRequest.setValue("Keep-Alive", forHTTPHeaderField: "Connection")
    serverRequest.setValue("gzip", forHTTPHeaderField: "Accept-Encoding")
    serverRequest.setValue("text/plain; charset=UTF-8", forHTTPHeaderField: "Accept")
    serverRequest.setValue(DDGUtility.agentDDG(), forHTTPHeaderField: "User-Agent")
  }
  
  func suggestions(forSearchText searchText: String) -> [Any] {
    var bestMatch: String? = nil
    for suggestionText: String in suggestionsCache.keys {
      if searchText.hasPrefix(suggestionText) && (suggestionText.characters.count > bestMatch!.characters.count) {
        bestMatch = suggestionText
      }
    }
    if let bestMatch = bestMatch, let matchResults = suggestionsCache[bestMatch] {
      return matchResults
    } else {
      return []
    }
  }
  
  func downloadSuggestions(forSearchText searchText: String, success: @escaping (_: Void) -> Void) {
    // check the cache before querying the server
    if (suggestionsCache[searchText] != nil) {
      // we have this suggestion already
      success()
      return
    } else if (searchText == "") {
      success()
    } else {
      var urlString = kDDGSuggestionsURLString.appending(searchText.addingPercentEncoding(withAllowedCharacters: CharacterSet.alphanumerics) ?? searchText)
      serverRequest.url = URL(string: urlString)!
      
      session.dataTask(with: serverRequest as URLRequest, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) -> Void in
        if error == nil, let data = data {
          if let jsonDict = try JSONSerialization.jsonObject(with: data) as? Dictionary {
            suggestionsCache[searchText] = jsonDict
            success()
          } else {
            print("error: unable to extract JSON from autocompletion response: \(data)")
          }
        } else {
          print("error: \(error.userInfo)")
        }
      }).resume()
    }
    
  }
  
  func emptyCache() {
    suggestionsCache.removeAll()
  }
  
  func textIsLink(_ text: String) -> Bool {
    let linkDetector = try! NSDataDetector(types: ( NSTextCheckingResult.CheckingType.link.rawValue))
    let matches = linkDetector.matches(in: text, options: [], range: NSRange(location: 0, length: text.characters.count))
    for match: NSTextCheckingResult in matches {
      if match.resultType == .link {
        return true
      }
    }
    return false
  }

}
