//
//  LoginDetection.swift
//  DuckDuckGo
//
//  Created by Chris Brind on 09/01/2020.
//  Copyright © 2020 DuckDuckGo. All rights reserved.
//

import WebKit

protocol LoginDetectionURLProvider {
    
    var url: URL? { get }
    
}

protocol LoginDetectionCookiesProvider {
    
    @available (iOS 11, *)
    func getAllCookies(completion: @escaping ([HTTPCookie]) -> Void)
    
}

protocol LoginDetectionAction {
    
    var method: String? { get }

}

class LoginDetection {
    
    private var cookies: [HTTPCookie]?
    private var domain: String?
    
    init() {
        print("*** LoginDetection init")
    }
    
    func webView(withURL urlProvider: LoginDetectionURLProvider,
                 andCookies cookiesProvider: LoginDetectionCookiesProvider,
                 allowedAction action: LoginDetectionAction,
                 completion: @escaping (Bool) -> Void) {

        self.cookies = nil
        self.domain = nil
        
        guard #available(iOS 11, *) else {
            completion(false)
            return
        }
        
        guard action.method == "POST" else {
            completion(false)
            return
        }
        
        let domain = urlProvider.url?.host
        cookiesProvider.getAllCookies { cookies in
            self.cookies = self.cookiesForDomain(domain, from: cookies)
            self.domain = domain
            completion(true)
        }
    }
    
    /// Completion passes true if the navigation was a post and resulted in different cookies.
    func webViewDidFinishNavigation(withCookies cookiesProvider: LoginDetectionCookiesProvider, completion: @escaping (Bool) -> Void) {
        guard #available(iOS 11, *) else {
            completion(false)
            return
        }
        
        guard let initialCookies = self.cookies else {
            completion(false)
            return
        }
        
        cookiesProvider.getAllCookies { cookies in
            let postCookies = self.cookiesForDomain(self.domain, from: cookies)
            let isPossibleLogin = !self.equals(initialCookies, postCookies)
            completion(isPossibleLogin)
        }
    }
    
    private func cookiesForDomain(_ domain: String?, from cookies: [HTTPCookie]) -> [HTTPCookie] {
        return cookies.filter { $0.domain == domain }.sorted(by: { $0.name < $1.name })
    }
    
    private func equals(_ lhs: [HTTPCookie], _ rhs: [HTTPCookie]) -> Bool {
        guard lhs.count == rhs.count else { return false }
        
        for i in 0 ..< lhs.count {
            if !equals(lhs[i], rhs[i]) {
                return false
            }
        }
        
        return true
    }
    
    private func equals(_ lhs: HTTPCookie, _ rhs: HTTPCookie) -> Bool {
        return lhs.name == rhs.name
            && lhs.value == rhs.value
            && lhs.path == rhs.path
    }
    
}

extension WKWebView: LoginDetectionURLProvider, LoginDetectionCookiesProvider {

    @available (iOS 11, *)
    func getAllCookies(completion: @escaping ([HTTPCookie]) -> Void) {
        configuration.websiteDataStore.httpCookieStore.getAllCookies(completion)
    }
    
}

extension WKNavigationAction: LoginDetectionAction {

    var method: String? {
        return request.httpMethod
    }
    
}
