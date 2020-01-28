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

        let prompt = UIAlertController(title: UserText.preserveLoginsTitle,
                                       message: UserText.preserveLoginsMessage,
                                       preferredStyle: .alert)
        prompt.addAction(title: UserText.preserveLoginsRemember) {
            PreserveLogins.shared.userDecision = .preserveLogins
            completion()
        }
        prompt.addAction(title: UserText.preserveLoginsForget) {
            PreserveLogins.shared.userDecision = .forgetAll
            completion()
        }
        controller.present(prompt, animated: true)
    }
    
}
