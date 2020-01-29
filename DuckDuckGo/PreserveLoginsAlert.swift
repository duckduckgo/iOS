//
//  PreserveLoginsAlert.swift
//  DuckDuckGo
//
//  Created by Chris Brind on 22/01/2020.
//  Copyright © 2020 DuckDuckGo. All rights reserved.
//

import Foundation
import Core

class PreserveLoginsAlert {
    
    class func showInitialPromptIfNeeded(usingController controller: UIViewController, completion: @escaping () -> Void) {
        let logins = PreserveLogins.shared
        guard logins.userDecision == .unknown, !logins.detectedDomains.isEmpty else {
            completion()
            return
        }

        let dateShown = Date()
        let prompt = UIAlertController(title: UserText.preserveLoginsTitle,
                                       message: UserText.preserveLoginsMessage,
                                       preferredStyle: .alert)
        prompt.addAction(title: UserText.preserveLoginsRemember) {
            PreserveLogins.shared.userDecision = .preserveLogins
            TimedPixel(.preserveLoginsUserDecisionPreserve, date: dateShown).fire()
            completion()
        }
        prompt.addAction(title: UserText.preserveLoginsForget) {
            PreserveLogins.shared.userDecision = .forgetAll
            TimedPixel(.preserveLoginsUserDecisionForget, date: dateShown).fire()
            completion()
        }
        controller.present(prompt, animated: true)
    }
    
}
