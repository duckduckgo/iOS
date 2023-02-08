//
//  OmniBarNotificationViewModel.swift
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

final class OmniBarNotificationViewModel: ObservableObject {
    
    enum Duration {
        static let notificationSlide: TimeInterval = 0.3
        static let cookieAnimationDelay: TimeInterval = notificationSlide * 0.75
        static let notificationCloseDelay: TimeInterval = 2.5
        static let notificationFadeOutDelay: TimeInterval = notificationCloseDelay + 2 * notificationSlide
    }
    
    let text: String
    let animationName: String
    
    @Published var isOpen: Bool = false
    @Published var animateCookie: Bool = false
    
    init(text: String, animationName: String) {
        self.text = text
        self.animationName = animationName
    }
    
    func showNotification(completion: @escaping () -> Void) {
        // Open the notification
        self.isOpen = true
        
        // Start cookie animation with a delay
        DispatchQueue.main.asyncAfter(deadline: .now() + Duration.cookieAnimationDelay) {
            self.animateCookie = true
        }
        
        // Close the notification
        DispatchQueue.main.asyncAfter(deadline: .now() + Duration.notificationCloseDelay) {
            self.isOpen = false
        }
        
        // Fire completion after everything
        DispatchQueue.main.asyncAfter(deadline: .now() + Duration.notificationFadeOutDelay) {
            completion()
        }
    }
}
