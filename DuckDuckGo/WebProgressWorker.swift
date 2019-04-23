//
//  WebProgressWorker.swift
//  DuckDuckGo
//
//  Created by Bartek on 12/04/2019.
//  Copyright © 2019 DuckDuckGo. All rights reserved.
//

import UIKit

class WebProgressWorker {
    
    private struct Constants {
        static let initialProgress: CGFloat = 0.1
    }
    
    weak var progressBar: ProgressView?
    
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
