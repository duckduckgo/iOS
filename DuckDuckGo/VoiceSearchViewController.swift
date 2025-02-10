//
//  VoiceSearchViewController.swift
//  DuckDuckGo
//
//  Copyright © 2021 DuckDuckGo. All rights reserved.
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
import SwiftUI

protocol VoiceSearchViewControllerDelegate: AnyObject {
    func voiceSearchViewController(_ controller: VoiceSearchViewController, didFinishQuery query: String?, target: VoiceSearchTarget)
}

enum VoiceSearchTarget {
    case search
    case aiChat
}

class VoiceSearchViewController: UIViewController {
    weak var delegate: VoiceSearchViewControllerDelegate?
    private let speechRecognizer = SpeechRecognizer()
    private lazy var blurView: UIVisualEffectView = {
        let effectView = UIVisualEffectView(effect: UIBlurEffect(style: .regular))
        return effectView
    }()

    private func setupConstraints() {
        blurView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            blurView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            blurView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            blurView.topAnchor.constraint(equalTo: view.topAnchor)
        ])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(blurView)
        view.backgroundColor = .clear
        installSpeechView()
        setupConstraints()
    }
    
    private func installSpeechView() {
        let model = VoiceSearchFeedbackViewModel(speechRecognizer: speechRecognizer)
        model.delegate = self
        let speechView = VoiceSearchFeedbackView(speechModel: model)
        let controller = UIHostingController(rootView: speechView)
        controller.view.backgroundColor = .clear
        installChildViewController(controller)
    }
}

extension VoiceSearchViewController: VoiceSearchFeedbackViewModelDelegate {
    func voiceSearchFeedbackViewModel(_ model: VoiceSearchFeedbackViewModel, didFinishQuery query: String?, target: VoiceSearchTarget) {
        delegate?.voiceSearchViewController(self, didFinishQuery: query, target: target)
    }
}
