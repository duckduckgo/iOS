//
//  LoginDetection.swift
//  DuckDuckGo
//
//  Created by Chris Brind on 09/01/2020.
//  Copyright © 2020 DuckDuckGo. All rights reserved.
//

import WebKit

protocol LoginDetectionWebView {
    
    var url: URL? { get }
    
    @available (iOS 11, *)
    func getAllCookies(completion: @escaping ([HTTPCookie]) -> Void)
    
}

protocol LoginDetectionNavigation: NSObjectProtocol {
    
}

protocol LoginDetectionAction {
    
    var method: String? { get }

}

class LoginDetection {
    
    private var cookies: [HTTPCookie]?
    
    func webView(_ webView: LoginDetectionWebView, allowedAction action: LoginDetectionAction, completion: @escaping () -> Void) {
        guard #available(iOS 11, *) else {
            completion()
            return
        }
        
        guard action.method == "POST" else {
            completion()
            return
        }
        
        webView.getAllCookies { cookies in
            self.cookies = self.cookiesForDomain(webView.url?.host, from: cookies)
            completion()
        }
    }
    
    /// Completion passes true if the navigation was a post and resulted in different cookies.
    func webViewDidFinishNavigation(_ webView: LoginDetectionWebView, completion: @escaping (Bool) -> Void) {
        guard #available(iOS 11, *) else {
            completion(false)
            return
        }
        
        webView.getAllCookies { cookies in
            let cookies = self.cookiesForDomain(webView.url?.host, from: cookies)
            completion(cookies != self.cookies)
        }
    }
    
    private func cookiesForDomain(_ domain: String?, from cookies: [HTTPCookie]) -> [HTTPCookie] {
        return cookies.filter { $0.domain == domain }.sorted(by: { $0.name < $1.name })
    }
    
}

extension WKWebView: LoginDetectionWebView {

    @available (iOS 11, *)
    func getAllCookies(completion: @escaping ([HTTPCookie]) -> Void) {
        configuration.websiteDataStore.httpCookieStore.getAllCookies(completion)
    }
    
}

extension WKNavigation: LoginDetectionNavigation {

}
