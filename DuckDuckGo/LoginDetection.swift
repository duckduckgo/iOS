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
    
    private var navigation: LoginDetectionNavigation?
    private var cookies: [HTTPCookie]?
    
    func navigation(_ navigation: LoginDetectionNavigation,
                    forWebView webView: LoginDetectionWebView,
                    allowedAction action: LoginDetectionAction,
                    completion: @escaping () -> Void) {
        
        guard #available(iOS 11, *) else {
            completion()
            return
        }
        
        guard action.method == "POST" else {
            completion()
            return
        }
        
        webView.getAllCookies { cookies in
            self.cookies = cookies.filter { $0.domain == webView.url?.host }
            self.navigation = navigation
            completion()
        }
    }
    
    func navigation(_ navigation: LoginDetectionNavigation, didFinishForWebView webView: LoginDetectionWebView) {
        
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
