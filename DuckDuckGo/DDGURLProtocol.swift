//
// Created by Sean Reilly on 2017.01.16.
// Copyright (c) 2017 DuckDuckGo. All rights reserved.
//

// NOTE I think this class is likely no longer needed since we can perform the key function
// (setting user-agent, but only for duckduckgo.com requests) when sending the requests.

import Foundation

class DDGURLProtocol: URLProtocol, NSURLConnectionDelegate, NSURLConnectionDataDelegate {
  
  var connection: NSURLConnection?
  
  override class func canInit(with request: URLRequest) -> Bool {
    if let hostname = request.url?.host, hostname.hasSuffix("duckduckgo.com") {
      if (URLProtocol.property(forKey: "UserAgentSet", in: request) != nil) {
        return true
      }
    }
    return false
  }
  
  override class func canonicalRequest(for request: URLRequest) -> URLRequest {
    return request
  }
  
  override func startLoading() {
    var request = self.request
    if let hostname = request.url?.host, hostname.hasSuffix("duckduckgo.com"){
      request.setValue(DDGUtility.agentDDG(), forHTTPHeaderField: "User-Agent")
      if let mutableRequest = request as? MutableURLRequest {
        URLProtocol.setProperty(true, forKey: "UserAgentSet", in: mutableRequest)
      }
    }
    self.connection = NSURLConnection(request: request, delegate: self)
  }
  
  override func stopLoading() {
    self.connection?.cancel()
  }
  
  
  // MARK: - NSURLConnectionDelegate
  func connection(_ connection: NSURLConnection, didFailWithError error: Error) {
    self.client?.urlProtocol(self, didFailWithError: error)
    self.connection = nil
  }
  
  
  // MARK: - NSURLConnectionDataDelegate
  func connectionDidFinishLoading(_ connection: NSURLConnection) {
    self.client!.urlProtocolDidFinishLoading(self)
    self.connection = nil
  }
  
  func connection(_ connection: NSURLConnection, didReceive data: Data) {
    self.client?.urlProtocol(self, didLoad:data)
  }
  
  func connection(_ connection: NSURLConnection, didReceive response: URLResponse) {
    self.client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .allowed)
  }
  
}

