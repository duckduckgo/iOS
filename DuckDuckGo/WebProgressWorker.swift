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
        guard let progressBar = progressBar,
            isLoading == false else {
                print("===> FAILED START")
                return
        }
        
        print("===> START")
        isLoading = true
        progressBar.show()
        self.progressBar?.updateProgress(Constants.initialProgress, animated: true)
    }
    
    func progressDidChange(_ progress: Double) {
        guard isLoading else {
            print("==> FAILED update to \(progress)")
            return
        }
        
        let progress = CGFloat(progress)
        guard progress > currentProgress else { return }
        currentProgress = progress
        
        self.progressBar?.updateProgress(progress, animated: true)
    }
    
    func didFinishLoading() {
        guard isLoading else { return }
        isLoading = false
        print("===> FINISH")
        self.progressBar?.hide()
        self.currentProgress = 0
    }
}
