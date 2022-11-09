//
//  AppIconChanger.swift
//  DuckDuckGo
//
//  Copyright © 2022 DuckDuckGo. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import Foundation
import UIKit
import os.log
import Core

class AppIconChanger {
    
    private var currentlySetAppIcon: AppIcon!
    private var appIconToChangeTo: AppIcon!
    private var completionHandlerToExecuteUponAppChange: ((Error?) -> Void)? = nil
    
    init() {}
    
    func changeAppIcon(_ appIcon: AppIcon, completionHandler: ((Error?) -> Void)? = nil) {
        self.setCurrentAppIcon()
        self.setAppIconToChangeTo(appIcon: appIcon)
        self.setCompletionHandlerToExecuteUponAppChange(completionHandler: completionHandler)
        self.changeAppIconIfNeeded()
        self.deallocateClassAtrributes()
    }
    
    private func setCurrentAppIcon() {
        self.currentlySetAppIcon = AppIconManager.shared.appIcon
    }
    
    private func setAppIconToChangeTo(appIcon: AppIcon) {
        self.appIconToChangeTo = appIcon
    }
    
    private func setCompletionHandlerToExecuteUponAppChange(completionHandler: ((Error?) -> Void)? = nil) {
        self.completionHandlerToExecuteUponAppChange = completionHandler
    }
        
    private func changeAppIconIfNeeded() {
        if !isCurrentlySetAppIconTheSameAsAppIconToChangeTo() {
            self.changeAppIconWithCompletionHandler()
        }
    }
        
    private func isCurrentlySetAppIconTheSameAsAppIconToChangeTo() -> Bool {
        return self.currentlySetAppIcon == appIconToChangeTo
    }
    
    private func changeAppIconWithCompletionHandler() {
        let alternateIconName = self.getAlternativeAppIconName()
        UIApplication.shared.setAlternateIconName(alternateIconName) { error in
            if let error = error {
                self.logErrorInGeneralLog(error: error)
                self.completionHandlerToExecuteUponAppChange?(error)
            }
            self.completionHandlerToExecuteUponAppChange?(nil)
        }
    }
        
    private func getAlternativeAppIconName() -> String? {
        if appIconToChangeTo != AppIcon.defaultAppIcon {
            return appIconToChangeTo.rawValue
        }
        return nil
    }
    
    private func logErrorInGeneralLog(error: Error) {
        os_log("Error while changing app icon: %s", log: generalLog, type: .debug, error.localizedDescription)
    }
    
    private func deallocateClassAtrributes() {
        self.currentlySetAppIcon = nil
        self.appIconToChangeTo = nil
    }
    
}
