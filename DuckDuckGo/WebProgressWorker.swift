//
//  WebProgressWorker.swift
//  DuckDuckGo
//
//  Copyright © 2019 DuckDuckGo. All rights reserved.
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

import UIKit

class WebProgressWorker {
    
    private struct Constants {
        static let initialProgress: CGFloat = 0.1
    }
    
    weak var progressBar: ProgressView? {
        didSet(oldValue) {
            oldValue?.hide()
            
            if isLoading {
                self.progressBar?.show(initialProgress: currentProgress)
            } else {
                self.progressBar?.hide()
            }
        }
    }
    
    private var isLoading = false
    private var currentProgress: CGFloat = 0.0
    
    func didStartLoading() {
        guard isLoading == false else { return }

        isLoading = true
        progressBar?.show()
        progressBar?.increaseProgress(to: Constants.initialProgress, animated: true)
    }
    
    func progressDidChange(_ progress: Double) {
        guard isLoading else { return }
        
        let progress = CGFloat(progress)
        guard progress > currentProgress else { return }
        currentProgress = progress
        
        progressBar?.increaseProgress(to: progress, animated: true)
    }
    
    func didFinishLoading() {
        guard isLoading else { return }
        isLoading = false
        progressBar?.finishAndHide()
        currentProgress = 0
    }
}
