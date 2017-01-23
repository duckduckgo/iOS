//
// Created by Sean Reilly on 2017.01.16.
// Copyright (c) 2017 DuckDuckGo. All rights reserved.
//

import Foundation

class DDGURLProtocol: URLProtocol, NSURLConnectionDelegate, NSURLConnectionDataDelegate {
  
  
  // MARK: - URLProtocol
  override class func canInit(with request: URLRequest) -> Bool {
    if request.url?.host?.hasSuffix("duckduckgo.com") {
      if (URLProtocol.property(forKey: "UserAgentSet", inRequest: request) != nil) {
        return true
      }
    }
    return false
  }
  
  class func canonicalRequest(forRequest request: URLRequest) -> URLRequest {
    return request
  }
  
  override func startLoading() {
    var request = self.request
    if request.url!.host!.hasSuffix("duckduckgo.com") {
      request.setValue(DDGUtility.agentDDG(), forHTTPHeaderField: "User-Agent")
      URLProtocol.setProperty(true, forKey: "UserAgentSet", inRequest: request)
    }
    self.connection = NSURLConnection(request, delegate: self)
  }
  
  override func stopLoading() {
    self.connection.cancel()
  }
  
  
  // MARK: - NSURLConnectionDelegate
  func connection(_ connection: NSURLConnection, didFailWithError error: Error?) {
    self.client!.urlProtocol()
    self.connection = nil
  }
  
  
  // MARK: - NSURLConnectionDataDelegate
  func connectionDidFinishLoading(_ connection: NSURLConnection) {
    self.client!.urlProtocolDidFinishLoading()
    self.connection = nil
  }
  
  func connection(_ connection: NSURLConnection, didReceiveData data: Data) {
    self.client!.urlProtocol()
  }
  
  func connection(_ connection: NSURLConnection, didReceiveResponse response: URLResponse) {
    self.client!.urlProtocol()
  }
  
  var connection: NSURLConnection!
  
}

