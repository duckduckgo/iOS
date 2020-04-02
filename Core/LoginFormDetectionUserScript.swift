//
//  LoginFormDetectionUserScript.swift
//  Core
//
//  Created by Chris Brind on 02/04/2020.
//  Copyright © 2020 DuckDuckGo. All rights reserved.
//

import WebKit

public protocol LoginFormDetectionDelegate: NSObjectProtocol {
    
    func loginFormDetectionUserScriptDetectedLoginForm(_ script: LoginFormDetectionUserScript)
    
}

public class LoginFormDetectionUserScript: NSObject, UserScript {

    public lazy var source: String = {
       return loadJS("login-form-detection")
    }()
    
    public var injectionTime: WKUserScriptInjectionTime = .atDocumentStart
    
    public var forMainFrameOnly: Bool = false
    
    public var messageNames: [String] = [ "loginFormDetected" ]
    
    public weak var delegate: LoginFormDetectionDelegate?
    
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        delegate?.loginFormDetectionUserScriptDetectedLoginForm(self)
    }
    
    deinit {
        print("*** deinit LFD")
    }
    
}
